const https = require('https');
const http = require('http');
const Koa = require('koa');
const cors = require('@koa/cors');
const sslify = require('koa-sslify').default;
const Router = require('@koa/router');
const Logger = require('koa-logger');
const {
    koaBody
} = require('koa-body');
const SocketIO = require('socket.io');
const WebSocket = require('ws');
const {
    Server
} = require('ws');

const {
    graphql,
    buildSchema
} = require('graphql');

const resolver = require('./resolver');
const fs = require('fs');

const port = 7777;
const options = {
    key: fs.readFileSync('../SSL/localhost-key.pem'),
    cert: fs.readFileSync('../SSL/localhost.pem'),
    //passphrase: fs.readFileSync('../SSL/key.txt').toString(),
};

const app = new Koa;
const router = new Router;
const httpServer = http.createServer(app.callback());
const server = https.createServer(options, app.callback());

let wsConnection;
const wss = new Server({
    server
});

wss.on('connection', function connection(ws) {
    ws.on('error', console.error);
    wsConnection = ws;
    ws.on('message', function message(data) {
        console.log('received: %s', data);
    });
});

const schema = buildSchema(fs.readFileSync('./schema.graphql').toString());

const corsoptions = {
    origin: '*'
};

app.use(cors(options));

app.use(sslify({
    resolver: (ctx) => {
        if (ctx.headers['x-forwarded-proto'] !== 'https') {
            console.log('https://' + ctx.hostname + ':' + port + ctx.url);
            return 'https://' + ctx.hostname + ':' + port + ctx.url;
        } else return null;
    }
}));
app.use(koaBody());

app.use(async (ctx, next) => {
    try {
        await next();
    } catch (err) {
        ctx.status = err.statusCode || err.status || 500;
        ctx.response.type = 'json';
        console.log('Error handled by Koa: ', err.message);
        ctx.body = {
            error: err.message
        };
    }
});

router.post('/api/:parm', async (ctx) => {
    let content = ctx.request.body;
    console.log(ctx.request);
    ctx.response.type = 'json';
    if (ctx.params.parm == 'test') {
        ctx.body = {
            message: 'Hello'
        };
        return;
    } else if (ctx.params.parm == 'gql') {
        let variables = content.variables ? json.variables : {};
        let context = content.context ? content.context : {};
        let toUser = null;
        if (content.query) {
            toUser = await graphql(schema, content.query, resolver, context, variables);
        } else if (content.mutation) {
            toUser = await graphql(schema, content.mutation, resolver, context, variables);
        } else {
            console.error('Invalid GraphQL type - query or mutation is required');
            ctx.body = {
                error: 'Invalid GraphQL type - query or mutation is required'
            };
            return;
        }
        if (toUser.errors) {
            console.error('GQL Error: ' + toUser.errors[0].message);
            ctx.body = {
                error: 'GraphQL error: ' + toUser.errors[0].message
            };
            return;
        } else if (toUser.data) {
            console.log(toUser.data);
            if ((!(!toUser.data.setRequest)) && (toUser.data.setRequest.State == 'New')) {
                //io.emit('message', toUser);
                if (wsConnection && wsConnection.readyState === WebSocket.OPEN) {
                    wsConnection.send(JSON.stringify(toUser.data));
                    console.log('WSS: send to client!');
                } else {
                    console.log('WebSocket connection is not open.');
                }
                console.log(toUser);
            }
            ctx.body = toUser;
            return;
        } else {
            console.error('Unexpected GraphQL exceptional content!');
            ctx.body = {
                error: 'Unexpected GraphQL exceptional content...'
            };
            return;
        }
    } else {
        console.error('Invalid parameter ' + ctx.params.parm);
        ctx.body = {
            error: 'Invalid parameter ' + ctx.params.parm
        };
        return;
    }
});

router.get('/api', async (ctx) => {
    ctx.response.type = 'json';
    ctx.body = {
        message: "Welcome"
    };
});

app.use(Logger())
    .use(router.routes())
    .use(router.allowedMethods());

server.on('error', (err, ctx) => {
    console.error('Server error', err, ctx);
});

httpServer.listen(port - 10, () => {
    console.log(`HTTP Server started on port ${port-10}`);
});
server.listen(port, () => {
    console.log(`HTTPS Server started on port ${port}!`);
});

const io = SocketIO(server);
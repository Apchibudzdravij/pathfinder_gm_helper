const https = require('https');
const http = require('http');
const Koa = require('koa');
const sslify = require('koa-sslify').default;
const Router = require('@koa/router');
const Logger = require('koa-logger');
const {
    koaBody
} = require('koa-body');

const {
    graphql,
    buildSchema
} = require('graphql');

const resolver = require('./resolver');
const fs = require('fs');

const port = 7777;
const options = {
    key: fs.readFileSync('../SSL/key.pem'),
    cert: fs.readFileSync('../SSL/cert.pem'),
    passphrase: fs.readFileSync('../SSL/key.txt').toString(),
};

const app = new Koa;
const router = new Router;
const httpServer = http.createServer(app.callback());
const server = https.createServer(options, app.callback());

const schema = buildSchema(fs.readFileSync('./schema.graphql').toString());

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

httpServer.listen(port - 10, () => {
    console.log(`HTTP Server started on port ${port-10}`);
});
server.listen(port, () => {
    console.log(`HTTPS Server started on port ${port}!`);
});

server.on('error', (err, ctx) => {
    console.error('Server error', err, ctx);
});
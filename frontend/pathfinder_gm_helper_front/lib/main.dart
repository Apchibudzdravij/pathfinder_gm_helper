//import 'dart:math';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pathfinder_gm_helper_front/content/environment/environment.dart';
import 'package:pathfinder_gm_helper_front/content/environment/hazard.dart';
import 'package:pathfinder_gm_helper_front/content/environment/weather.dart';
import 'package:pathfinder_gm_helper_front/content/environment/wilddetail.dart';
import 'package:pathfinder_gm_helper_front/content/personal/campain.dart';
import 'package:pathfinder_gm_helper_front/content/personal/personalarea.dart';
import 'package:pathfinder_gm_helper_front/content/personal/session.dart';
import 'package:provider/provider.dart';

import 'package:pathfinder_gm_helper_front/content/signin.dart';
import 'package:pathfinder_gm_helper_front/content/monsters.dart';
import 'package:pathfinder_gm_helper_front/content/environment/wilderness.dart';

import 'content/environment/subweather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppPageState(),
      child: OKToast(
        child: MaterialApp(
          title: 'Pathfinder GM Helper',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: MyHomePage(title: 'Помощник Мастера Игры Pathfinder'),
        ),
      ),
    );
  }
}

class MyAppPageState extends ChangeNotifier {
  var stateOfMain = 'tableMain';

  Future<void> setStateOfMain(String nesWtate) async {
    stateOfMain = nesWtate;
    envname = '';
    envdesc = '';
    envsrc = '';
    swid = -1;
    notifyListeners();
  }

  void setStateOfMainForEnvUpdate(
      String nesWtate, String name, String description, String source) {
    stateOfMain = nesWtate;
    envname = name;
    envdesc = description;
    envsrc = source;
    notifyListeners();
  }

  var uid = -1;
  var name = '';
  var type = '';

  var pid = -1;
  var swid = -1;

  var envname = '';
  var envdesc = '';
  var envsrc = '';

  void setUser(String name, int uid, String type) {
    this.uid = uid;
    this.name = name;
    this.type = type;
    if (this.uid != -1) {
      this.stateOfMain = 'tableMain';
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = '';
  late WebSocketChannel channel;

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    channel = HtmlWebSocketChannel.connect('wss://localhost:7777/');
  }

  void connectToWebSocket(BuildContext context, int uid) {
    channel.sink.close();
    channel = HtmlWebSocketChannel.connect('wss://localhost:7777/');
    channel.stream.listen((message) {
      print('Received message: $message');
      var jsonmessage = json.decode(message.toString());
      //_showToast(context, jsonmessage['setRequest']['Message'],
      //    int.parse(jsonmessage['setRequest']['RID']), uid);
      showToastWidget(
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: 300,
              height: 100,
              child: Card(
                color: Color.fromRGBO(239, 214, 255, 1),
                child: SingleChildScrollView(
                  child: Text(
                    jsonmessage['setRequest']['Message'],
                    style: TextStyle(fontSize: 200.0),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ),
          position: ToastPosition(align: Alignment.bottomLeft, offset: 10.0),
          duration: Duration(seconds: 10));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppPageState>();
    var stateOfMain = appState.stateOfMain;

    if (appState.uid == -1) {
      channel.sink.close();
    } else if (appState.type == 'm') {
      connectToWebSocket(context, appState.uid);
    }

    Widget page;
    switch (stateOfMain) {
      case "tableMain":
        //page = TableMainPage();
        page = EnvironmentApp();
        break;
      case "login":
        page = LogIn();
        break;
      case "monsters":
        page = MonstersApp();
        break;
      case "environment":
        page = EnvironmentApp();
        break;
      case "charachterCreation":
        page = Placeholder();
        break;
      case "magic":
        page = Placeholder();
        break;
      case "items":
        page = Placeholder();
        break;
      case "rules":
        page = Placeholder();
        break;
      case "myRoom":
        page = PersonalArea();
        break;
      case "addHazard":
        page = AddHazard(
            name: appState.envname,
            desc: appState.envdesc,
            src: appState.envsrc);
        break;
      case "showHazard":
        page = ShowHazard();
        break;
      case "addWeather":
        page = AddWeather(
            name: appState.envname,
            desc: appState.envdesc,
            src: appState.envsrc);
        break;
      case "showWeather":
        page = ShowWeather();
        break;
      case "addSubWeather":
        page = AddSubWeather(
            name: appState.envname,
            desc: appState.envdesc,
            src: appState.envsrc);
        break;
      case "addWilderness":
        page = AddWilderness(
            name: appState.envname,
            desc: appState.envdesc,
            src: appState.envsrc);
        break;
      case "showWilderness":
        page = ShowWilderness();
        break;
      case "addWildDetail":
        page = AddWildDetail(name: appState.envname, desc: appState.envdesc);
        break;
      case "addCampain":
        page = AddCampain(name: appState.envname, desc: appState.envdesc);
        break;
      case "showCampain":
        page = ShowCampain();
        break;
      case "addSession":
        page = AddSession(name: appState.envname, desc: appState.envdesc);
        break;
      default:
        throw UnimplementedError('KMP - unimplemented state $stateOfMain');
    }

    Future<void> sendGraphQLAddRequests(
        BuildContext context, String message) async {
      var url = Uri.parse('https://localhost:7777/api/gql');
      var mutation;
      if (appState.uid == -1)
        mutation = '''
    mutation {
      setRequest(Message: "${Uri.encodeComponent(message)}",
      State: "new"
      ) {
        Message
        State
      }
    }
  ''';
      else
        mutation = '''
    mutation {
      setRequest(Message: "${Uri.encodeComponent(message)}",
      State: "new", Sender: ${appState.uid}
      ) {
        Message
        State
        Sender
      }
    }
  ''';

      var body = json.encode({'mutation': mutation});
      print(body);
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data.containsKey('error')) {
            throw Error();
          } else {
            if (data['data']['setRequest']['State']) {
              throw Error();
            }
            showAlert(context, 'Запрос успешно отправлен!', 'Успех');
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          throw Error();
        }
      } catch (e) {
        // Error occurred
        print('Error: $e');
        showAlert(
            context,
            'Невозможно отправить запрос - проверьте соединение с интернетом, или сервер временно недоступен',
            'Ошибка');
      }
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              appState.setStateOfMain('tableMain');
            },
            child: Text(
              this.widget.title,
              textScaleFactor: 1.4,
            ),
          ),
        ),
        actions: [
          if (appState.uid == -1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton.filledTonal(
                onPressed: () {
                  appState.setStateOfMain('login');
                },
                icon: const Icon(Icons.face),
                iconSize: 45.0,
                tooltip: 'Войти',
              ),
            ),
          if (appState.uid != -1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton.filledTonal(
                onPressed: () {
                  appState.setStateOfMain('myRoom');
                },
                icon: const Icon(Icons.home),
                iconSize: 45.0,
                tooltip: 'Личный кабинет',
              ),
            ),
          if (appState.uid != -1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton.filledTonal(
                onPressed: () {
                  //appState.setStateOfMain('tableMain');
                  appState.setUser('', -1, '');
                  if (stateOfMain == 'myRoom') {
                    appState.setStateOfMain('tableMain');
                  }
                },
                icon: const Icon(Icons.exit_to_app),
                iconSize: 45.0,
                tooltip: 'Выйти',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            child: page,
          ),
        ),
      ),
      floatingActionButton: PopupMenuButton(
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            value: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Введите текст', // Подсказка в поле ввода
                  labelText: 'Текст', // Лейбл для поля ввода
                  prefixIcon: Icon(Icons.message), // Иконка слева от поля ввода
                  border: OutlineInputBorder(), // Вид границы поля ввода
                ),
                onChanged: (value) {
                  message = value;
                },
              ),
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Отправить'),
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 2) {
            print(message);
            sendGraphQLAddRequestRequest(context, message, appState.uid);
            //_showToast(context, message);
            message = '';
          }
        },
        icon: Icon(
          Icons.request_quote,
          size: 45,
        ),
        //color: Colors.deepPurple,
      ), //Icon(Icons.request_quote_outlined),
    );
  }
}

class TableMainPage extends StatelessWidget {
  const TableMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppPageState>();
    var theme = Theme.of(context);
    var style = theme.textTheme.headlineMedium!
        .copyWith(color: theme.colorScheme.secondary);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 1.5,
            maxWidth: MediaQuery.of(context).size.width / 2.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("ho1");
                  appState.setStateOfMain("monsters");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Бестиарий', style: style),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("ho2");
                  appState.setStateOfMain("environment");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Окружающая среда', style: style),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("ho3");
                  appState.setStateOfMain("charachterCreation");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Создание персонажа', style: style),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("ho4");
                  appState.setStateOfMain("magic");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Магия', style: style),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("ho5");
                  appState.setStateOfMain("items");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Предметы', style: style),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("ho6");
                  appState.setStateOfMain("rules");
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Прочие правила', style: style),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _showToast(BuildContext scontext, String smessage, int srid, int suid) {
  Future<void> sendGraphQLApplyRequestRequest(
      BuildContext context, int rid, int user) async {
    var url = Uri.parse('https://localhost:7777/api/gql');
    var mutation = '''
    mutation {
      setRequest(
        State: "Applying",
        resolver: { UID: $user },
        RID: $rid
      ) {
        RID
        Message
        Sender
        State
        resolver {
          UID
          Name
        }
      }
    }
  ''';

    var body = json.encode({'mutation': mutation});
    print(body);
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data.containsKey('error')) {
          throw Error();
        } else {
          var id = int.parse(data['data']['setRequest']['RID']);
          var message = data['data']['setRequest']['Message'];
          var state = data['data']['setRequest']['State'];
          var sender = data['data']['setRequest']['Sender'];
          var ruid = int.parse(data['data']['setRequest']['resolver']['UID']);
          var rname = data['data']['setRequest']['resolver']['Name'];
          showAlert(context, 'Запрос "${message}" успешно принят к выполнению!',
              'Успех');
          return;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Error();
      }
    } catch (e) {
      // Error occurred
      print('Error: $e');
      showAlert(
          context,
          'Невозможно принять запрос - проверьте соединение с интернетом',
          'Ошибка');
      return;
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      SizedBox(
        width: MediaQuery.of(scontext).size.width / 3,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Закругленные края
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  smessage,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Color(255)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await sendGraphQLApplyRequestRequest(
                          scontext, srid, suid);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(240, 255, 240, 1)),
                    child: Text('Принять'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //scaffold.hideCurrentSnackBar();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 240, 240, 1)),
                    child: Text('Пропустить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Future<void> sendGraphQLAddRequestRequest(
    BuildContext context, String message, int user) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setRequest(
        Message: "${Uri.encodeComponent(message)}",
        State: "New",
        Sender: $user
      ) {
        RID
        Message
        State
      }
    }
  ''';

  var body = json.encode({'mutation': mutation});
  print(body);
  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data.containsKey('error')) {
        throw Error();
      } else {
        var name = data['data']['setRequest']['Message'];
        print(name);
        showAlert(context, 'Запрос "$name" успешно отправлен!', 'Успех');
        return;
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Error();
    }
  } catch (e) {
    // Error occurred
    print('Error: $e');
    showAlert(
        context,
        'Невозможно отправить запрос - проверьте соединение с интернетом, или сервер временно недоступен',
        'Ошибка');
    return;
  }
}

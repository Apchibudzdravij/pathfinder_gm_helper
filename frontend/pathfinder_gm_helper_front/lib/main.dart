import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:pathfinder_gm_helper_front/content/signin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppPageState(),
      child: MaterialApp(
        title: 'Pathfinder GM Helper',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: MyHomePage(title: 'Помощник Мастера Игры Pathfinder'),
      ),
    );
  }
}

class MyAppPageState extends ChangeNotifier {
  var stateOfMain = 'tableMain';

  void setStateOfMain(String nesWtate) {
    stateOfMain = nesWtate;
    notifyListeners();
  }
}

class MyUserState extends ChangeNotifier {
  var uid = -1;
  var name = '';

  void setUser(String name, int user) {
    user = user;
    name = name;
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  void _incrementCounter() {
    print('ok');
  }

  String message = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppPageState>();
    var stateOfMain = appState.stateOfMain;
    Widget page;
    switch (stateOfMain) {
      case "tableMain":
        page = TableMainPage();
        break;
      case "login":
        page = LogIn();
        break;
      case "monsters":
        page = Placeholder();
        break;
      case "environment":
        page = Placeholder();
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
      default:
        throw UnimplementedError('KMP - unimplemented state $stateOfMain');
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
              this.title,
              textScaleFactor: 1.4,
            ),
          ),
        ),
        actions: [
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
                  print('Введен текст: $value');
                },
                onSubmitted: (value) {
                  print('Отправлен текст: $value');
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

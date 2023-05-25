import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pathfinder_gm_helper_front/main.dart';
import 'package:provider/provider.dart';
//import 'package:graphql_flutter/graphql_flutter.dart';
//import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserInfo {
  UserInfo() {
    this.Name = "";
    this.Type = "";
    this.UID = -1;
  }
  late String Name;
  late String Type;
  late int UID;
}

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  //TextEditingController _passwordController = TextEditingController();
  bool _isButtonLoginEnabled = false;
  bool _isButtonRegisterEnabled = false;

  @override
  void initState() {
    super.initState();
    textFieldController2.addListener(_checkPasswordLoginLength);
  }

  @override
  void dispose() {
    textFieldController2.dispose();
    super.dispose();
  }

  void _checkPasswordLoginLength() {
    setState(() {
      _isButtonLoginEnabled = textFieldController2.text.length >= 8;
    });
  }

  void _checkPasswordRegisterLength() {
    setState(() {
      _isButtonRegisterEnabled = ((textFieldController4.text.length >= 8) &&
          (textFieldController5.text.length >= 8) &&
          (textFieldController4.text.compareTo(textFieldController5.text) ==
              0));
    });
  }

  void registerUser() {
    if (textFieldController4.text.compareTo(textFieldController5.text) == 0) {
      var bytes = utf8.encode(textFieldController4.text);
      var hashpass = md5.convert(bytes);
      print(hashpass);
      sendGraphQLRegisterRequest(
          context, textFieldController3.text, hashpass.toString());
    }
    clearTextFieldsRegister();
  }

  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  TextEditingController textFieldController3 = TextEditingController();
  TextEditingController textFieldController4 = TextEditingController();
  TextEditingController textFieldController5 = TextEditingController();

  void clearTextFieldsLogin() {
    textFieldController1.clear();
    textFieldController2.clear();
    _checkPasswordLoginLength();
  }

  void clearTextFieldsRegister() {
    textFieldController3.clear();
    textFieldController4.clear();
    textFieldController5.clear();
    _checkPasswordRegisterLength();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    //var userProvider = Provider.of<MyUserState>(context, listen: true);
    var myUserState = context.watch<MyAppPageState>();

    Future<void> loginUser() async {
      var bytes = utf8.encode(textFieldController2.text);
      var hashpass = md5.convert(bytes);
      print(hashpass);
      var usr = await sendGraphQLLoginRequest(
          context, textFieldController1.text, hashpass.toString());
      myUserState.setUser(usr.Name, usr.UID, usr.Type);
      clearTextFieldsLogin();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 2,
        maxWidth: MediaQuery.of(context).size.width / 1.5,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Вход',
                  style: theme.textTheme.displaySmall!
                      .copyWith(color: theme.colorScheme.primary),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController1,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9а-яА-Я]{1,32}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'aka Юзернейм', // Подсказка в поле ввода
                          labelText: 'Логин',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController2,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^.{1,32}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordLoginLength();
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isButtonLoginEnabled ? loginUser : null,
                  child: Text(
                    'Войти!',
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              width: 2,
              color: theme.primaryColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Регистрация',
                  style: theme.textTheme.displaySmall!
                      .copyWith(color: theme.colorScheme.primary),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController3,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9а-яА-Я]{1,32}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'aka Юзернейм', // Подсказка в поле ввода
                          labelText: 'Логин',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController4,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^.{1,32}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordRegisterLength();
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController5,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^.{1,32}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Повторите пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordRegisterLength();
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isButtonRegisterEnabled ? registerUser : null,
                  child: Text(
                    'Начать!',
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<UserInfo> sendGraphQLLoginRequest(
    BuildContext context, String name, String password) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(name);
  print(password);

  var query = '''
    query {
      getUsers(Name: "${Uri.encodeComponent(name)}", Password: "${Uri.encodeComponent(password)}") {
        UID
        Name
        Type
      }
    }
  ''';

  var body = json.encode({'query': query});
  print(body);

  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      if (data.containsKey('error')) {
        throw Error();
      } else {
        var name = data['data']['getUsers'][0]['Name'];
        var type = data['data']['getUsers'][0]['Type'];
        var uid = int.parse(data['data']['getUsers'][0]['UID']);
        showAlert(context, 'Добро пожаловать, ${name}!', 'Успех');
        UserInfo userInfo = new UserInfo();
        userInfo.Name = name;
        userInfo.Type = type;
        userInfo.UID = uid;
        return userInfo;
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Error();
    }
  } catch (e) {
    print('Error: $e');
    showAlert(
        context,
        'Авторизация невозможна - пароль неверен, или пользователя с таким именем не существует, или проверьте соединение с интернетом',
        'Ошибка');
    UserInfo userInfo = new UserInfo();
    return userInfo;
  }
}

void sendGraphQLRegisterRequest(
    BuildContext context, String name, String password) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  var mutation = '''
    mutation {
      setUser(Name: "${Uri.encodeComponent(name)}", Password: "${Uri.encodeComponent(password)}", Type: "u") {
        UID
        Name
        Type
      }
    }
  ''';

  var body = json.encode({'mutation': mutation});

  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      if (data.containsKey('error')) {
        throw Error();
      } else {
        var name = data['data']['setUser']['Name'];
        showAlert(context, 'Пользователь ${name} успешно добавлен!', 'Успех');
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
        'Невозможно добавить пользователя - пользователь с таким именем уже существует, или проверьте соединение с интернетом',
        'Ошибка');
  }
}

void showAlert(BuildContext context, String message, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Закрыть'),
          ),
        ],
      );
    },
  );
}

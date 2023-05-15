import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

  var usrnm = '';
  var usrpss = '';
  var usrpssch = '';

  void registerUser() {
    if (usrpss == usrpssch) {
      var bytes = utf8.encode(usrpss);
      var hashpass = md5.convert(bytes);
      print(hashpass);
    }
    usrnm = '';
    usrpss = usrpssch = '';
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
                        decoration: const InputDecoration(
                          hintText: 'aka Юзернейм', // Подсказка в поле ввода
                          labelText: 'Логин',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          usrnm = value;
                          print('Введен текст: $usrnm');
                        },
                        onSubmitted: (value) {
                          print('Отправлен текст: $value');
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController2,
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordLoginLength();
                          usrpss = value;
                          print('Введен текст: $value');
                        },
                        onSubmitted: (value) {
                          print('Отправлен текст: $value');
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed:
                      _isButtonLoginEnabled ? clearTextFieldsLogin : null,
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
                              RegExp(r'[a-zA-Z0-9а-яА-Я]+[\w]*')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'aka Юзернейм', // Подсказка в поле ввода
                          labelText: 'Логин',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          usrnm = value;
                          print('Введен текст: $value');
                        },
                        onSubmitted: (value) {
                          print('Отправлен текст: $value');
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController4,
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordRegisterLength();
                          usrpss = value;
                          print('Введен текст: $value');
                        },
                        onSubmitted: (value) {
                          print('Отправлен текст: $value');
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextField(
                        controller: textFieldController5,
                        decoration: const InputDecoration(
                          hintText: '********', // Подсказка в поле ввода
                          labelText: 'Повторите пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscuringCharacter: '-',
                        obscureText: true,
                        onChanged: (value) {
                          _checkPasswordRegisterLength();
                          usrpssch = value;
                          print('Введен текст: $value');
                        },
                        onSubmitted: (value) {
                          print('Отправлен текст: $value');
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

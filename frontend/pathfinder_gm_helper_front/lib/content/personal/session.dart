import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class SessionID {
  SessionID() {
    this.GSID = -1;
    this.Name = '';
    this.Description = '';
  }
  late int GSID;
  late String Name;
  late String Description;
}

class AddSession extends StatefulWidget {
  const AddSession({super.key, required this.name, required this.desc});
  final String name;
  final String desc;

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новую сессию?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    if (textFieldController1.text != '') title = 'Изменить сессию?';
  }

  void _checkDataLength() {
    setState(() {
      _isButtonAddEnabled = textFieldController1.text.length >= 1 &&
          textFieldController2.text.length >= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<void> createSession() async {
      print('he');
      if (appState.swid == -1) {
        var resWeather = await sendGraphQLAddSessionRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.GSID != -1) {
          appState.swid = resWeather.GSID;
          print(appState.pid);
          appState.setStateOfMain('showCampain');
        }
      } else {
        var resWeather = await sendGraphQLUpdSessionRequest(
            context,
            appState.swid,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.GSID != -1) {
          appState.swid = resWeather.GSID;
          print(appState.pid);
          appState.setStateOfMain('showCampain');
        }
      }
    }

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: theme.textTheme.displayMedium!
                  .copyWith(color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Приключения начинаются..!',
              style: theme.textTheme.displaySmall!
                  .copyWith(color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextField(
                          controller: textFieldController1,
                          decoration: const InputDecoration(
                            hintText:
                                'Например, Ёж в посудной лавке', // Подсказка в поле ввода
                            labelText: 'Название сесси',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _checkDataLength();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextField(
                          controller: textFieldController2,
                          maxLines: 12,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textAlign: TextAlign.justify,
                          decoration: const InputDecoration(
                            hintText:
                                'Пишите что угодно - любую полезную информацию ;)', // Подсказка в поле ввода
                            labelText: 'Описание сессии',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _checkDataLength();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: _isButtonAddEnabled ? createSession : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return theme.colorScheme.inversePrimary;
                              }
                              return theme.colorScheme.primary;
                            },
                          ),
                        ),
                        child: Text(
                          appState.swid == -1 ? "Добавить!" : "Обновить!",
                          style: theme.textTheme.headlineMedium!
                              .copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.setStateOfMain('myRoom');
                },
                child: Text('Назад в личный кабинет',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<SessionID> sendGraphQLAddSessionRequest(
    BuildContext context,
    String name,
    String description,
    int user,
    String userName,
    int campain) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setSession(Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(description)}",
        campain: {
          GCID: $campain
        }
      ) {
        GSID
        Name
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
        var name = data['data']['setSession']['Name'];
        showAlert(context, 'Сессия ${name} успешно добавлена!', 'Успех');
        SessionID answer = SessionID();
        answer.GSID = int.parse(data['data']['setSession']['GSID']);
        return answer;
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
        'Невозможно добавить сессию - проверьте соединение с интернетом',
        'Ошибка');
    return new SessionID();
  }
}

Future<SessionID> sendGraphQLUpdSessionRequest(
    BuildContext context,
    int swid,
    String name,
    String description,
    int user,
    String userName,
    int campain) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setSession(GSID: $swid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(description)}",
        campain: {
          GCID: $campain
        }
      ) {
        GSID
        Name
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
      print(data);
      if (data.containsKey('error')) {
        throw Error();
      } else {
        var name = data['data']['setSession']['Name'];
        showAlert(context, 'Сессия ${name} успешно обновлена!', 'Успех');
        SessionID answer = new SessionID();
        answer.GSID = int.parse(data['data']['setSession']['GSID']);
        return answer;
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
        'Невозможно обновить сессию - проверьте соединение с интернетом',
        'Ошибка');
    return new SessionID();
  }
}

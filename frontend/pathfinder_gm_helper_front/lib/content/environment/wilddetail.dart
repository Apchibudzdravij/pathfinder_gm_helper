import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class WildDetailID {
  WildDetailID() {
    this.WDID = -1;
    this.Name = '';
    this.Description = '';
  }
  late int WDID;
  late String Name;
  late String Description;
}

class AddWildDetail extends StatefulWidget {
  const AddWildDetail({super.key, required this.name, required this.desc});
  final String name;
  final String desc;

  @override
  State<AddWildDetail> createState() => _AddWildDetailState();
}

class _AddWildDetailState extends State<AddWildDetail> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новую деталь дикой местности?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    if (textFieldController1.text != '')
      title = 'Изменить деталь дикой местности?';
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

    Future<void> createWildDetail() async {
      print('he');
      if (appState.swid == -1) {
        var resWeather = await sendGraphQLAddWildDetailRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.WDID != -1) {
          appState.swid = resWeather.WDID;
          print(appState.pid);
          appState.setStateOfMain('showWilderness');
        }
      } else {
        var resWeather = await sendGraphQLUpdWildDetailRequest(
            context,
            appState.swid,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.WDID != -1) {
          appState.swid = resWeather.WDID;
          print(appState.pid);
          appState.setStateOfMain('showWilderness');
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
              'Окей...',
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
                                'Например, Сосна в берёзовом лесе', // Подсказка в поле ввода
                            labelText: 'Название детали местности',
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
                                'Постарайтесь описать детали дикой местности как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание детали местности',
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
                        onPressed:
                            _isButtonAddEnabled ? createWildDetail : null,
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
                  appState.setStateOfMain('environment');
                },
                child: Text('Назад к поиску',
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

Future<WildDetailID> sendGraphQLAddWildDetailRequest(
    BuildContext context,
    String name,
    String description,
    int user,
    String userName,
    int weather) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setWildDetail(
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(escapedDescription)}",
        type: {
          WID: $weather
        }
      ) {
        WDID
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
        var name = data['data']['setWildDetail']['Name'];
        showAlert(
            context, 'Деталь ${name} успешно добавлена к местности!', 'Успех');
        WildDetailID answer = WildDetailID();
        answer.WDID = int.parse(data['data']['setWildDetail']['WDID']);
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
        'Невозможно добавить деталь дикой местности - деталь с таким названием уже существует, или проверьте соединение с интернетом',
        'Ошибка');
    return new WildDetailID();
  }
}

Future<WildDetailID> sendGraphQLUpdWildDetailRequest(
    BuildContext context,
    int swid,
    String name,
    String description,
    int user,
    String userName,
    int weather) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setWildDetail(WDID: $swid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(escapedDescription)}",
        type: {
          WID: $weather
        }
      ) {
        WDID
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
        var name = data['data']['setWildDetail']['Name'];
        showAlert(context, 'Погода ${name} успешно обновлена!', 'Успех');
        WildDetailID answer = new WildDetailID();
        answer.WDID = int.parse(data['data']['setWildDetail']['WDID']);
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
        'Невозможно обновить погоду - проверьте соединение с интернетом',
        'Ошибка');
    return new WildDetailID();
  }
}

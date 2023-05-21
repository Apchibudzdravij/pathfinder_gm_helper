import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class SubWeatherID {
  SubWeatherID() {
    this.SWID = -1;
    this.Name = '';
    this.Description = '';
    this.Source = '';
  }
  late int SWID;
  late String Name;
  late String Description;
  late String Source;
}

class AddSubWeather extends StatefulWidget {
  const AddSubWeather(
      {super.key, required this.name, required this.desc, required this.src});
  final String name;
  final String desc;
  final String src;

  @override
  State<AddSubWeather> createState() => _AddSubWeatherState();
}

class _AddSubWeatherState extends State<AddSubWeather> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  TextEditingController textFieldController3 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новый подвид погоды?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    textFieldController3.text = widget.src;
    if (textFieldController1.text != '') title = 'Изменить подвид погоды?';
  }

  void _checkDataLength() {
    setState(() {
      _isButtonAddEnabled = textFieldController1.text.length >= 1 &&
          textFieldController2.text.length >= 1 &&
          textFieldController3.text.length >= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<void> createWeather() async {
      print('he');
      if (appState.swid == -1) {
        var resWeather = await sendGraphQLAddSubWeatherRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.SWID != -1) {
          appState.swid = resWeather.SWID;
          print(appState.pid);
          appState.setStateOfMain('showWeather');
        }
      } else {
        var resWeather = await sendGraphQLUpdSubWeatherRequest(
            context,
            appState.swid,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name,
            appState.pid);
        if (resWeather.SWID != -1) {
          appState.swid = resWeather.SWID;
          print(appState.pid);
          appState.setStateOfMain('showWeather');
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
              'Ладно...',
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
                                'Например, Коралловые песнопения', // Подсказка в поле ввода
                            labelText: 'Название подвида погоды',
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
                                'Постарайтесь описать подвид погоды как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание подвида погоды',
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
                          controller: textFieldController3,
                          decoration: const InputDecoration(
                            hintText:
                                'Напишите, откуда взяли информацию', // Подсказка в поле ввода
                            labelText: 'Название ресурса',
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
                        onPressed: _isButtonAddEnabled ? createWeather : null,
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

Future<SubWeatherID> sendGraphQLAddSubWeatherRequest(
    BuildContext context,
    String name,
    String description,
    String source,
    int user,
    String userName,
    int weather) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setSubweather(Name: "${Uri.encodeComponent(name)}", Description: "${Uri.encodeComponent(description)}",
        source: {
          Name: "${Uri.encodeComponent(source)}"
        },
        useradd: {
          Name: "${Uri.encodeComponent(userName)}"
        },
        class: {
          WID: $weather
        }
      ) {
        SWID
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
        var name = data['data']['setSubweather']['Name'];
        showAlert(context, 'Подвид погоды ${name} успешно добавлен!', 'Успех');
        SubWeatherID answer = SubWeatherID();
        answer.SWID = int.parse(data['data']['setSubweather']['SWID']);
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
        'Невозможно добавить подвид погоды - подвид с таким названием уже существует, или проверьте соединение с интернетом',
        'Ошибка');
    return new SubWeatherID();
  }
}

Future<SubWeatherID> sendGraphQLUpdSubWeatherRequest(
    BuildContext context,
    int swid,
    String name,
    String description,
    String source,
    int user,
    String userName,
    int weather) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setSubweather(SWID: $swid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(description)}",
        source: {
          Name: "${Uri.encodeComponent(source)}"
        },
        useradd: {
          Name: "${Uri.encodeComponent(userName)}"
        },
        class: {
          WID: $weather
        }
      ) {
        SWID
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
        var name = data['data']['setSubweather']['Name'];
        showAlert(context, 'Погода ${name} успешно обновлена!', 'Успех');
        SubWeatherID answer = new SubWeatherID();
        answer.SWID = int.parse(data['data']['setSubweather']['SWID']);
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
    return new SubWeatherID();
  }
}

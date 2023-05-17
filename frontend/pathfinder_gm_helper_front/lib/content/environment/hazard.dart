import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class HazardID {
  HazardID() {
    this.HID = -1;
    this.Name = '';
    this.Description = '';
    this.Source = '';
  }
  late int HID;
  late String Name;
  late String Description;
  late String Source;
}

class AddHazard extends StatefulWidget {
  const AddHazard(
      {super.key, required this.name, required this.desc, required this.src});
  final String name;
  final String desc;
  final String src;

  @override
  State<AddHazard> createState() => _AddHazardState();
}

class _AddHazardState extends State<AddHazard> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  TextEditingController textFieldController3 = TextEditingController();
  var _isButtonAddEnabled = false;

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    textFieldController3.text = widget.src;
  }

  void _checkDataLength() {
    setState(() {
      _isButtonAddEnabled = textFieldController1.text.length >= 1 &&
          textFieldController2.text.length >= 1 &&
          textFieldController3.text.length >= 1;
    });
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<void> createHazard() async {
      print('he');
      var resHazard = await sendGraphQLAddHazardRequest(
          context,
          textFieldController1.text,
          textFieldController2.text,
          textFieldController3.text,
          appState.uid,
          appState.name);
      if (resHazard != -1) {
        appState.pid = resHazard.HID;
        print(appState.pid);
        appState.setStateOfMain('showHazard');
      }
    }

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Создать новую ОПАСНУЮ СРЕДУ?',
              style: theme.textTheme.displayMedium!
                  .copyWith(color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Легко!',
              style: theme.textTheme.displaySmall!
                  .copyWith(color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 7,
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
                                'Например, Холодная полутвёрдая кислота, пахнущая ромашковым чаем с имбирём', // Подсказка в поле ввода
                            labelText: 'Название опасной среды',
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
                                'Постарайтесь описать среду как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание опасной среды',
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
                        onPressed: _isButtonAddEnabled ? createHazard : null,
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
                          "Добавить!",
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
        ],
      ),
    );
  }
}

class ShowHazard extends StatefulWidget {
  const ShowHazard({super.key});

  @override
  State<ShowHazard> createState() => _ShowHazardState();
}

class _ShowHazardState extends State<ShowHazard> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50.0),
      child: Placeholder(),
    );
  }
}

Future<HazardID> sendGraphQLAddHazardRequest(BuildContext context, String name,
    String description, String source, int user, String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setHazard(Name: "$name", Description: "$escapedDescription",
        source: {
          Name: "$source"
        },
        useradd: {
          Name: "$userName"
        }
      ) {
        HID
        Name
        Description
        source {
          Name
        }
      }
    }
  ''';

  var body = json.encode({'mutation': mutation});
  print(body);
  try {
    var httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    var request = await httpClient.postUrl(url);
    request.headers.add('Content-Type', 'application/json; charset=utf-8');
    request.write(body);

    var response = await request.close();

    if (response.statusCode == 200) {
      var responseBody = await response.transform(utf8.decoder).join();
      var data = json.decode(responseBody);

      if (data.containsKey('error')) {
        throw Error();
      } else {
        var name = data['data']['setHazard']['Name'];
        showAlert(context, 'Среда ${name} успешно добавлена!', 'Успех');
        HazardID answer = new HazardID();
        answer.HID = int.parse(data['data']['setHazard']['HID']);
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
        'Невозможно добавить опасную среду - среда с таким названием уже существует, или проверьте соединение с интернетом',
        'Ошибка');
    return new HazardID();
  }
}

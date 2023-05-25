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

class CampainID {
  CampainID() {
    this.GCID = -1;
    this.Name = '';
    this.Description = '';
    this.sessions = [];
  }
  late int GCID;
  late String Name;
  late String Description;
  late List<SessionID> sessions;
}

class AddCampain extends StatefulWidget {
  const AddCampain({super.key, required this.name, required this.desc});
  final String name;
  final String desc;

  @override
  State<AddCampain> createState() => _AddCampainState();
}

class _AddCampainState extends State<AddCampain> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новую КАМПАНИЮ?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    if (textFieldController1.text != '') title = 'Изменить КАМПАНИЮ?';
  }

  void _checkDataLength() {
    setState(() {
      _isButtonAddEnabled = textFieldController1.text.length >= 1 &&
          textFieldController2.text.length >= 1;
    });
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<void> createCampain() async {
      if (appState.pid == -1) {
        var resWeather = await sendGraphQLAddCampainRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name);
        if (resWeather.GCID != -1) {
          appState.pid = resWeather.GCID;
          print(appState.pid);
          appState.setStateOfMain('showCampain');
        }
      } else {
        var resWeather = await sendGraphQLUpdCampainRequest(
            context,
            appState.pid,
            textFieldController1.text,
            textFieldController2.text,
            appState.uid,
            appState.name);
        if (resWeather.GCID != -1) {
          appState.pid = resWeather.GCID;
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
              'Вперёд к приключениям!',
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
                                'Например, Добрые сказки няни-орка', // Подсказка в поле ввода
                            labelText: 'Название кампании',
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
                                'Постарайтесь описать кампанию как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание кампании',
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
                        onPressed: _isButtonAddEnabled ? createCampain : null,
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
                          appState.pid == -1 ? "Добавить!" : "Обновить!",
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
                child: Text('Назад к личному кабинету',
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

class ShowCampain extends StatefulWidget {
  const ShowCampain({super.key});

  @override
  State<ShowCampain> createState() => _ShowCampainState();
}

class _ShowCampainState extends State<ShowCampain> {
  CampainID campain = CampainID();
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    isFirst = true;
  }

  Future<void> firstCampain(BuildContext context, int pid, int uid) async {
    this.campain = await sendGraphQLgetCampain(context, pid);
    if (isFirst) {
      setState(() {});
      isFirst = false;
    }
  }

  Future<void> deleteSession(BuildContext context, int swid) async {
    await sendGraphQLDelSessionRequest(context, swid);
    setState(() {});
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();
    firstCampain(context, appState.pid, appState.uid);

    Widget buildInputDecorator(String label, String text, int swid) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(),
                ),
                child: SelectableText(
                  text,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            if (appState.type != '')
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      appState.swid = swid;
                      appState.setStateOfMainForEnvUpdate(
                          'addSession', label, text, '');
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteSession(context, swid);
                      bool uno = true;
                      Future.delayed(Duration(milliseconds: 500), () {
                        if (uno) {
                          setState(() {});
                          uno = false;
                        }
                      });
                    },
                    icon: Icon(Icons.delete_forever),
                    iconSize: 20.0,
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.setStateOfMain('myRoom');
                  },
                  child: Text('Назад к личному кабинету',
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 1.5,
            child: Card(
              color: theme.colorScheme.onInverseSurface,
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Название кампании',
                                          border:
                                              OutlineInputBorder(), // Граница текстового поля
                                        ),
                                        child: SelectableText(this.campain.Name,
                                            style:
                                                theme.textTheme.headlineSmall!),
                                      ),
                                    ),
                                    if (appState.type != "")
                                      IconButton(
                                        onPressed: () {
                                          //updateWeather();
                                          appState.setStateOfMainForEnvUpdate(
                                              'addCampain',
                                              this.campain.Name,
                                              this.campain.Description,
                                              '');
                                        },
                                        icon: const Icon(Icons.edit),
                                        iconSize: 45.0,
                                        tooltip: 'Изменить',
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0, bottom: 10.0),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Её описание',
                                    border:
                                        OutlineInputBorder(), // Граница текстового поля
                                  ),
                                  child: SelectableText(
                                      this.campain.Description,
                                      maxLines: this.campain.sessions.isEmpty
                                          ? 16
                                          : 8,
                                      style: theme.textTheme.bodyLarge!,
                                      textAlign: TextAlign.justify),
                                ),
                              ),
                              if (!this.campain.sessions.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    height: MediaQuery.of(context).size.height /
                                        4.5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SingleChildScrollView(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              this.campain.sessions.length /
                                              3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: this
                                                  .campain
                                                  .sessions
                                                  .map((sub) =>
                                                      buildInputDecorator(
                                                          sub.Name,
                                                          sub.Description,
                                                          sub.GSID))
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (appState.type != '')
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  appState.setStateOfMain('addSession');
                },
                child: Text(
                  'Добавить сессию',
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.primary),
                ),
              ),
            )
        ],
      ),
    );
  }
}

Future<CampainID> sendGraphQLAddCampainRequest(BuildContext context,
    String name, String description, int user, String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setCampain(Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(escapedDescription)}",
        master: {
          Name: "${Uri.encodeComponent(userName)}"
        }
      ) {
        GCID
        Name
        Description
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
        var name = data['data']['setCampain']['Name'];
        showAlert(context, 'Кампания ${name} успешно добавлена!', 'Успех');
        CampainID answer = new CampainID();
        answer.GCID = int.parse(data['data']['setCampain']['GCID']);
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
        'Невозможно добавить кампанию - кампания с таким названием уже существует, или проверьте соединение с интернетом',
        'Ошибка');
    return new CampainID();
  }
}

Future<CampainID> sendGraphQLgetCampain(BuildContext context, int hid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getGameCampains(GCID: $hid) {
        GCID
        Name
        Description
        gamesessions {
          GSID
          Name
          Description
        }
      }
    }
  ''';

  var body = json.encode({
    'query': query,
    'context': {'type': 'id'}
  });
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
        var name = data['data']['getGameCampains'][0]['Name'];
        var desc = data['data']['getGameCampains'][0]['Description'];
        var gcid = int.parse(data['data']['getGameCampains'][0]['GCID']);
        CampainID haz = new CampainID();
        haz.Name = name;
        haz.Description = desc;
        haz.GCID = gcid;
        var subs = data['data']['getGameCampains'][0]['gamesessions'];
        for (var sub in subs) {
          SessionID s = SessionID();
          s.GSID = int.parse(sub['GSID']);
          s.Name = sub['Name'];
          s.Description = sub['Description'];
          haz.sessions.add(s);
        }
        return haz;
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Error();
    }
  } catch (e) {
    print('Error: $e');
    showAlert(
        context,
        'Получить данные невозможно - проверьте соединение с интернетом или свяжитесь с модераторами',
        'Ошибка');
    return new CampainID();
  }
}

Future<CampainID> sendGraphQLUpdCampainRequest(BuildContext context, int gcid,
    String name, String description, int user, String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setCampain(GCID: $gcid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(escapedDescription)}",
        master: {
          Name: "${Uri.encodeComponent(userName)}"
        }
      ) {
        GCID
        Name
        Description
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
        var name = data['data']['setCampain']['Name'];
        showAlert(context, 'Кампания ${name} успешно обновлена!', 'Успех');
        CampainID answer = new CampainID();
        answer.GCID = int.parse(data['data']['setCampain']['WID']);
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
        'Невозможно обновить кампанию - проверьте соединение с интернетом',
        'Ошибка');
    return new CampainID();
  }
}

Future<void> sendGraphQLDelSessionRequest(
    BuildContext context, int gsid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      delGameSessions(GSID: $gsid) {
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
        var name = data['data']['delGameSessions']['Name'];
        showAlert(context, 'Сессия ${name} успешно удалена!', 'Успех');
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
        'Невозможно удалить сессию - проверьте соединение с интернетом',
        'Ошибка');
    return;
  }
}

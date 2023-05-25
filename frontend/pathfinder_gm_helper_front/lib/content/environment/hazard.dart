import 'dart:convert';
import 'package:http/http.dart' as http;

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

class ShowHazard extends StatefulWidget {
  const ShowHazard({super.key});

  @override
  State<ShowHazard> createState() => _ShowHazardState();
}

class _ShowHazardState extends State<ShowHazard> {
  HazardID hazard = HazardID();
  bool isFirst = true;
  var _isStar = -1;

  @override
  void initState() {
    super.initState();
    isFirst = true;
  }

  Future<void> updateHazard(BuildContext context, int pid, int uid) async {
    this.hazard = await sendGraphQLgetHazards(context, pid);
    await checkIfStar(context, pid, uid);
    if (isFirst) {
      setState(() {
        isFirst = false;
      });
    }
  }

  Future<void> checkIfStar(BuildContext context, int pid, int uid) async {
    _isStar = await sendGraphQLgetUMHazard(context, pid, uid);
  }

  Future<void> star(BuildContext context, int pid, String name, int uid) async {
    _isStar = await sendGraphQLstarHazard(context, pid, name, uid);
    setState(() {});
  }

  Future<void> unstar(BuildContext context, int pid, int uid) async {
    await sendGraphQLunstarHazard(context, pid, uid);
    _isStar = -1;
    setState(() {});
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();
    updateHazard(context, appState.pid, appState.uid);

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.setStateOfMain('environment');
                  },
                  child: Text('Назад к поиску',
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.primary)),
                ),
                if (appState.uid != -1)
                  ElevatedButton(
                    onPressed: () {
                      //appState.setStateOfMain('environment');
                      if (_isStar == -1) {
                        star(context, appState.pid, this.hazard.Name,
                            appState.uid);
                      } else {
                        unstar(context, appState.pid, appState.uid);
                      }
                    },
                    child: _isStar == -1
                        ? Icon(Icons.star_border)
                        : Icon(Icons.star),
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
                                          labelText: 'Название опасной среды',
                                          border:
                                              OutlineInputBorder(), // Граница текстового поля
                                        ),
                                        child: SelectableText(this.hazard.Name,
                                            style:
                                                theme.textTheme.headlineSmall!),
                                      ),
                                    ),
                                    if (appState.type == "m")
                                      IconButton(
                                        onPressed: () {
                                          print('mom');
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
                                  child: SelectableText(this.hazard.Description,
                                      maxLines: 15,
                                      style: theme.textTheme.bodyLarge!,
                                      textAlign: TextAlign.justify),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ресурс',
                              border:
                                  OutlineInputBorder(), // Граница текстового поля
                            ),
                            child: SelectableText(this.hazard.Source),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<HazardID> sendGraphQLAddHazardRequest(BuildContext context, String name,
    String description, String source, int user, String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setHazard(Name: "${Uri.encodeComponent(name)}",
      Description: "${Uri.encodeComponent(description)}",
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

Future<HazardID> sendGraphQLgetHazards(BuildContext context, int hid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getHazards(HID: $hid) {
        HID
        Name
        Description
        source {
          Name
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
        var name = data['data']['getHazards'][0]['Name'];
        var desc = data['data']['getHazards'][0]['Description'];
        var hid = int.parse(data['data']['getHazards'][0]['HID']);
        var src = data['data']['getHazards'][0]['source']['Name'];
        HazardID haz = new HazardID();
        haz.Name = name;
        haz.Description = desc;
        haz.HID = hid;
        haz.Source = src;
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
    HazardID haz = new HazardID();
    return haz;
  }
}

Future<int> sendGraphQLgetUMHazard(
    BuildContext context, int hid, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getUserMemory(UID: $uid, TableID: $hid) {
        UMID
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
        if (data['data']['getUserMemory'].isEmpty) return -1;
        return int.parse(data['data']['getUserMemory'][0]['UMID']);
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
    return -1;
  }
}

Future<int> sendGraphQLstarHazard(
    BuildContext context, int hid, String name, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      setUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "hazards",
        Name: "${Uri.encodeComponent(name)}") {
        UMID
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
        return int.parse(data['data']['setUserMemory']['UMID']);
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Error();
    }
  } catch (e) {
    print('Error: $e');
    showAlert(
        context,
        'Отметить в закладки невозможно - проверьте соединение с интернетом или свяжитесь с модераторами',
        'Ошибка');
    return -1;
  }
}

Future<int> sendGraphQLunstarHazard(
    BuildContext context, int hid, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      delUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "hazards") {
        UMID
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
        return int.parse(data['data']['delUserMemory']['UMID']);
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Error();
    }
  } catch (e) {
    print('Error: $e');
    showAlert(
        context,
        'Убрать из закладок невозможно - проверьте соединение с интернетом или свяжитесь с модераторами',
        'Ошибка');
    return -1;
  }
}

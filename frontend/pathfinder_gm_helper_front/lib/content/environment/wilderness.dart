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
    this.Source = '';
  }
  late int WDID;
  late String Name;
  late String Description;
  late String Source;
}

class WildernessID {
  WildernessID() {
    this.WID = -1;
    this.Name = '';
    this.Description = '';
    this.Source = '';
    this.wildDetail = [];
  }
  late int WID;
  late String Name;
  late String Description;
  late String Source;
  late List<WildDetailID> wildDetail;
}

class AddWilderness extends StatefulWidget {
  const AddWilderness(
      {super.key, required this.name, required this.desc, required this.src});
  final String name;
  final String desc;
  final String src;

  @override
  State<AddWilderness> createState() => _AddWildernessState();
}

class _AddWildernessState extends State<AddWilderness> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  TextEditingController textFieldController3 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новую ДИКУЮ МЕСТНОСТЬ?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    textFieldController3.text = widget.src;
    if (textFieldController1.text != '') title = 'Изменить ДИКУЮ МЕСТНОСТЬ?';
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

    Future<void> createWilderness() async {
      print('he');
      if (appState.pid == -1) {
        var resWilderness = await sendGraphQLAddWildernessRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name);
        if (resWilderness.WID != -1) {
          appState.pid = resWilderness.WID;
          print(appState.pid);
          appState.setStateOfMain('showWilderness');
        }
      } else {
        var resWilderness = await sendGraphQLUpdWildernessRequest(
            context,
            appState.pid,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name);
        if (resWilderness.WID != -1) {
          appState.pid = resWilderness.WID;
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
              'Без труда!',
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
                                'Например, Область радужных единорогов', // Подсказка в поле ввода
                            labelText: 'Название дикой местности',
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
                                'Постарайтесь описать дикую местность как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание дикой местности',
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
                        onPressed:
                            _isButtonAddEnabled ? createWilderness : null,
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

class ShowWilderness extends StatefulWidget {
  const ShowWilderness({super.key});

  @override
  State<ShowWilderness> createState() => _ShowWildernessState();
}

class _ShowWildernessState extends State<ShowWilderness> {
  WildernessID wilderness = WildernessID();
  bool isFirst = true;
  var _isStar = -1;

  @override
  void initState() {
    super.initState();
    isFirst = true;
  }

  Future<void> firstWilderness(BuildContext context, int pid, int uid) async {
    this.wilderness = await sendGraphQLgetWilderness(context, pid);
    await checkIfStar(context, pid, uid);
    if (isFirst) {
      setState(() {});
      isFirst = false;
    }
  }

  Future<void> checkIfStar(BuildContext context, int pid, int uid) async {
    _isStar = await sendGraphQLgetUMWilderness(context, pid, uid);
  }

  Future<void> star(BuildContext context, int pid, String name, int uid) async {
    _isStar = await sendGraphQLstarWilderness(context, pid, name, uid);
    setState(() {});
  }

  Future<void> unstar(BuildContext context, int pid, int uid) async {
    await sendGraphQLunstarWilderness(context, pid, uid);
    _isStar = -1;
    setState(() {});
  }

  void deleteWildDetail(BuildContext context, int swid) async {
    await sendGraphQLDelWildDetailRequest(context, swid);
    setState(() {});
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();
    firstWilderness(context, appState.pid, appState.uid);

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
            if (appState.type == 'm')
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      appState.swid = swid;
                      appState.setStateOfMainForEnvUpdate(
                          'addWildDetail', label, text, this.wilderness.Source);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteWildDetail(context, swid);
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
                        star(context, appState.pid, this.wilderness.Name,
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
                                          labelText: 'Название дикой местности',
                                          border:
                                              OutlineInputBorder(), // Граница текстового поля
                                        ),
                                        child: SelectableText(
                                            this.wilderness.Name,
                                            style:
                                                theme.textTheme.headlineSmall!),
                                      ),
                                    ),
                                    if (appState.type == "m")
                                      IconButton(
                                        onPressed: () {
                                          appState.setStateOfMainForEnvUpdate(
                                              'addWilderness',
                                              this.wilderness.Name,
                                              this.wilderness.Description,
                                              this.wilderness.Source);
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
                                      this.wilderness.Description,
                                      maxLines:
                                          this.wilderness.wildDetail.isEmpty
                                              ? 15
                                              : 7,
                                      style: theme.textTheme.bodyLarge!,
                                      textAlign: TextAlign.justify),
                                ),
                              ),
                              if (!this.wilderness.wildDetail.isEmpty)
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
                                      child: Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: this
                                                .wilderness
                                                .wildDetail
                                                .map((sub) =>
                                                    buildInputDecorator(
                                                        sub.Name,
                                                        sub.Description,
                                                        sub.WDID))
                                                .toList(),
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
                            child: SelectableText(this.wilderness.Source),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (appState.type == 'm')
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  appState.setStateOfMain('addWildDetail');
                },
                child: Text('Добавить деталь об этой дикой местности'),
              ),
            )
        ],
      ),
    );
  }
}

Future<WildernessID> sendGraphQLAddWildernessRequest(
    BuildContext context,
    String name,
    String description,
    String source,
    int user,
    String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setWilderness(Name: "${Uri.encodeComponent(name)}", Description: "${Uri.encodeComponent(description)}",
        source: {
          Name: "${Uri.encodeComponent(source)}"
        },
        useradd: {
          Name: "${Uri.encodeComponent(userName)}"
        }
      ) {
        WID
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
        var name = data['data']['setWilderness']['Name'];
        showAlert(
            context, 'Дикая местность ${name} успешно добавлена!', 'Успех');
        WildernessID answer = new WildernessID();
        answer.WID = int.parse(data['data']['setWilderness']['WID']);
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
        'Невозможно добавить дикую местность - местность с таким названием уже существует, или проверьте соединение с интернетом, или сервер временно недоступен',
        'Ошибка');
    return new WildernessID();
  }
}

Future<WildernessID> sendGraphQLgetWilderness(
    BuildContext context, int hid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getWilderness(WID: $hid) {
        WID
        Name
        Description
        source {
          Name
        }
        wilddetail {
          WDID
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
        var name = data['data']['getWilderness'][0]['Name'];
        var desc = data['data']['getWilderness'][0]['Description'];
        var hid = int.parse(data['data']['getWilderness'][0]['WID']);
        var src = data['data']['getWilderness'][0]['source']['Name'];
        WildernessID haz = new WildernessID();
        haz.Name = name;
        haz.Description = desc;
        haz.WID = hid;
        haz.Source = src;
        var subs = data['data']['getWilderness'][0]['wilddetail'];
        for (var sub in subs) {
          WildDetailID s = WildDetailID();
          s.WDID = int.parse(sub['WDID']);
          s.Name = sub['Name'];
          s.Description = sub['Description'];
          haz.wildDetail.add(s);
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
    WildernessID haz = new WildernessID();
    return haz;
  }
}

Future<WildernessID> sendGraphQLUpdWildernessRequest(
    BuildContext context,
    int wid,
    String name,
    String description,
    String source,
    int user,
    String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      setWilderness(WID: $wid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(description)}",
        source: {
          Name: "${Uri.encodeComponent(source)}"
        },
        useradd: {
          Name: "${Uri.encodeComponent(userName)}"
        }
      ) {
        WID
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
        var name = data['data']['setWilderness']['Name'];
        showAlert(
            context, 'Дикая местность ${name} успешно обновлена!', 'Успех');
        WildernessID answer = new WildernessID();
        answer.WID = int.parse(data['data']['setWilderness']['WID']);
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
        'Невозможно обновить дикую местность - проверьте соединение с интернетом',
        'Ошибка');
    return new WildernessID();
  }
}

Future<void> sendGraphQLDelWildDetailRequest(
    BuildContext context, int swid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      delWildDetails(WDID: $swid) {
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
        var name = data['data']['delWildDetails']['Name'];
        showAlert(context, 'Деталь о дикой местности ${name} успешно удалена!',
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
        'Невозможно удалить деталь о дикой местности - проверьте соединение с интернетом',
        'Ошибка');
    return;
  }
}

Future<int> sendGraphQLgetUMWilderness(
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

Future<int> sendGraphQLstarWilderness(
    BuildContext context, int hid, String name, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      setUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "wilderness",
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

Future<int> sendGraphQLunstarWilderness(
    BuildContext context, int hid, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      delUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "wilderness") {
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

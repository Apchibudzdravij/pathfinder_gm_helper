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

class WeatherID {
  WeatherID() {
    this.WID = -1;
    this.Name = '';
    this.Description = '';
    this.Source = '';
    this.subWeather = [];
  }
  late int WID;
  late String Name;
  late String Description;
  late String Source;
  late List<SubWeatherID> subWeather;
}

class AddWeather extends StatefulWidget {
  const AddWeather(
      {super.key, required this.name, required this.desc, required this.src});
  final String name;
  final String desc;
  final String src;

  @override
  State<AddWeather> createState() => _AddWeatherState();
}

class _AddWeatherState extends State<AddWeather> {
  TextEditingController textFieldController1 = TextEditingController();
  TextEditingController textFieldController2 = TextEditingController();
  TextEditingController textFieldController3 = TextEditingController();
  var _isButtonAddEnabled = false;
  String title = 'Создать новую ПОГОДУ?';

  @override
  void initState() {
    super.initState();
    textFieldController1.text = widget.name;
    textFieldController2.text = widget.desc;
    textFieldController3.text = widget.src;
    if (textFieldController1.text != '') title = 'Изменить ПОГОДУ?';
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

    Future<void> createWeather() async {
      print('he');
      if (appState.pid == -1) {
        var resWeather = await sendGraphQLAddWeatherRequest(
            context,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name);
        if (resWeather.WID != -1) {
          appState.pid = resWeather.WID;
          print(appState.pid);
          appState.setStateOfMain('showWeather');
        }
      } else {
        var resWeather = await sendGraphQLUpdWeatherRequest(
            context,
            appState.pid,
            textFieldController1.text,
            textFieldController2.text,
            textFieldController3.text,
            appState.uid,
            appState.name);
        if (resWeather.WID != -1) {
          appState.pid = resWeather.WID;
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
              'Раз плюнуть!',
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
                            labelText: 'Название погоды',
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
                                'Постарайтесь описать погоду как можно более подробно ;)', // Подсказка в поле ввода
                            labelText: 'Описание погоды',
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

class ShowWeather extends StatefulWidget {
  const ShowWeather({super.key});

  @override
  State<ShowWeather> createState() => _ShowWeatherState();
}

class _ShowWeatherState extends State<ShowWeather> {
  WeatherID weather = WeatherID();
  bool isFirst = true;
  var _isStar = -1;
  @override
  void initState() {
    super.initState();
    isFirst = true;
  }

  Future<void> firstWeather(BuildContext context, int pid, int uid) async {
    this.weather = await sendGraphQLgetWeather(context, pid);
    await checkIfStar(context, pid, uid);
    if (isFirst) {
      setState(() {});
      isFirst = false;
    }
  }

  Future<void> checkIfStar(BuildContext context, int pid, int uid) async {
    _isStar = await sendGraphQLgetUMWeather(context, pid, uid);
  }

  Future<void> star(BuildContext context, int pid, String name, int uid) async {
    _isStar = await sendGraphQLstarWeather(context, pid, name, uid);
    setState(() {});
  }

  Future<void> unstar(BuildContext context, int pid, int uid) async {
    await sendGraphQLunstarWeather(context, pid, uid);
    _isStar = -1;
    setState(() {});
  }

  Future<void> deleteSubweather(BuildContext context, int swid) async {
    await sendGraphQLDelSubWeatherRequest(context, swid);
    _isStar = _isStar;
    setState(() {});
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();
    firstWeather(context, appState.pid, appState.uid);

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
                children: [
                  IconButton(
                    onPressed: () {
                      appState.swid = swid;
                      appState.setStateOfMainForEnvUpdate(
                          'addSubWeather', label, text, this.weather.Source);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteSubweather(context, swid);
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
                        star(context, appState.pid, this.weather.Name,
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
                                          labelText: 'Название погоды',
                                          border:
                                              OutlineInputBorder(), // Граница текстового поля
                                        ),
                                        child: SelectableText(this.weather.Name,
                                            style:
                                                theme.textTheme.headlineSmall!),
                                      ),
                                    ),
                                    if (appState.type == "m")
                                      IconButton(
                                        onPressed: () {
                                          //updateWeather();
                                          appState.setStateOfMainForEnvUpdate(
                                              'addWeather',
                                              this.weather.Name,
                                              this.weather.Description,
                                              this.weather.Source);
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
                                      this.weather.Description,
                                      maxLines: this.weather.subWeather.isEmpty
                                          ? 15
                                          : 7,
                                      style: theme.textTheme.bodyLarge!,
                                      textAlign: TextAlign.justify),
                                ),
                              ),
                              if (!this.weather.subWeather.isEmpty)
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
                                              this.weather.subWeather.length /
                                              8,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ListView.builder(
                                              itemCount: this
                                                  .weather
                                                  .subWeather
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                var sub = this
                                                    .weather
                                                    .subWeather[index];
                                                return buildInputDecorator(
                                                    sub.Name,
                                                    sub.Description,
                                                    sub.SWID);
                                              },
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
                            child: SelectableText(this.weather.Source),
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
                  appState.setStateOfMain('addSubWeather');
                },
                child: Text('Добавить подвид погоды'),
              ),
            )
        ],
      ),
    );
  }
}

Future<WeatherID> sendGraphQLAddWeatherRequest(
    BuildContext context,
    String name,
    String description,
    String source,
    int user,
    String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setWeather(Name: "${Uri.encodeComponent(name)}", Description: "${Uri.encodeComponent(escapedDescription)}",
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
        var name = data['data']['setWeather']['Name'];
        showAlert(context, 'Погода ${name} успешно добавлена!', 'Успех');
        WeatherID answer = new WeatherID();
        answer.WID = int.parse(data['data']['setWeather']['WID']);
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
        'Невозможно добавить погоду - погода с таким названием уже существует, или проверьте соединение с интернетом',
        'Ошибка');
    return new WeatherID();
  }
}

Future<WeatherID> sendGraphQLgetWeather(BuildContext context, int hid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getWeather(WID: $hid) {
        WID
        Name
        Description
        source {
          Name
        }
        subweather {
          SWID
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
        var name = data['data']['getWeather'][0]['Name'];
        var desc = data['data']['getWeather'][0]['Description'];
        var hid = int.parse(data['data']['getWeather'][0]['WID']);
        var src = data['data']['getWeather'][0]['source']['Name'];
        WeatherID haz = new WeatherID();
        haz.Name = name;
        haz.Description = desc;
        haz.WID = hid;
        haz.Source = src;
        var subs = data['data']['getWeather'][0]['subweather'];
        for (var sub in subs) {
          SubWeatherID s = SubWeatherID();
          s.SWID = int.parse(sub['SWID']);
          s.Name = sub['Name'];
          s.Description = sub['Description'];
          haz.subWeather.add(s);
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
    WeatherID haz = new WeatherID();
    return haz;
  }
}

Future<WeatherID> sendGraphQLUpdWeatherRequest(
    BuildContext context,
    int wid,
    String name,
    String description,
    String source,
    int user,
    String userName) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  String escapedDescription = description.replaceAll('\n', '\\n');
  var mutation = '''
    mutation {
      setWeather(WID: $wid,
        Name: "${Uri.encodeComponent(name)}",
        Description: "${Uri.encodeComponent(escapedDescription)}",
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
        var name = data['data']['setWeather']['Name'];
        showAlert(context, 'Погода ${name} успешно обновлена!', 'Успех');
        WeatherID answer = new WeatherID();
        answer.WID = int.parse(data['data']['setWeather']['WID']);
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
    return new WeatherID();
  }
}

Future<void> sendGraphQLDelSubWeatherRequest(
    BuildContext context, int swid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');
  var mutation = '''
    mutation {
      delSubweather(SWID: $swid) {
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
        var name = data['data']['delSubweather']['Name'];
        showAlert(context, 'Подвид погоды ${name} успешно удалён!', 'Успех');
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
        'Невозможно удалить подвид погоды - проверьте соединение с интернетом',
        'Ошибка');
    return;
  }
}

Future<int> sendGraphQLgetUMWeather(
    BuildContext context, int hid, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var query = '''
    query {
      getUserMemory(UID: $uid, TableID: $hid, TableName: "weather") {
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

Future<int> sendGraphQLstarWeather(
    BuildContext context, int hid, String name, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      setUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "weather",
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

Future<int> sendGraphQLunstarWeather(
    BuildContext context, int hid, int uid) async {
  var url = Uri.parse('https://localhost:7777/api/gql');

  print(hid);

  var mutation = '''
    mutation {
      delUserMemory(UID: $uid,
        TableID: $hid,
        TableName: "weather") {
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

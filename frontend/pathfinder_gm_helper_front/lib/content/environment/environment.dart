import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class EnvironmentApp extends StatefulWidget {
  const EnvironmentApp({super.key});

  @override
  State<EnvironmentApp> createState() => _EnvironmentAppState();
}

class _EnvironmentAppState extends State<EnvironmentApp> {
  List<Widget> weatherList = [];
  List<Widget> hazardList = [];
  List<Widget> wilderList = [];

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<List<Widget>> sendGraphQLfindManyHazards(
        BuildContext context, String name) async {
      var url = Uri.parse('https://localhost:7777/api/gql');
      //var nm = json.encode(name);
      print(name);

      var query = '''
    query {
      getHazards(Name: "${Uri.encodeComponent(name)}") {
        HID
        Name
      }
    }
  ''';

      var body = json.encode({
        'query': query,
        'context': {'type': 'name'}
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
            if (data['data']['getHazards'].isEmpty) {
              print('Список getHazards пустой');
              return [];
            } else {
              var hazards = data['data']['getHazards'];
              var answer = <Widget>[];
              for (var hazard in hazards) {
                var hid = hazard['HID'];
                var hname = hazard['Name'];
                var hazardWidget = Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      appState.pid = int.parse(hid);
                      appState.setStateOfMain('showHazard');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.snowing),
                        Text(hname, overflow: TextOverflow.clip),
                        Icon(Icons.snowing),
                      ],
                    ),
                  ),
                );
                answer.add(hazardWidget);
              }
              print(answer);
              return answer;
            }
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          throw Error();
        }
      } catch (e) {
        print('Error: $e');
        showAlert(
            context,
            'Поиск невозможен - проверьте соединение с интернетом и символы на допустимость',
            'Ошибка');
        return [];
      }
    }

    Future<List<Widget>> sendGraphQLfindManyWeather(
        BuildContext context, String name) async {
      var url = Uri.parse('https://localhost:7777/api/gql');
      //var nm = json.encode(name);
      print(name);

      var query = '''
    query {
      getWeather(Name: "${Uri.encodeComponent(name)}") {
        WID
        Name
      }
    }
  ''';

      var body = json.encode({
        'query': query,
        'context': {'type': 'name'}
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
            if (data['data']['getWeather'].isEmpty) {
              print('Список getWeather пустой');
              return [];
            } else {
              var hazards = data['data']['getWeather'];
              var answer = <Widget>[];
              for (var hazard in hazards) {
                var wid = hazard['WID'];
                var wname = hazard['Name'];
                var weatherWidget = Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      appState.pid = int.parse(wid);
                      appState.setStateOfMain('showWeather');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.cloud),
                        Text(wname, overflow: TextOverflow.clip),
                        Icon(Icons.cloud),
                      ],
                    ),
                  ),
                );
                answer.add(weatherWidget);
              }
              print(answer);
              return answer;
            }
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          throw Error();
        }
      } catch (e) {
        print('Error: $e');
        /*showAlert(
            context,
            'Поиск невозможен - проверьте соединение с интернетом и символы на допустимость',
            'Ошибка');*/
        return [];
      }
    }

    Future<List<Widget>> sendGraphQLfindManyWilderness(
        BuildContext context, String name) async {
      var url = Uri.parse('https://localhost:7777/api/gql');
      //var nm = json.encode(name);
      print(name);

      var query = '''
    query {
      getWilderness(Name: "${Uri.encodeComponent(name)}") {
        WID
        Name
      }
    }
  ''';

      var body = json.encode({
        'query': query,
        'context': {'type': 'name'}
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
            if (data['data']['getWilderness'].isEmpty) {
              print('Список getWilderness пустой');
              return [];
            } else {
              var hazards = data['data']['getWilderness'];
              var answer = <Widget>[];
              for (var hazard in hazards) {
                var wid = hazard['WID'];
                var wname = hazard['Name'];
                var weatherWidget = Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      appState.pid = int.parse(wid);
                      appState.setStateOfMain('showWilderness');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.landscape),
                        Text(wname, overflow: TextOverflow.clip),
                        Icon(Icons.landscape),
                      ],
                    ),
                  ),
                );
                answer.add(weatherWidget);
              }
              print(answer);
              return answer;
            }
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          throw Error();
        }
      } catch (e) {
        print('Error: $e');
        /*showAlert(
            context,
            'Поиск невозможен - проверьте соединение с интернетом и символы на допустимость',
            'Ошибка');*/
        return [];
      }
    }

    Future<void> setHazardList(BuildContext context, String val) async {
      hazardList = await sendGraphQLfindManyHazards(context, val);
    }

    Future<void> setWeatherList(BuildContext context, String val) async {
      weatherList = await sendGraphQLfindManyWeather(context, val);
    }

    Future<void> setWildernessList(BuildContext context, String val) async {
      wilderList = await sendGraphQLfindManyWilderness(context, val);
    }

    Future<void> find(String val) async {
      await setHazardList(context, val);
      await setWeatherList(context, val);
      await setWildernessList(context, val);
      setState(() {});
    }

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Например, темнота', // Подсказка в поле ввода
              labelText: 'Введите поисковый запрос',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              if (value.length > 0) {
                print('Отправлен текст: $value');
                find(value);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 1.5,
                maxWidth: MediaQuery.of(context).size.width / 1.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Погода',
                              style: theme.textTheme.headlineLarge!
                                  .copyWith(color: theme.colorScheme.primary),
                              textAlign: TextAlign.center,
                            ),
                            if (appState.uid != -1 && appState.type == 'm')
                              IconButton(
                                  color: theme.primaryColor,
                                  onPressed: () {
                                    appState.pid = -1;
                                    appState.setStateOfMain("addWeather");
                                  },
                                  icon: Icon(Icons.add_circle_outline))
                          ],
                        ),
                        Column(
                          children: weatherList,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.25,
                    width: 2,
                    color: theme.focusColor,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Опасная\nсреда',
                              style: theme.textTheme.headlineLarge!
                                  .copyWith(color: theme.colorScheme.primary),
                              textAlign: TextAlign.center,
                            ),
                            if (appState.uid != -1 && appState.type == 'm')
                              IconButton(
                                  color: theme.primaryColor,
                                  onPressed: () {
                                    appState.pid = -1;
                                    appState.setStateOfMain("addHazard");
                                  },
                                  icon: Icon(Icons.add_circle_outline))
                          ],
                        ),
                        Column(
                          children: hazardList,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.25,
                    width: 2,
                    color: theme.focusColor,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Дикая\nместность',
                              style: theme.textTheme.headlineLarge!
                                  .copyWith(color: theme.colorScheme.primary),
                              textAlign: TextAlign.center,
                            ),
                            if (appState.uid != -1 && appState.type == 'm')
                              IconButton(
                                color: theme.primaryColor,
                                onPressed: () {
                                  appState.pid = -1;
                                  appState.setStateOfMain("addWilderness");
                                },
                                icon: Icon(Icons.add_circle_outline),
                              ),
                          ],
                        ),
                        Column(
                          children: wilderList,
                        ),
                      ],
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

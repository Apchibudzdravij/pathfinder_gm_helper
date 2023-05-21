import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pathfinder_gm_helper_front/content/environment/hazard.dart';
import 'package:pathfinder_gm_helper_front/content/environment/weather.dart';
import 'package:pathfinder_gm_helper_front/content/environment/wilderness.dart';
import 'package:pathfinder_gm_helper_front/content/personal/requestWidget.dart';
import 'package:pathfinder_gm_helper_front/content/signin.dart';
import 'package:pathfinder_gm_helper_front/main.dart';
import 'package:provider/provider.dart';

class PersonalArea extends StatefulWidget {
  const PersonalArea({super.key});

  @override
  State<PersonalArea> createState() => _PersonalAreaState();
}

class _PersonalAreaState extends State<PersonalArea> {
  List<Widget> marks = [];
  List<Widget> campains = [];
  List<Widget> requests = [];
  bool uno = true;

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    Future<void> unstar(
        BuildContext context, int pid, int uid, String type) async {
      switch (type) {
        case 'hazards':
          await sendGraphQLunstarHazard(context, pid, uid);
          break;
        case 'weather':
          await sendGraphQLunstarWeather(context, pid, uid);
          break;
        case 'wilderness':
          await sendGraphQLunstarWilderness(context, pid, uid);
          break;
      }
      uno = true;
    }

    Future<List<Widget>> sendGraphQLfindManyRequests(
        BuildContext context) async {
      var url = Uri.parse('https://localhost:7777/api/gql');

      var query = '''
    query {
      getRequests {
        RID
        Message
        Sender
        State
        resolver {
          UID
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
            if (data['data']['getRequests'].isEmpty) {
              print('Список getRequests пустой');
              return [];
            } else {
              var reqs = data['data']['getRequests'];
              var answer = <Widget>[];
              for (var req in reqs) {
                int rid = int.parse(req['RID']);
                String rstate = req['State'];
                String rmessage = req['Message'];
                int rsender = req['Sender'];
                int ruid = -1;
                String rname = '';
                if (req['resolver'] != null) {
                  ruid = int.parse(req['resolver']['UID']);
                  rname = req['resolver']['Name'];
                }
                var memoryWidget = RequestWidget(
                    state: rstate,
                    ruid: ruid,
                    rname: rname,
                    id: rid,
                    message: rmessage,
                    sender: rsender);
                answer.add(memoryWidget);
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
            'Получить запросы невозможно - проверьте соединение с интернетом',
            'Ошибка');
        return [];
      }
    }

    Future<List<Widget>> sendGraphQLfindManyMarks(
        BuildContext context, int uid) async {
      var url = Uri.parse('https://localhost:7777/api/gql');

      var query = '''
    query {
      getUserMemory(UID: $uid) {
        TableID
        TableName
        Name
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
            if (data['data']['getUserMemory'].isEmpty) {
              print('Список getUserMemory пустой');
              return [];
            } else {
              var memories = data['data']['getUserMemory'];
              var answer = <Widget>[];
              for (var memory in memories) {
                var tid = memory['TableID'];
                var tname = memory['TableName'];
                var name = memory['Name'];
                var memoryWidget = Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            unstar(context, tid, appState.uid, tname);
                            setState(() {});
                          },
                          icon: Icon(Icons.delete_forever),
                          iconSize: 20.0,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          onPressed: () {
                            appState.pid = tid;
                            switch (tname) {
                              case 'weather':
                                appState.setStateOfMain('showWeather');
                                break;
                              case 'wilderness':
                                appState.setStateOfMain('showWilderness');
                                break;
                              case 'hazards':
                                appState.setStateOfMain('showHazard');
                                break;
                              default:
                                throw Error();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              tname == 'hazards'
                                  ? Icon(Icons.snowing)
                                  : tname == 'weather'
                                      ? Icon(Icons.cloud)
                                      :
                                      //tname == 'wilderness' ?
                                      Icon(Icons.landscape),
                              Text(name, overflow: TextOverflow.clip),
                              tname == 'hazards'
                                  ? Icon(Icons.snowing)
                                  : tname == 'weather'
                                      ? Icon(Icons.cloud)
                                      :
                                      //tname == 'wilderness' ?
                                      Icon(Icons.landscape),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                answer.add(memoryWidget);
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
            'Получение закладок невозможно - проверьте соединение с интернетом, или сервер недоступен',
            'Ошибка');
        return [];
      }
    }

    Future<List<Widget>> sendGraphQLfindManyCampains(
        BuildContext context, int uid) async {
      var url = Uri.parse('https://localhost:7777/api/gql');

      var query = '''
    query {
      getGameCampains(Master: $uid) {
        GCID
        Name
      }
    }
  ''';

      var body = json.encode({
        'query': query,
        'context': {'type': 'user'}
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
            if (data['data']['getGameCampains'].isEmpty) {
              print('Список getUserMemory пустой');
              return [];
            } else {
              var campains = data['data']['getGameCampains'];
              var answer = <Widget>[];
              for (var campain in campains) {
                var tid = campain['GCID'];
                var name = campain['Name'];
                var campainWidget = Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        appState.pid = int.parse(tid);
                        appState.setStateOfMain('showCampain');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.map),
                          Text(name, overflow: TextOverflow.clip),
                          Icon(Icons.map),
                        ],
                      ),
                    ),
                  ),
                );
                answer.add(campainWidget);
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
            'Получение кампаний невозможно - проверьте соединение с интернетом, или сервер недоступен',
            'Ошибка');
        return [];
      }
    }

    Future<void> findRequests() async {
      requests = await sendGraphQLfindManyRequests(context);
      setState(() {
        requests = requests;
      });
    }

    Future<void> setList(BuildContext context, int val) async {
      marks = await sendGraphQLfindManyMarks(context, val);
      campains = await sendGraphQLfindManyCampains(context, appState.uid);

      requests = await sendGraphQLfindManyRequests(context);
      //await findRequests();

      Future.delayed(Duration(milliseconds: 500), () {
        if (uno) {
          setState(() {});
          uno = false;
        }
      });
    }

    setList(context, appState.uid);

    return Container(
      padding: EdgeInsets.all(25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Закладки',
                    style: theme.textTheme.displaySmall!
                        .copyWith(color: theme.colorScheme.primary),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: marks,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Кампании',
                          style: theme.textTheme.displaySmall!
                              .copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: campains, //campains
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            appState.pid = -1;
                            appState.setStateOfMain("addCampain");
                          },
                          child: Text(
                            'Добавить кампанию',
                            style: theme.textTheme.headlineSmall!
                                .copyWith(color: theme.colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (appState.type == 'm')
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Заявки',
                            style: theme.textTheme.displaySmall!
                                .copyWith(color: theme.colorScheme.primary),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: requests, //requests
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

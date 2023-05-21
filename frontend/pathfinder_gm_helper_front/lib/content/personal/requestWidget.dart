import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../signin.dart';

class RequestWidget extends StatefulWidget {
  const RequestWidget(
      {super.key,
      required this.state,
      required this.ruid,
      required this.rname,
      required this.id,
      required this.message,
      required this.sender});
  final String state;
  final int ruid;
  final String rname;
  final int id;
  final String message;
  final int sender;

  @override
  State<RequestWidget> createState() => _RequestWidgetState();
}

class _RequestWidgetState extends State<RequestWidget> {
  late String _state;
  late int _ruid;
  late String _rname;
  late int _id;
  late String _message;
  late int _sender;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _state = widget.state;
    _ruid = widget.ruid;
    _rname = widget.rname;
    _id = widget.id;
    _message = widget.message;
    _sender = widget.sender;
  }

  void setStateWithParams(
      String state, int rid, String rname, int id, String message, int sender) {
    setState(() {
      _state = state;
      _ruid = rid;
      _rname = rname;
      _id = id;
      _message = message;
      _sender = sender;
    });
  }

  void dropMyself() {
    setState(() {
      _isDeleted = true;
    });
  }

  Future<void> sendGraphQLApplyRequestRequest(
      BuildContext context, int rid, int user) async {
    var url = Uri.parse('https://localhost:7777/api/gql');
    var mutation = '''
    mutation {
      setRequest(
        State: "Applying",
        resolver: { UID: $user },
        RID: $rid
      ) {
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
          var id = int.parse(data['data']['setRequest']['RID']);
          var message = data['data']['setRequest']['Message'];
          var state = data['data']['setRequest']['State'];
          var sender = data['data']['setRequest']['Sender'];
          var ruid = int.parse(data['data']['setRequest']['resolver']['UID']);
          var rname = data['data']['setRequest']['resolver']['Name'];
          showAlert(context, 'Запрос "${message}" успешно принят к выполнению!',
              'Успех');
          setStateWithParams(state, ruid, rname, id, message, sender);
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
          'Невозможно принять запрос - проверьте соединение с интернетом',
          'Ошибка');
      return;
    }
  }

  Future<void> sendGraphQLDelRequestRequest(
      BuildContext context, int rid, int succ) async {
    var url = Uri.parse('https://localhost:7777/api/gql');
    var mutation = '''
    mutation {
      delRequest(RID: $rid) {
        RID
        Message
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
          var name = data['data']['delRequest']['Message'];
          if (succ == 1)
            showAlert(context, 'Запрос "${name}" успешно отклонён!', 'Успех');
          else
            showAlert(context, 'Запрос "${name}" успешно выполнен!', 'Успех');
          dropMyself();
          return;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Error();
      }
    } catch (e) {
      // Error occurred
      print('Error: $e');
      if (succ == 1)
        showAlert(
            context,
            'Невозможно отклонить запрос - проверьте соединение с интернетом',
            'Ошибка');
      else
        showAlert(
            context,
            'Невозможно выполнить запрос - проверьте соединение с интернетом',
            'Ошибка');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) {
      return Container();
    }
    var theme = Theme.of(context);
    var appState = context.watch<MyAppPageState>();

    return SizedBox(
      height: 110,
      width: 300,
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: Padding(
          padding: EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8.0),
              color: _ruid == -1
                  ? Color.fromRGBO(255, 240, 240, 1)
                  : _ruid == appState.uid
                      ? Color.fromRGBO(240, 255, 240, 1)
                      : theme.colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _message,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (_ruid == -1)
                      IconButton(
                        onPressed: () async {
                          await sendGraphQLApplyRequestRequest(
                              context, _id, appState.uid);
                        },
                        icon: Icon(Icons.approval),
                      ),
                    if ((_ruid != -1) && (_ruid == appState.uid))
                      IconButton(
                        onPressed: () async {
                          await sendGraphQLDelRequestRequest(context, _id, 0);
                        },
                        icon: Icon(Icons.done_outline),
                      ),
                    if ((_ruid == -1) || (_ruid == appState.uid))
                      IconButton(
                        onPressed: () async {
                          await sendGraphQLDelRequestRequest(context, _id, 1);
                        },
                        icon: Icon(Icons.delete_forever),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

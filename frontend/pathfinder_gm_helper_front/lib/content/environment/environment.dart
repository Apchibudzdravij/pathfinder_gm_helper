import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

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
            onChanged: (value) {
              print('Введен текст: $value');
            },
            onSubmitted: (value) {
              print('Отправлен текст: $value');
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
                                  onPressed: () {},
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
                                onPressed: () {},
                                icon: Icon(Icons.add_circle_outline),
                              ),
                            Column(
                              children: wilderList,
                            ),
                          ],
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

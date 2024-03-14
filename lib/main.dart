import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app_data.dart';
import 'game.dart';
import 'game_overlay.dart';
import 'layout_login.dart';
import 'layout_players.dart';

void main() async {
  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    print(e);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MyApp(),
    ),
  );
}

void showWindow(_) async {
  windowManager.setMinimumSize(const Size(0, 0));
  await windowManager.setTitle('Flappy Bird Battle Royal');
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget _setLayout(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    switch (appData.connectionStatus) {
      case ConnectionStatus.connecting:
        return const LayoutLogin();
      case ConnectionStatus.waiting:
        return const LayoutPlayers();
      case ConnectionStatus.connected:
        return appData.playerMap.isNotEmpty
            ? GameWidget<FlappyEmber>.controlled(
                gameFactory: () => FlappyEmber(appData),
                overlayBuilderMap: {
                  'GameOverlay': (_, game) => GameOverlay(game: game),
                },
              )
            : const LayoutLogin();
      default:
        return const LayoutLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird Battle Royal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _setLayout(context),
    );
  }
}

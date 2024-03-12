import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'game.dart';
import 'layout_login.dart';
import 'layout_players.dart';

Future<void> main() async {

  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    print(e);
  }

  runApp(MyApp());
}

void showWindow(_) async {
  windowManager.setMinimumSize(const Size(0, 0));
  await windowManager.setTitle('FBBR');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBBR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LayoutLogin(),
        '/players': (context) => const LayoutPlayers(),
        '/game': (context) => GameWidget(game: FlappyEmber()..context = context),
      },
    );
  }
}

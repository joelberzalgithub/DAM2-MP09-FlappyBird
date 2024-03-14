import 'dart:async';

import 'package:flappy_ember/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutPlayers extends StatefulWidget {
  const LayoutPlayers({Key? key}) : super(key: key);

  @override
  LayoutPlayersState createState() => LayoutPlayersState();
}

class LayoutPlayersState extends State<LayoutPlayers> {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    appData.startTimer();

    return Scaffold(
      body: OverflowBox(
        minHeight: 600,
        minWidth: 600,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/parallax/bg_sky.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 125.0,
                  bottom: 125.0,
                ),
                child: Container(
                    width: 500,
                    height: 400,
                    margin: const EdgeInsets.symmetric(horizontal: 50.0),
                    padding: const EdgeInsets.all(50.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ListView(
                      children: appData.playerMap.entries.map((entry) {
                        final String playerId = entry.key;
                        final Player player = entry.value;
                        return ListTile(
                          title: Text(player.name),
                        );
                      }).toList(),
                    ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

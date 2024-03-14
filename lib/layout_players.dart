import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutPlayers extends StatefulWidget {
  const LayoutPlayers({Key? key}) : super(key: key);

  @override
  LayoutPlayersState createState() => LayoutPlayersState();
}

class LayoutPlayersState extends State<LayoutPlayers> {
  late String counter;
  late int time;

  @override
  void initState() {
    super.initState();
    counter = '';
    time = 3;
    countTime();
  }

  void countTime() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (time < 0) {
          Provider.of<AppData>(context, listen: false).connectionStatus = ConnectionStatus.connected;
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          Provider.of<AppData>(context, listen: false).notifyListeners();
          return;
        } else {
          if (time < 1) {
            counter = 'GO!';
          } else {
            counter = time.toString();
          }
          time--;
          countTime();
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: appData.playerMap.entries.map((entry) {
                            // ignore: unused_local_variable
                            final playerId = entry.key;
                            final player = entry.value;
                            return ListTile(
                              title: Text(player.name),
                            );
                          }).toList(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          counter,
                          style: const TextStyle(
                            fontSize: 35.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

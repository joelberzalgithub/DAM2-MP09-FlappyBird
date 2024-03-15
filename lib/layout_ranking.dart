import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutRanking extends StatefulWidget {
  const LayoutRanking({Key? key}) : super(key: key);

  @override
  LayoutRankingState createState() => LayoutRankingState();
}

class LayoutRankingState extends State<LayoutRanking> {
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fi de la partida!', style: TextStyle(fontSize: 25),),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView(
                          children: appData.playerMap.entries.map((entry) {
                            // ignore: unused_local_variable
                            final playerId = entry.key;
                            final player = entry.value;
                            return ListTile(
                              title: Row(
                                children: [
                                  Text('${player.name}  '),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 10,
                                        child: LinearProgressIndicator(
                                          value: player.score / appData.getHighScore(),
                                          backgroundColor: Colors.transparent,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text('  ${player.score}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            appData.playerMap = {};
                            appData.changeConnectionStatus(ConnectionStatus.disconnected);
                          },
                          child: const Text("Tornar a la pantalla d'inici"),
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

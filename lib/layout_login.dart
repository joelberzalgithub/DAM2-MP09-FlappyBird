import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutLogin extends StatefulWidget {
  const LayoutLogin({Key? key}) : super(key: key);

  @override
  LayoutLoginState createState() => LayoutLoginState();
}

class LayoutLoginState extends State<LayoutLogin> {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    ipController.text = appData.ip;
    portController.text = appData.port;

    return Scaffold(
      body: OverflowBox(
        minHeight: 600,
        minWidth: 600,
        child: Stack(
          fit: StackFit.expand,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('Flappy Bird multijugador: FBBR',
                          style: TextStyle(fontSize: 25),),
                      TextFormField(
                        controller: ipController,
                        decoration: const InputDecoration(labelText: 'IP'),
                      ),
                      TextFormField(
                        controller: portController,
                        decoration: const InputDecoration(labelText: 'Port'),
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Nom del jugador'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // appData.connect();
                          if (ipController.text != '' &&
                              portController.text != '' &&
                              nameController.text != '') {
                            appData.name = nameController.text;
                            appData.isGameOver = false;
                            appData.connectToServer();
                          }
                        },
                        child: const Text('Iniciar partida'),
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

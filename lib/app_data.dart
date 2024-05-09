import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

import 'game.dart';
import 'player.dart';

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  waiting,
  connected
}

class AppData with ChangeNotifier {
  String ip = 'localhost';
  String port = '8888';
  String name = '';
  String id = '';
  late String counter = '';
  late int time = 3;
  bool repaint = true;
  Map<String, Player> playerMap = {};
  Timer? timer;
  int alivePlayers = 0;
  bool? isNewBoxBottom;
  int? newBoxHeight;
  bool isGameOver = false;

  IOWebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String messages = '';

  AppData() {
    _getLocalIpAddress();
  }

  void _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      if (interfaces.isNotEmpty) {
        final interface = interfaces.first;
        final address = interface.addresses.first;
        ip = address.address;
        notifyListeners();
      }
    } catch (e) {
      print("Can't get local IP address : $e");
    }
  }

  Future<void> connectToServer() async {
    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));

    _socketClient = IOWebSocketChannel.connect('ws://$ip:$port');
    _socketClient!.stream.listen(
      (message) {
        final Map<String, dynamic> data = jsonDecode(message);

        switch (data['type']) {
          case 'salutation':
            connectionStatus = ConnectionStatus.waiting;
            sendMessage(
              'join',
              'room',
              name,
              'nickname',
              name,
            );
            break;

          case 'join':
            if (playerMap.isEmpty) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_blue.png'));
            } else if (playerMap.length == 1) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_red.png'));
            } else if (playerMap.length == 2) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_green.png'));
            } else {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_orange.png'));
            }

            break;

          case 'joined':
            id = data['value'];
            name = data['name'];

            if (playerMap.containsKey(id)) {
              playerMap[id]!.name = name;
            } else {
              playerMap.putIfAbsent(
                  id, () => Player(data['name'], true, 'bird_blue.png'));
            }

            connectionStatus = ConnectionStatus.waiting;
            notifyListeners();
            break;

          case 'move':
            playerMap[data['id']]?.position.y = (data['y']) as double;
            playerMap[data['id']]?.score = ((data['score']) as num).round();
            break;

          case 'start':
            countTime();
            //connectionStatus = ConnectionStatus.connected;
            notifyListeners();
            break;

          case 'player':
            if (data['name'] == name) {
              break;
            }
            /*if (playerMap.isEmpty) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_blue.png'));
            } else */if (playerMap.length == 1) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_red.png'));
            } else if (playerMap.length == 2) {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_green.png'));
            } else {
              playerMap.putIfAbsent(data['value'],
                  () => Player(data['name'], false, 'bird_orange.png'));
            }

            break;

          case 'box':
            print(data);
            isNewBoxBottom = data['isBottom'];
            newBoxHeight = data['height'];
            break;

          case 'victory':
            print(data);
            isGameOver = true;
            notifyListeners();
            break;

          default:
            messages += "Message from '${data['from']}': ${data['value']}\n";
            break;
        }

        notifyListeners();
      },
      onError: (error) {
        connectionStatus = ConnectionStatus.disconnected;
        notifyListeners();
      },
      onDone: () {
        //sendMessage('connection', 'status', 'disconnection', 'UUID', uuid);
        connectionStatus = ConnectionStatus.disconnected;
        notifyListeners();
      },
    );
  }

  FlappyEmber buildGame() {
    return FlappyEmber(this);
  }

  void sendMessage(
    String typeValue,
    String key1,
    Object value1,
    String key2,
    Object value2,
  ) {
    final message = {'type': typeValue, key1: value1, key2: value2};
    _socketClient!.sink.add(jsonEncode(message));
  }

  void sendCustomMessage(Map<String, dynamic> msg) {
    _socketClient!.sink.add(jsonEncode(msg));
  }

  void disconnectFromServer() async {
    //sendMessage('connection', 'status', 'disconnection', 'UUID', uuid);
    connectionStatus = ConnectionStatus.disconnected;
    _socketClient?.sink.close();

    notifyListeners();
  }

  void playAgain() async {
    //sendMessage('play again', 'UUID', uuid, '', '');
    connectionStatus = ConnectionStatus.waiting;
    notifyListeners();
  }

  void forceNotifyListeners() {
    notifyListeners();
  }

  void changeConnectionStatus(ConnectionStatus status) {
    connectionStatus = status;
    notifyListeners();
  }

  void startTimer() {
    Timer(const Duration(seconds: 5), () {
      connectionStatus = ConnectionStatus.connected;
      notifyListeners();
    });
  }

  void countTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (time < 0) {
        time = 3;
        counter = '';
        connectionStatus = ConnectionStatus.connected;
        notifyListeners();
        return;
      } else {
        if (time < 1) {
          counter = 'GO!';
        } else {
          counter = time.toString();
        }
        time--;
        notifyListeners();
        countTime();
      }
    });
  }

  void setScore(String playerId, int score) {
    if (playerMap.containsKey(playerId)) {
      playerMap[playerId]!.score = score;
      notifyListeners();
    }
  }

  int getHighScore() {
    var highScore = -1;
    playerMap.forEach((key, value) {
      if (value.score > highScore) {
        highScore = value.score;
      }
    });
    return highScore;
  }

  void initAlivePlayers() {
    alivePlayers = playerMap.length;
  }

  void sortPlayerMap() {
    playerMap = Map.fromEntries(
      playerMap.entries.toList()
        // ignore: avoid_dynamic_calls
        ..sort((a, b) => (b.value.score).compareTo(a.value.score)),
    );
    notifyListeners();
  }

}

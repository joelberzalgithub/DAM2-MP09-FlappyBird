import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'app_data.dart';
import 'box_stack.dart';
import 'ground.dart';
import 'player.dart';
import 'sky.dart';

class FlappyEmber extends FlameGame with TapDetector, HasCollisionDetection {
  late AppData appData;
  List<Player> players = [];
  Map<String, dynamic> playerMap = {};

  FlappyEmber(this.appData);

  final _random = Random();
  double speed = 200;
  double _timeSinceBox = 0;
  final _boxInterval = 2;
  late Player player;
  bool _gameOver = false;
  int _time = 0;

  @override
  Future<void> onLoad() async {

    await addAll([
      Sky(),
      Ground(),
      player =  appData.playerMap[appData.id]?? Player('xd', false, 'bird_orange.png'),
      ScreenHitbox(),
    ]);

    appData.playerMap.forEach((key, value) {if (!value.local) {
      add(value);
    }});
    countTime();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceBox += dt;
    speed += 10 * dt;
    /*
    if (_timeSinceBox > _boxInterval) {
      add(BoxStack(isBottom: _random.nextBool()));
      _timeSinceBox = 0;
    }
    */

    bool? isBottom = appData.isNewBoxBottom;
    int? boxHeight = appData.newBoxHeight;

    if (isBottom != null && boxHeight != null) {
      add(BoxStack(isBottom: isBottom, stackHeight: boxHeight));
      appData.isNewBoxBottom = null;
      appData.newBoxHeight = null;
      appData.forceNotifyListeners();
    }

    if (!_gameOver) {
      appData.sendCustomMessage({
        'type': 'alive',
        'id': appData.id,
        'x': player.x,
        'y': player.y,
        'score': player.score,
      });
    }

    appData.sortPlayerMap();
  }

  @override
  void updateTree(double dt) {
    if (_gameOver) {
      return;
    }
    super.updateTree(dt);
  }

  void countTime() {
    if (player.isDying) {
      appData.setScore(appData.id, _time);
      return;
    }
    Future.delayed(const Duration(seconds: 1), () {
      _time++;
      appData.setScore(appData.id, _time);
      countTime();
    });
  }

  void gameOver() {
    _gameOver = true;
    appData.sendMessage('dead', 'x', player.x, 'y', player.y);
    appData.changeConnectionStatus(ConnectionStatus.disconnecting);
  }

  @override
  void onTap() {
    player.fly();
  }
}

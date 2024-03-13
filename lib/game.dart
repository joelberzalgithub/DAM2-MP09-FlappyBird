import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'box_stack.dart';
import 'ground.dart';
import 'player.dart';
import 'sky.dart';

class FlappyEmber extends FlameGame with TapDetector, HasCollisionDetection {
  late final BuildContext context;

  FlappyEmber();

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
      player = Player(),
      ScreenHitbox(),
    ]);
    countTime();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceBox += dt;
    speed += 10 * dt;
    if (_timeSinceBox > _boxInterval) {
      add(BoxStack(isBottom: _random.nextBool()));
      _timeSinceBox = 0;
    }
  }

  @override
  void updateTree(double dt) {
    if (_gameOver) {
      return;
    }
    super.updateTree(dt);
  }

  void countTime() {
    if (_gameOver) {
      print('La partida ha durat $_time segons!');
      return;
    }
    Future.delayed(const Duration(seconds: 1), () {
      _time++;
      print('Han transcorregut $_time segons');
      countTime();
    });
  }

  void gameOver() {
    _gameOver = true;
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fi de la partida!'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jugador 1  '),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: 400 / 400,
                          backgroundColor: Colors.transparent,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Text('  40'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jugador 2  '),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: 300 / 400,
                          backgroundColor: Colors.transparent,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Text('  30'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jugador 3  '),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: 200 / 400,
                          backgroundColor: Colors.transparent,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Text('  20'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jugador 4  '),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: 100 / 400,
                          backgroundColor: Colors.transparent,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Text('  10'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: const Text("Tornar a la pantalla d'inici"),
          ),
        ],
      ),
    );
  }

  @override
  void onTap() {
    player.fly();
  }
}

import 'dart:math';

import 'package:flame/components.dart';

import 'box.dart';
import 'game.dart';

class BoxStack extends PositionComponent with HasGameRef<FlappyEmber> {
  BoxStack({required this.isBottom, required this.stackHeight});

  final bool isBottom;
  final int stackHeight;

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;
    final gameHeight = gameRef.size.y;
    final boxHeight = Box.initialSize.y;
    final boxSpacing = boxHeight * (2 / 3);
    final initialY = isBottom ? gameHeight - boxHeight : -boxHeight / 3;
    final boxes = List.generate(stackHeight, (i) {
      return Box(
        position: Vector2(0, initialY + i * boxSpacing * (isBottom ? -1 : 1)),
      );
    });
    addAll(isBottom ? boxes : boxes.reversed);
  }

  @override
  void update(double dt) {
    if (position.x < -Box.initialSize.x) {
      removeFromParent();
    }
    position.x -= gameRef.speed * dt;
  }
}

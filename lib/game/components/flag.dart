import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';

/// Level-end flag pole. Touching it completes the level.
class Flag extends PositionComponent with CollisionCallbacks {
  Flag({required Vector2 position})
      : super(
          // Make the pole tall so it is easy to reach.
          position: position - Vector2(0, MarioGame.tileSize * 8),
          size: Vector2(MarioGame.tileSize, MarioGame.tileSize * 9),
          anchor: Anchor.topLeft,
        );

  double _t = 0;

  @override
  Future<void> onLoad() async {
    // Hitbox is just the pole column.
    add(
      RectangleHitbox(
        size: Vector2(10, size.y),
        position: Vector2(size.x / 2 - 5, 0),
      )..collisionType = CollisionType.passive,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final p = Paint();
    final cx = size.x / 2;

    // Pole
    p.color = const Color(0xFFBDBDBD);
    canvas.drawRect(Rect.fromLTWH(cx - 3, 0, 6, size.y), p);
    // ball on top
    p.color = const Color(0xFFFFD93D);
    canvas.drawCircle(Offset(cx, 4), 8, p);

    // Waving flag
    p.color = const Color(0xFFD62828);
    final wave = math.sin(_t * 4) * 4;
    final path = Path()
      ..moveTo(cx, 16)
      ..lineTo(cx + 44 + wave, 28)
      ..lineTo(cx, 42)
      ..close();
    canvas.drawPath(path, p);
    // emblem
    p.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx + 16, 29), 4, p);
  }
}

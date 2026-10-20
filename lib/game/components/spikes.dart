import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';

/// Hazard spikes. Touching them kills the player.
class Spikes extends PositionComponent with CollisionCallbacks {
  Spikes({required Vector2 position})
      : super(
          position: position + Vector2(0, MarioGame.tileSize - 20),
          size: Vector2(MarioGame.tileSize, 20),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    final p = Paint()..color = const Color(0xFFBDBDBD);
    const s = MarioGame.tileSize;
    const spikes = 4;
    const w = s / spikes;
    for (int i = 0; i < spikes; i++) {
      final path = Path()
        ..moveTo(i * w, size.y)
        ..lineTo(i * w + w / 2, 0)
        ..lineTo((i + 1) * w, size.y)
        ..close();
      canvas.drawPath(path, p);
      // highlight
      canvas.drawPath(
        Path()
          ..moveTo(i * w + w / 2, 0)
          ..lineTo(i * w + w / 2 + 2, size.y)
          ..lineTo(i * w + w / 2 - 1, size.y)
          ..close(),
        Paint()..color = const Color(0xFFEEEEEE),
      );
    }
    // base
    p.color = const Color(0xFF616161);
    canvas.drawRect(Rect.fromLTWH(0, size.y - 4, s, 4), p);
  }
}

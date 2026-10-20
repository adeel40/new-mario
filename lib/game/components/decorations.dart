import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';

/// Non-interactive fluffy cloud.
class CloudDecoration extends PositionComponent {
  CloudDecoration({required Vector2 position})
      : super(
          position: position,
          size: Vector2(MarioGame.tileSize * 2, MarioGame.tileSize),
          anchor: Anchor.topLeft,
        ) {
    priority = -50;
  }

  @override
  void render(Canvas canvas) {
    final p = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(const Offset(24, 30), 18, p);
    canvas.drawCircle(const Offset(48, 24), 22, p);
    canvas.drawCircle(const Offset(72, 30), 18, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 28, 60, 18),
        const Radius.circular(12),
      ),
      p,
    );
    // soft shadow
    p.color = const Color(0x22000000);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 42, 52, 6),
        const Radius.circular(6),
      ),
      p,
    );
  }
}

/// Non-interactive background hill.
class HillDecoration extends PositionComponent {
  HillDecoration({required Vector2 position})
      : super(
          position: position,
          size: Vector2(MarioGame.tileSize * 4, MarioGame.tileSize * 3),
          anchor: Anchor.topLeft,
        ) {
    priority = -60;
  }

  @override
  void render(Canvas canvas) {
    final p = Paint()..color = const Color(0xFF3E9E4E);
    final path = Path()
      ..moveTo(0, size.y)
      ..quadraticBezierTo(size.x / 2, -20, size.x, size.y)
      ..close();
    canvas.drawPath(path, p);
    // highlight
    p.color = const Color(0xFF55B766);
    final path2 = Path()
      ..moveTo(size.x * 0.25, size.y)
      ..quadraticBezierTo(size.x * 0.45, size.y * 0.25, size.x * 0.6, size.y)
      ..close();
    canvas.drawPath(path2, p);
  }
}

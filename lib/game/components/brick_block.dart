import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// Decorative brick block (solid). Classic red brick pattern.
class BrickBlock extends Solid {
  BrickBlock({required super.position});

  @override
  void render(Canvas canvas) {
    const s = MarioGame.tileSize;
    final p = Paint()..color = const Color(0xFFB5572A);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), p);

    // mortar lines
    p
      ..color = const Color(0xFF7A3A18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // horizontal
    canvas.drawLine(const Offset(0, 16), const Offset(s, 16), p);
    canvas.drawLine(const Offset(0, 32), const Offset(s, 32), p);
    // vertical (staggered)
    canvas.drawLine(const Offset(24, 0), const Offset(24, 16), p);
    canvas.drawLine(const Offset(12, 16), const Offset(12, 32), p);
    canvas.drawLine(const Offset(36, 16), const Offset(36, 32), p);
    canvas.drawLine(const Offset(24, 32), const Offset(24, s), p);

    // highlight
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0x33FFFFFF);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, 3), p);
  }
}

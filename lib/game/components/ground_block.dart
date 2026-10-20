import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// Ground / dirt block with a grassy top edge.
class GroundBlock extends Solid {
  GroundBlock({required super.position});

  @override
  void render(Canvas canvas) {
    const s = MarioGame.tileSize;
    final p = Paint();

    // Dirt body
    p.color = const Color(0xFF9B5A2B);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), p);

    // Dirt speckles
    p.color = const Color(0xFF7A4420);
    canvas.drawRect(const Rect.fromLTWH(8, 18, 6, 6), p);
    canvas.drawRect(const Rect.fromLTWH(30, 30, 7, 7), p);
    canvas.drawRect(const Rect.fromLTWH(20, 38, 5, 5), p);

    // Grass top
    p.color = const Color(0xFF4CAF50);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, 12), p);
    p.color = const Color(0xFF66CC66);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, 4), p);

    // Subtle border
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    p.color = const Color(0x33000000);
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), p);
  }
}

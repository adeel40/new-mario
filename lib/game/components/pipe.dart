import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// Classic green pipe. [isTop] draws the wider lip.
class Pipe extends Solid {
  Pipe({required super.position, required this.isTop});

  final bool isTop;

  @override
  void render(Canvas canvas) {
    const s = MarioGame.tileSize;
    final body = Paint()..color = const Color(0xFF2EA043);
    final shade = Paint()..color = const Color(0xFF1C7A30);
    final light = Paint()..color = const Color(0xFF57D977);

    if (isTop) {
      // lip overhangs slightly
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, 0, s + 8, 16),
          const Radius.circular(4),
        ),
        body,
      );
      canvas.drawRect(const Rect.fromLTWH(-4, 0, s + 8, 4), light);
      canvas.drawRect(const Rect.fromLTWH(-4, 12, s + 8, 4), shade);
      // tube below
      canvas.drawRect(const Rect.fromLTWH(4, 16, s - 8, s - 16), body);
      canvas.drawRect(const Rect.fromLTWH(6, 16, 6, s - 16), light);
    } else {
      canvas.drawRect(const Rect.fromLTWH(4, 0, s - 8, s), body);
      canvas.drawRect(const Rect.fromLTWH(6, 0, 6, s), light);
      canvas.drawRect(const Rect.fromLTWH(s - 12, 0, 4, s), shade);
    }
  }
}

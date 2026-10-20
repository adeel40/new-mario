import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// A floating platform block with a stone/metal look.
class PlatformBlock extends Solid {
  PlatformBlock({required super.position});

  @override
  void render(Canvas canvas) {
    const s = MarioGame.tileSize;
    final p = Paint()..color = const Color(0xFF8D9AA8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, s, s),
        const Radius.circular(4),
      ),
      p,
    );
    // top highlight
    p.color = const Color(0xFFB9C4D0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, s - 4, 10),
        const Radius.circular(3),
      ),
      p,
    );
    // bottom shadow
    p.color = const Color(0xFF5D6977);
    canvas.drawRect(const Rect.fromLTWH(0, s - 8, s, 8), p);
    // bolts
    p.color = const Color(0xFF454F5B);
    canvas.drawCircle(const Offset(8, s - 4), 2, p);
    canvas.drawCircle(const Offset(s - 8, s - 4), 2, p);
  }
}

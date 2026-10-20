import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// Question block. When hit from below it bumps up, awards score/coin and
/// turns into an inert used block.
class QuestionBlock extends Solid with HasGameReference<MarioGame> {
  QuestionBlock({required super.position});

  bool used = false;
  double _bump = 0;
  double _t = 0;

  void hit() {
    if (used) return;
    used = true;
    _bump = 10;
    game.addCoin();
    game.addScore(100);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_bump > 0) {
      _bump = math.max(0, _bump - dt * 60);
    }
  }

  @override
  void render(Canvas canvas) {
    const s = MarioGame.tileSize;
    canvas.save();
    canvas.translate(0, -_bump);

    final p = Paint();
    if (used) {
      p.color = const Color(0xFF8B6914);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 2, s - 4, s - 4),
          const Radius.circular(4),
        ),
        p,
      );
    } else {
      // pulsing golden block
      final glow = (math.sin(_t * 4) + 1) / 2;
      p.color = Color.lerp(
        const Color(0xFFF2A900),
        const Color(0xFFFFD93D),
        glow,
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 2, s - 4, s - 4),
          const Radius.circular(4),
        ),
        p,
      );
      // rivets
      p.color = const Color(0xFF8B6914);
      for (final o in const [
        Offset(8, 8),
        Offset(s - 8, 8),
        Offset(8, s - 8),
        Offset(s - 8, s - 8),
      ]) {
        canvas.drawCircle(o, 2, p);
      }
      // question mark
      final tp = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: Color(0xFF8B4A00),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((s - tp.width) / 2, (s - tp.height) / 2));
    }
    canvas.restore();
  }
}

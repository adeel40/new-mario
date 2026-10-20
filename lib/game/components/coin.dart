import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';

/// Spinning collectible coin.
class Coin extends PositionComponent
    with HasGameReference<MarioGame>, CollisionCallbacks {
  Coin({required Vector2 position})
      : super(
          position: position + Vector2.all(MarioGame.tileSize * 0.2),
          size: Vector2.all(MarioGame.tileSize * 0.6),
          anchor: Anchor.topLeft,
        );

  double _t = 0;
  bool _collected = false;
  double _popY = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    game.addCoin();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_collected) {
      _popY -= dt * 120;
      if (_popY < -40) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // spin by scaling width horizontally
    final spin = (math.sin(_t * 5).abs() * 0.9 + 0.1);
    final w = size.x * spin;
    final cx = size.x / 2;
    canvas.save();
    canvas.translate(0, _popY);

    final p = Paint()..color = const Color(0xFFFFD93D);
    canvas.drawOval(
      Rect.fromLTWH(cx - w / 2, 0, w, size.y),
      p,
    );
    p.color = const Color(0xFFF2A900);
    canvas.drawOval(
      Rect.fromLTWH(cx - w / 2 + 2, 2, math.max(0, w - 4), size.y - 4),
      p..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // shine
    if (spin > 0.4) {
      p
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFF3B0);
      canvas.drawOval(
        Rect.fromLTWH(cx - 2, 5, 3, size.y - 10),
        p,
      );
    }
    canvas.restore();
  }
}

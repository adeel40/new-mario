import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// A walking mushroom enemy. Patrols left/right, reverses at walls/ledges,
/// and gets squashed when stomped.
class Goomba extends PositionComponent
    with HasGameReference<MarioGame>, CollisionCallbacks {
  Goomba({required Vector2 position})
      : super(
          position: position + Vector2(4, MarioGame.tileSize - 40),
          size: Vector2(40, 40),
          anchor: Anchor.topLeft,
        );

  final double _speed = 52;
  double _dir = -1;
  double _t = 0;
  bool isDead = false;
  double _squashTimer = 0;
  double _vy = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  void stomp() {
    if (isDead) return;
    isDead = true;
    _squashTimer = 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;

    if (isDead) {
      _squashTimer -= dt;
      if (_squashTimer <= 0) removeFromParent();
      return;
    }

    // gravity so it sits on ground / falls off edges
    _vy += MarioGame.gravity * dt;
    if (_vy > 700) _vy = 700;
    position.y += _vy * dt;
    position.x += _dir * _speed * dt;

    // Fell out of world.
    if (position.y > game.levelWorld!.data.heightInTiles * MarioGame.tileSize + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isDead) return;
    if (other is Solid) {
      final me = toAbsoluteRect();
      final it = other.toAbsoluteRect();
      final overlapTop = me.bottom - it.top;
      final overlapLeft = me.right - it.left;
      final overlapRight = it.right - me.left;
      final minX = math.min(overlapLeft, overlapRight);

      // Landing on top.
      if (_vy > 0 && overlapTop < 20 && me.bottom < it.top + 20) {
        position.y -= overlapTop;
        _vy = 0;
      } else if (minX < 14) {
        // Hit a wall: reverse.
        _dir = -_dir;
        if (overlapLeft < overlapRight) {
          position.x -= overlapLeft;
        } else {
          position.x += overlapRight;
        }
      }
    } else if (other is Goomba && !other.isDead && other != this) {
      _dir = -_dir;
    }
  }

  @override
  void render(Canvas canvas) {
    final p = Paint();
    if (isDead) {
      // squashed
      p.color = const Color(0xFF8B4513);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, size.y - 12, size.x - 4, 12),
          const Radius.circular(5),
        ),
        p,
      );
      return;
    }

    final waddle = math.sin(_t * 8) * 2;

    // Feet
    p.color = const Color(0xFF3B2410);
    canvas.drawOval(
      Rect.fromLTWH(4 + waddle, size.y - 8, 14, 8),
      p,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.x - 18 - waddle, size.y - 8, 14, 8),
      p,
    );

    // Body (mushroom cap)
    p.color = const Color(0xFF9B5A2B);
    canvas.drawOval(
      Rect.fromLTWH(2, 4, size.x - 4, size.y - 12),
      p,
    );
    // Lighter underside
    p.color = const Color(0xFFE2B07A);
    canvas.drawOval(
      Rect.fromLTWH(8, size.y - 22, size.x - 16, 16),
      p,
    );

    // Eyes
    p.color = const Color(0xFFFFFFFF);
    canvas.drawOval(const Rect.fromLTWH(10, 16, 8, 11), p);
    canvas.drawOval(Rect.fromLTWH(size.x - 18, 16, 8, 11), p);
    p.color = const Color(0xFF1A1A1A);
    final look = _dir < 0 ? 0.0 : 2.0;
    canvas.drawOval(Rect.fromLTWH(12 + look, 20, 4, 6), p);
    canvas.drawOval(Rect.fromLTWH(size.x - 16 + look, 20, 4, 6), p);

    // Angry brows
    p
      ..color = const Color(0xFF3B2410)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(9, 15), const Offset(19, 18), p);
    canvas.drawLine(
      Offset(size.x - 9, 15),
      Offset(size.x - 19, 18),
      p,
    );
  }
}

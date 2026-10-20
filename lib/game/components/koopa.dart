import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';

/// A faster turtle-like enemy. Taller than a goomba and quicker.
class Koopa extends PositionComponent
    with HasGameReference<MarioGame>, CollisionCallbacks {
  Koopa({required Vector2 position})
      : super(
          position: position + Vector2(4, MarioGame.tileSize - 52),
          size: Vector2(40, 52),
          anchor: Anchor.topLeft,
        );

  final double _speed = 90;
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
    _vy += MarioGame.gravity * dt;
    if (_vy > 700) _vy = 700;
    position.y += _vy * dt;
    position.x += _dir * _speed * dt;
    if (position.y >
        game.levelWorld!.data.heightInTiles * MarioGame.tileSize + 100) {
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
      if (_vy > 0 && overlapTop < 20 && me.bottom < it.top + 20) {
        position.y -= overlapTop;
        _vy = 0;
      } else if (minX < 14) {
        _dir = -_dir;
        if (overlapLeft < overlapRight) {
          position.x -= overlapLeft;
        } else {
          position.x += overlapRight;
        }
      }
    } else if (other is Koopa && !other.isDead && other != this) {
      _dir = -_dir;
    }
  }

  @override
  void render(Canvas canvas) {
    final p = Paint();
    if (isDead) {
      p.color = const Color(0xFF2E7D32);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, size.y - 14, size.x - 4, 14),
          const Radius.circular(6),
        ),
        p,
      );
      return;
    }

    final waddle = math.sin(_t * 9) * 2;

    // Feet
    p.color = const Color(0xFFF2A900);
    canvas.drawOval(Rect.fromLTWH(4 + waddle, size.y - 8, 13, 8), p);
    canvas.drawOval(
        Rect.fromLTWH(size.x - 17 - waddle, size.y - 8, 13, 8), p);

    // Shell
    p.color = const Color(0xFF2E9E3F);
    canvas.drawOval(Rect.fromLTWH(3, 18, size.x - 6, size.y - 26), p);
    // shell plates
    p
      ..color = const Color(0xFF1C7A30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
        Rect.fromLTWH(9, 24, size.x - 18, size.y - 38), p);
    p.style = PaintingStyle.fill;

    // Belly
    p.color = const Color(0xFFF4E285);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 30, size.x - 20, 12),
        const Radius.circular(4),
      ),
      p,
    );

    // Head
    final hx = _dir < 0 ? 2.0 : size.x - 20;
    p.color = const Color(0xFF8BC34A);
    canvas.drawOval(Rect.fromLTWH(hx, 2, 18, 18), p);
    // eye
    p.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(hx + (_dir < 0 ? 5 : 13), 9), 3.5, p);
    p.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(hx + (_dir < 0 ? 4 : 14), 9), 1.8, p);
  }
}

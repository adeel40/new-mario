import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mario_game.dart';
import 'solid.dart';
import 'goomba.dart';
import 'koopa.dart';
import 'coin.dart';
import 'question_block.dart';
import 'spikes.dart';
import 'flag.dart';

/// The player character. Hand-painted (no external art) with a classic
/// red-cap plumber look, plus responsive platforming physics:
///  - acceleration / friction
///  - run (hold Shift) for higher top speed
///  - variable jump height (hold to jump higher)
///  - coyote time + jump buffering for forgiving controls
class Player extends PositionComponent
    with HasGameReference<MarioGame>, CollisionCallbacks {
  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(40, 46),
          anchor: Anchor.topLeft,
        );

  // Physics tuning.
  static const double _walkSpeed = 150;
  static const double _runSpeed = 260;
  static const double _accel = 900;
  static const double _friction = 1100;
  static const double _jumpVelocity = -560;
  static const double _maxFall = 820;
  static const double _coyoteTime = 0.10;
  static const double _jumpBuffer = 0.12;

  Vector2 velocity = Vector2.zero();
  bool onGround = false;
  bool _facingRight = true;
  double _coyoteTimer = 0;
  double _jumpBufferTimer = 0;
  bool _wasJumpDown = false;
  double _animTime = 0;
  bool _dead = false;

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: Vector2(34, 44),
        position: Vector2(3, 2),
      )..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dead) {
      // Death flop animation.
      velocity.y += MarioGame.gravity * dt;
      position += velocity * dt;
      _animTime += dt;
      if (position.y > game.levelWorld!.data.heightInTiles * MarioGame.tileSize + 200) {
        // fully fallen; game handles respawn already triggered in _die()
      }
      return;
    }

    _animTime += dt;
    final input = game;

    // --- Horizontal input -----------------------------------------------
    final double target = input.wantRun ? _runSpeed : _walkSpeed;
    double dir = 0;
    if (input.moveLeft) dir -= 1;
    if (input.moveRight) dir += 1;

    if (dir != 0) {
      velocity.x += dir * _accel * dt;
      velocity.x = velocity.x.clamp(-target, target);
      _facingRight = dir > 0;
    } else {
      // apply friction
      if (velocity.x > 0) {
        velocity.x = math.max(0, velocity.x - _friction * dt);
      } else if (velocity.x < 0) {
        velocity.x = math.min(0, velocity.x + _friction * dt);
      }
    }

    // --- Jump logic (coyote + buffer + variable height) ------------------
    _coyoteTimer = onGround ? _coyoteTime : _coyoteTimer - dt;

    final jumpDown = input.wantJump;
    if (jumpDown && !_wasJumpDown) {
      _jumpBufferTimer = _jumpBuffer;
    } else {
      _jumpBufferTimer -= dt;
    }
    _wasJumpDown = jumpDown;

    if (_jumpBufferTimer > 0 && _coyoteTimer > 0) {
      velocity.y = _jumpVelocity;
      onGround = false;
      _coyoteTimer = 0;
      _jumpBufferTimer = 0;
    }

    // Variable jump height: releasing jump early cuts upward velocity.
    if (!jumpDown && velocity.y < -140) {
      velocity.y = -140;
    }

    // --- Gravity ---------------------------------------------------------
    velocity.y += MarioGame.gravity * dt;
    if (velocity.y > _maxFall) velocity.y = _maxFall;

    // --- Move with per-axis collision resolution ------------------------
    onGround = false;
    _moveAndCollide(dt);

    // --- Fall-out-of-world death ----------------------------------------
    final worldBottom =
        game.levelWorld!.data.heightInTiles * MarioGame.tileSize;
    if (position.y > worldBottom + 100) {
      _die();
    }
  }

  void _moveAndCollide(double dt) {
    // Horizontal
    position.x += velocity.x * dt;
    _resolveAxis(horizontal: true);
    // Vertical
    position.y += velocity.y * dt;
    _resolveAxis(horizontal: false);
  }

  // We use Flame's collision callbacks for the actual overlap resolution with
  // solids; this method keeps the player inside the horizontal world bounds.
  void _resolveAxis({required bool horizontal}) {
    if (horizontal) {
      if (position.x < 0) {
        position.x = 0;
        velocity.x = 0;
      }
      final maxX = game.levelWorld!.data.widthInTiles * MarioGame.tileSize -
          size.x;
      if (position.x > maxX) {
        position.x = maxX;
        velocity.x = 0;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Collisions
  // ---------------------------------------------------------------------------
  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (_dead) return;

    if (other is Solid) {
      _resolveSolid(other);
    } else if (other is Goomba && !other.isDead) {
      _handleEnemyHit(other.toRect(), () => other.stomp());
    } else if (other is Koopa && !other.isDead) {
      _handleEnemyHit(other.toRect(), () => other.stomp());
    } else if (other is Coin) {
      other.collect();
    } else if (other is Spikes) {
      _die();
    } else if (other is Flag) {
      game.levelCompleted();
    }
  }

  void _resolveSolid(Solid solid) {
    final me = toAbsoluteRect();
    final it = solid.toAbsoluteRect();

    final overlapLeft = me.right - it.left;
    final overlapRight = it.right - me.left;
    final overlapTop = me.bottom - it.top;
    final overlapBottom = it.bottom - me.top;

    final minX = math.min(overlapLeft, overlapRight);
    final minY = math.min(overlapTop, overlapBottom);

    if (minX < minY) {
      // Resolve on X axis.
      if (overlapLeft < overlapRight) {
        position.x -= overlapLeft;
      } else {
        position.x += overlapRight;
      }
      velocity.x = 0;
    } else {
      // Resolve on Y axis.
      if (overlapTop < overlapBottom) {
        // Landing on top of the solid.
        position.y -= overlapTop;
        velocity.y = 0;
        onGround = true;
      } else {
        // Hitting head on the underside.
        position.y += overlapBottom;
        if (velocity.y < 0) velocity.y = 0;
        if (solid is QuestionBlock) {
          solid.hit();
        }
      }
    }
  }

  void _handleEnemyHit(Rect enemyRect, VoidCallback stomp) {
    final me = toAbsoluteRect();
    final stomping = velocity.y > 0 && me.bottom < enemyRect.top + 24;
    if (stomping) {
      stomp();
      velocity.y = _jumpVelocity * 0.6; // bounce
      game.addScore(100);
    } else {
      _die();
    }
  }

  void _die() {
    if (_dead) return;
    _dead = true;
    velocity = Vector2(0, -420);
    // After a short delay the game reloads the level / ends.
    add(
      TimerComponent(
        period: 1.1,
        removeOnFinish: true,
        onTick: () => game.playerDied(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rendering: hand-painted plumber
  // ---------------------------------------------------------------------------
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final moving = velocity.x.abs() > 10 && onGround;
    final bob = moving ? math.sin(_animTime * 18) * 2 : 0.0;
    final legPhase = moving ? math.sin(_animTime * 18) : 0.0;

    canvas.save();
    // Flip horizontally based on facing.
    if (!_facingRight) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }
    if (_dead) {
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(_animTime * 6);
      canvas.translate(-size.x / 2, -size.y / 2);
    }

    const red = Color(0xFFD62828);
    const blue = Color(0xFF2B50C8);
    const skin = Color(0xFFFFC9A0);
    const brown = Color(0xFF6B3E1D);
    const shoe = Color(0xFF5A3A1A);

    final p = Paint();

    // Legs (overalls) with walk animation
    p.color = blue;
    final legOffset = legPhase * 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 30 + bob, 10, 14 + legOffset.abs()),
        const Radius.circular(3),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(22, 30 + bob, 10, 14 + (4 - legOffset.abs())),
        const Radius.circular(3),
      ),
      p,
    );

    // Shoes
    p.color = shoe;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 42 + bob, 13, 5),
        const Radius.circular(2.5),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(21, 42 + bob, 13, 5),
        const Radius.circular(2.5),
      ),
      p,
    );

    // Body / shirt
    p.color = red;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 20 + bob, 26, 14),
        const Radius.circular(5),
      ),
      p,
    );
    // Overall straps
    p.color = blue;
    canvas.drawRect(Rect.fromLTWH(12, 20 + bob, 4, 10), p);
    canvas.drawRect(Rect.fromLTWH(24, 20 + bob, 4, 10), p);
    // Button
    p.color = const Color(0xFFFFD93D);
    canvas.drawCircle(Offset(20, 30 + bob), 1.8, p);

    // Arms
    p.color = red;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 22 + bob, 7, 11),
        const Radius.circular(3),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(31, 22 + bob, 7, 11),
        const Radius.circular(3),
      ),
      p,
    );
    // Hands
    p.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(5, 33 + bob), 3, p);
    canvas.drawCircle(Offset(35, 33 + bob), 3, p);

    // Head
    p.color = skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 6 + bob, 20, 16),
        const Radius.circular(7),
      ),
      p,
    );

    // Cap
    p.color = red;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 2 + bob, 26, 10),
        const Radius.circular(6),
      ),
      p,
    );
    // Cap brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(24, 8 + bob, 12, 4),
        const Radius.circular(2),
      ),
      p,
    );
    // Cap emblem
    p.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(16, 7 + bob), 3, p);
    p.color = red;
    canvas.drawCircle(Offset(16, 7 + bob), 1.6, p);

    // Eye
    p.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(26, 14 + bob), 1.8, p);

    // Mustache
    p.color = brown;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 17 + bob, 11, 3.5),
        const Radius.circular(2),
      ),
      p,
    );
    // Nose
    p.color = const Color(0xFFE8A87C);
    canvas.drawCircle(Offset(30, 16 + bob), 2.4, p);

    canvas.restore();
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../mario_game.dart';

/// Base class for any block the player cannot pass through. Collision
/// resolution is handled by the [Player] via its collision callbacks.
abstract class Solid extends PositionComponent {
  Solid({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(MarioGame.tileSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A themed gradient sky that fills the whole level. Three themes give each
/// level a distinct mood (day hills, cavern dusk, sky sunset).
class ParallaxBackground extends PositionComponent {
  ParallaxBackground({
    required this.themeIndex,
    required this.worldWidth,
    required this.worldHeight,
  }) : super(
          position: Vector2(0, -worldHeight),
          size: Vector2(worldWidth, worldHeight * 3),
          anchor: Anchor.topLeft,
        );

  final int themeIndex;
  final double worldWidth;
  final double worldHeight;

  List<Color> get _colors {
    switch (themeIndex) {
      case 1:
        // cavern dusk
        return const [Color(0xFF2C1A4A), Color(0xFF5B3A8C), Color(0xFF9B6FC2)];
      case 2:
        // sky sunset
        return const [Color(0xFF1B3A8C), Color(0xFF6A5ACD), Color(0xFFFFA45B)];
      case 0:
      default:
        // day
        return const [Color(0xFF3A6FE0), Color(0xFF5C94FC), Color(0xFF9FCBFF)];
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _colors,
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }
}

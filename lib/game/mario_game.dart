import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'levels.dart';
import 'components/player.dart';
import 'world/level_world.dart';

enum PlayState { menu, playing, paused, gameOver, levelComplete, win }

/// The main game class. Owns global state (score, coins, lives, level index),
/// the camera, and orchestrates loading / unloading of levels.
class MarioGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  MarioGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  static const double gravity = 1400;
  static const double tileSize = 48;

  // Fixed virtual resolution so the game looks identical on every device
  // (letter-boxed as needed). 720px tall == 15 tiles of 48px.
  static const double gameWidth = 1280;
  static const double gameHeight = 720;

  late Player player;
  LevelWorld? levelWorld;

  int currentLevel = 0;
  int score = 0;
  int coins = 0;
  int lives = 3;
  int highScore = 0;

  PlayState _state = PlayState.menu;
  PlayState get state => _state;

  // Simple HUD listenable so Flutter overlays can rebuild on changes.
  final ValueNotifier<int> hudTick = ValueNotifier<int>(0);

  SharedPreferences? _prefs;

  @override
  Color backgroundColor() => const Color(0xFF5C94FC);

  @override
  Future<void> onLoad() async {
    _prefs = await SharedPreferences.getInstance();
    highScore = _prefs?.getInt('highScore') ?? 0;

    camera.viewfinder.anchor = Anchor.center;
  }

  void _notify() => hudTick.value++;

  // ---------------------------------------------------------------------------
  // Flow control
  // ---------------------------------------------------------------------------

  void startGame() {
    currentLevel = 0;
    score = 0;
    coins = 0;
    lives = 3;
    overlays.remove('MainMenu');
    _loadLevel(currentLevel);
  }

  Future<void> _loadLevel(int index) async {
    // Clean up any existing world.
    levelWorld?.removeFromParent();
    final data = levels[index];

    final newWorld = LevelWorld(data: data);
    levelWorld = newWorld;
    world.add(newWorld);

    // Wait a tick for the world to mount so the player is available.
    await newWorld.loaded;
    player = newWorld.player;

    // Configure camera to follow the player horizontally, clamped to the
    // level bounds. The bounds rectangle is the area the camera *center*
    // may occupy, so we inset it by half the viewport.
    final levelW = data.widthInTiles * tileSize;
    final levelH = data.heightInTiles * tileSize;
    camera.follow(player, maxSpeed: 600, snap: true);
    camera.setBounds(
      Rectangle.fromLTWH(
        gameWidth / 2,
        gameHeight / 2,
        (levelW - gameWidth).clamp(0, double.infinity),
        (levelH - gameHeight).clamp(0, double.infinity) + tileSize * 2,
      ),
    );

    _state = PlayState.playing;
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    if (!overlays.isActive('Hud')) overlays.add('Hud');
    resumeEngine();
    _notify();
  }

  void playerDied() {
    lives -= 1;
    _notify();
    if (lives <= 0) {
      _state = PlayState.gameOver;
      _saveHighScore();
      overlays.add('GameOver');
      pauseEngine();
    } else {
      // Reload the same level.
      _loadLevel(currentLevel);
    }
  }

  void levelCompleted() {
    if (_state != PlayState.playing) return;
    _state = PlayState.levelComplete;
    score += 1000; // flag/level clear bonus
    _saveHighScore();
    _notify();
    if (currentLevel >= levels.length - 1) {
      _state = PlayState.win;
      overlays.add('Win');
    } else {
      overlays.add('LevelComplete');
    }
    pauseEngine();
  }

  void nextLevel() {
    currentLevel += 1;
    if (currentLevel >= levels.length) {
      _state = PlayState.win;
      overlays.add('Win');
      return;
    }
    _loadLevel(currentLevel);
  }

  void restart() {
    overlays.remove('GameOver');
    overlays.remove('Win');
    startGame();
  }

  void backToMenu() {
    levelWorld?.removeFromParent();
    levelWorld = null;
    overlays.remove('Hud');
    overlays.remove('GameOver');
    overlays.remove('Win');
    overlays.remove('LevelComplete');
    overlays.remove('Pause');
    _state = PlayState.menu;
    overlays.add('MainMenu');
    pauseEngine();
  }

  void togglePause() {
    if (_state == PlayState.playing) {
      _state = PlayState.paused;
      overlays.add('Pause');
      pauseEngine();
    } else if (_state == PlayState.paused) {
      _state = PlayState.playing;
      overlays.remove('Pause');
      resumeEngine();
    }
  }

  // ---------------------------------------------------------------------------
  // Scoring helpers (called by components)
  // ---------------------------------------------------------------------------

  void addCoin() {
    coins += 1;
    score += 200;
    if (coins >= 100) {
      coins = 0;
      lives += 1;
    }
    _notify();
  }

  void addScore(int amount) {
    score += amount;
    _notify();
  }

  void _saveHighScore() {
    if (score > highScore) {
      highScore = score;
      _prefs?.setInt('highScore', highScore);
    }
  }

  // ---------------------------------------------------------------------------
  // Input (keyboard for desktop/web testing; touch handled by overlay buttons)
  // ---------------------------------------------------------------------------

  final Set<LogicalKeyboardKey> _pressed = {};

  bool get leftPressed =>
      _pressed.contains(LogicalKeyboardKey.arrowLeft) ||
      _pressed.contains(LogicalKeyboardKey.keyA);
  bool get rightPressed =>
      _pressed.contains(LogicalKeyboardKey.arrowRight) ||
      _pressed.contains(LogicalKeyboardKey.keyD);
  bool get jumpPressed =>
      _pressed.contains(LogicalKeyboardKey.space) ||
      _pressed.contains(LogicalKeyboardKey.arrowUp) ||
      _pressed.contains(LogicalKeyboardKey.keyW);
  bool get runPressed =>
      _pressed.contains(LogicalKeyboardKey.shiftLeft) ||
      _pressed.contains(LogicalKeyboardKey.shiftRight);

  // Virtual (touch) inputs set by HUD buttons.
  bool vLeft = false;
  bool vRight = false;
  bool vJump = false;
  bool vRun = false;

  bool get moveLeft => leftPressed || vLeft;
  bool get moveRight => rightPressed || vRight;
  bool get wantJump => jumpPressed || vJump;
  bool get wantRun => runPressed || vRun;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _pressed
      ..clear()
      ..addAll(keysPressed);
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyP) {
      togglePause();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}

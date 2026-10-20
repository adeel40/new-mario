import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/mario_game.dart';
import 'ui/overlays.dart';

/// Entry point. Locks the app to landscape, hides system UI for an immersive
/// full-screen experience, and boots the Flame [GameWidget].
///
/// Any error is shown on screen instead of leaving a blank screen.
void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (details) => _ErrorScreen(
          message: details.exceptionAsString(),
        );

    // Fire-and-forget: never block the first frame on platform channels.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
        .catchError((_) {});

    runApp(const NewMarioApp());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class NewMarioApp extends StatelessWidget {
  const NewMarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Mario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD62828)),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final MarioGame _game;

  @override
  void initState() {
    super.initState();
    _game = MarioGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C94FC),
      body: GameWidget<MarioGame>(
        game: _game,
        loadingBuilder: (_) => const _LoadingScreen(),
        errorBuilder: (_, error) => _ErrorScreen(message: '$error'),
        overlayBuilderMap: {
          'MainMenu': (ctx, game) => MainMenuOverlay(game: game),
          'Hud': (ctx, game) => HudOverlay(game: game),
          'GameOver': (ctx, game) => GameOverOverlay(game: game),
          'LevelComplete': (ctx, game) => LevelCompleteOverlay(game: game),
          'Pause': (ctx, game) => PauseOverlay(game: game),
          'Win': (ctx, game) => WinOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5C94FC),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Loading...',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          'Something went wrong:\n\n$message',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

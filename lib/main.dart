import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/mario_game.dart';
import 'ui/overlays.dart';

/// Entry point. Locks the app to landscape, hides system UI for an immersive
/// full-screen experience, and boots the Flame [GameWidget].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const NewMarioApp());
}

class NewMarioApp extends StatelessWidget {
  const NewMarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Mario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'monospace',
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
      backgroundColor: Colors.black,
      body: GameWidget<MarioGame>(
        game: _game,
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

import 'package:flutter/material.dart';

import '../game/mario_game.dart';
import '../game/levels.dart';
import 'touch_controls.dart';

const _red = Color(0xFFD62828);
const _dark = Color(0xFF1A1A2E);

TextStyle _title(double size) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 2,
      shadows: const [
        Shadow(color: Colors.black54, offset: Offset(3, 3), blurRadius: 0),
      ],
    );

ButtonStyle _btnStyle(Color color) => ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );

// ---------------------------------------------------------------------------
// Main menu
// ---------------------------------------------------------------------------
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});
  final MarioGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A6FE0), Color(0xFF5C94FC), Color(0xFF9FCBFF)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NEW', style: _title(42)),
            Text('MARIO', style: _title(72).copyWith(color: const Color(0xFFFFD93D))),
            const SizedBox(height: 8),
            const Text(
              'A Flutter + Flame Platformer',
              style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: _btnStyle(_red),
              onPressed: game.startGame,
              child: const Text('▶  PLAY'),
            ),
            const SizedBox(height: 16),
            Text(
              'High Score: ${game.highScore}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Keyboard: ← →  move   ·   Space/↑  jump   ·   Shift  run   ·   P  pause\n'
                'Touch: on-screen D-pad + A (jump) / B (run)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HUD (score/coins/lives + touch controls)
// ---------------------------------------------------------------------------
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});
  final MarioGame game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top status bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: game.hudTick,
            builder: (context, _, __) {
              final levelName = levels[game.currentLevel].name;
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    _stat('SCORE', game.score.toString().padLeft(6, '0')),
                    const SizedBox(width: 20),
                    _stat('🪙', 'x${game.coins}'),
                    const Spacer(),
                    Text(
                      levelName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _stat('LIVES', '♥ ${game.lives}'),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: game.togglePause,
                      icon: const Icon(Icons.pause_circle_filled,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Touch controls
        TouchControls(game: game),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared dialog scaffold
// ---------------------------------------------------------------------------
class _CenterPanel extends StatelessWidget {
  const _CenterPanel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _dark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});
  final MarioGame game;
  @override
  Widget build(BuildContext context) {
    return _CenterPanel(children: [
      Text('GAME OVER', style: _title(40).copyWith(color: _red)),
      const SizedBox(height: 12),
      Text('Score: ${game.score}',
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      Text('High Score: ${game.highScore}',
          style: const TextStyle(color: Color(0xFFFFD93D), fontSize: 16)),
      const SizedBox(height: 24),
      Row(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(
            style: _btnStyle(_red),
            onPressed: game.restart,
            child: const Text('RETRY')),
        const SizedBox(width: 16),
        ElevatedButton(
            style: _btnStyle(Colors.blueGrey),
            onPressed: game.backToMenu,
            child: const Text('MENU')),
      ]),
    ]);
  }
}

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({super.key, required this.game});
  final MarioGame game;
  @override
  Widget build(BuildContext context) {
    return _CenterPanel(children: [
      Text('LEVEL CLEAR!', style: _title(36).copyWith(color: const Color(0xFF4CAF50))),
      const SizedBox(height: 12),
      Text('Score: ${game.score}',
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 24),
      ElevatedButton(
          style: _btnStyle(const Color(0xFF4CAF50)),
          onPressed: game.nextLevel,
          child: const Text('NEXT LEVEL  ▶')),
    ]);
  }
}

class WinOverlay extends StatelessWidget {
  const WinOverlay({super.key, required this.game});
  final MarioGame game;
  @override
  Widget build(BuildContext context) {
    return _CenterPanel(children: [
      Text('🏆', style: _title(50)),
      Text('YOU WIN!', style: _title(44).copyWith(color: const Color(0xFFFFD93D))),
      const SizedBox(height: 8),
      const Text('You cleared every world!',
          style: TextStyle(color: Colors.white, fontSize: 16)),
      const SizedBox(height: 10),
      Text('Final Score: ${game.score}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text('High Score: ${game.highScore}',
          style: const TextStyle(color: Color(0xFFFFD93D), fontSize: 16)),
      const SizedBox(height: 24),
      Row(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(
            style: _btnStyle(_red),
            onPressed: game.restart,
            child: const Text('PLAY AGAIN')),
        const SizedBox(width: 16),
        ElevatedButton(
            style: _btnStyle(Colors.blueGrey),
            onPressed: game.backToMenu,
            child: const Text('MENU')),
      ]),
    ]);
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});
  final MarioGame game;
  @override
  Widget build(BuildContext context) {
    return _CenterPanel(children: [
      Text('PAUSED', style: _title(40)),
      const SizedBox(height: 24),
      Row(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(
            style: _btnStyle(const Color(0xFF4CAF50)),
            onPressed: game.togglePause,
            child: const Text('RESUME')),
        const SizedBox(width: 16),
        ElevatedButton(
            style: _btnStyle(Colors.blueGrey),
            onPressed: game.backToMenu,
            child: const Text('MENU')),
      ]),
    ]);
  }
}

import 'dart:async';

import 'package:flame/components.dart';

import '../levels.dart';
import '../mario_game.dart';
import '../components/player.dart';
import '../components/ground_block.dart';
import '../components/brick_block.dart';
import '../components/question_block.dart';
import '../components/platform_block.dart';
import '../components/coin.dart';
import '../components/goomba.dart';
import '../components/koopa.dart';
import '../components/spikes.dart';
import '../components/pipe.dart';
import '../components/flag.dart';
import '../components/background.dart';
import '../components/decorations.dart';

/// Parses a [LevelData] ASCII map and builds all the components of a level.
/// This is a plain [Component] container that lives inside the game's [World].
class LevelWorld extends Component with HasGameReference<MarioGame> {
  LevelWorld({required this.data});

  final LevelData data;
  late Player player;

  @override
  Future<void> onLoad() async {
    const t = MarioGame.tileSize;

    // Parallax / themed background behind everything.
    add(
      ParallaxBackground(
        themeIndex: data.backgroundThemeIndex,
        worldWidth: data.widthInTiles * t,
        worldHeight: data.heightInTiles * t,
      )..priority = -100,
    );

    Vector2 spawn = Vector2(t * 2, t * 2);

    for (int row = 0; row < data.rows.length; row++) {
      final line = data.rows[row];
      for (int col = 0; col < line.length; col++) {
        final ch = line[col];
        final pos = Vector2(col * t, row * t);
        switch (ch) {
          case 'X':
            add(GroundBlock(position: pos));
            break;
          case 'B':
            add(BrickBlock(position: pos));
            break;
          case '?':
            add(QuestionBlock(position: pos));
            break;
          case 'P':
            add(PlatformBlock(position: pos));
            break;
          case 'o':
            add(Coin(position: pos));
            break;
          case 'g':
            add(Goomba(position: pos));
            break;
          case 'k':
            add(Koopa(position: pos));
            break;
          case '^':
            add(Spikes(position: pos));
            break;
          case '=':
            add(Pipe(position: pos, isTop: true));
            break;
          case '|':
            add(Pipe(position: pos, isTop: false));
            break;
          case 'c':
            add(CloudDecoration(position: pos));
            break;
          case 'h':
            add(HillDecoration(position: pos));
            break;
          case 'F':
            add(Flag(position: pos));
            break;
          case 'p':
            spawn = pos.clone();
            break;
        }
      }
    }

    player = Player(position: spawn);
    add(player);
  }
}

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_mario/main.dart';
import 'package:new_mario/game/mario_game.dart';

void main() {
  testWidgets('game boots, shows menu, and plays without errors',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const NewMarioApp());
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Menu visible?
    expect(find.text('MARIO'), findsOneWidget);

    final gw = tester.widget<GameWidget<MarioGame>>(
        find.byType(GameWidget<MarioGame>));
    final game = gw.game!;
    expect(game.isLoaded, isTrue, reason: 'game.onLoad did not finish');

    await tester.tap(find.text('▶  PLAY'));
    for (int i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    // Walk right & jump for a while.
    game.vRight = true;
    for (int i = 0; i < 200; i++) {
      game.vJump = i % 40 < 10;
      await tester.pump(const Duration(milliseconds: 16));
    }

    final p = game.player;
    // ignore: avoid_print
    print('player pos=${p.position} onGround=${p.onGround} '
        'cam=${game.camera.viewfinder.position} state=${game.state} '
        'lives=${game.lives}');
    expect(game.levelWorld, isNotNull);
  });
}

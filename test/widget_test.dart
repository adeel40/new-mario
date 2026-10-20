import 'package:flutter_test/flutter_test.dart';

import 'package:new_mario/game/levels.dart';

void main() {
  test('levels are well-formed', () {
    expect(levels, isNotEmpty);
    for (final level in levels) {
      expect(level.rows, isNotEmpty, reason: '${level.name} has no rows');
      expect(level.name, isNotEmpty);
      // Every level must contain a player spawn and a flag.
      final flat = level.rows.join();
      expect(flat.contains('p'), isTrue,
          reason: '${level.name} is missing a player spawn (p)');
      expect(flat.contains('F'), isTrue,
          reason: '${level.name} is missing a flag (F)');
    }
  });

  test('tileAt handles out-of-bounds gracefully', () {
    final level = levels.first;
    expect(level.tileAt(-1, -1), ' ');
    expect(level.tileAt(100000, 0), ' ');
    expect(level.tileAt(0, 100000), ' ');
  });
}

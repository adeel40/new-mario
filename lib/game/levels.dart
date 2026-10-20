/// Level definitions using a compact ASCII tilemap.
///
/// Legend:
///   ' ' empty / sky
///   'X' solid ground / dirt
///   'B' brick block (breakable visual)
///   '?' question block (gives a coin/score when hit from below)
///   'P' solid platform block (floating)
///   'o' coin
///   'g' goomba enemy (walks)
///   'k' koopa enemy (walks, faster)
///   'p' player spawn
///   'F' flag pole (level end)
///   '=' pipe top
///   '|' pipe body
///   '^' spikes (hazard)
///   'c' cloud decoration
///   'h' hill decoration
class LevelData {
  final String name;
  final List<String> rows;
  final int backgroundThemeIndex;

  const LevelData({
    required this.name,
    required this.rows,
    this.backgroundThemeIndex = 0,
  });

  int get heightInTiles => rows.length;
  int get widthInTiles =>
      rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);

  String tileAt(int col, int row) {
    if (row < 0 || row >= rows.length) return ' ';
    final line = rows[row];
    if (col < 0 || col >= line.length) return ' ';
    return line[col];
  }
}

// Each row is 15 tiles tall (720 / 48). Levels scroll horizontally.
const List<LevelData> levels = [
  // ------------------------------------------------------------------ LEVEL 1
  LevelData(
    name: 'WORLD 1-1  GREEN HILLS',
    backgroundThemeIndex: 0,
    rows: [
      '                                                                                              ',
      '    c           c                      c                   c                                   ',
      '                                                                                              ',
      '          ?                      o o o                                        c               ',
      '                                                                                              ',
      '       o        B?B           P P P            o o o                   ?B?                    ',
      '                                                                                              ',
      '   h           o o            o                        B B B                        h         ',
      '          =                                 g                      o o o                      ',
      '          |         g            =                         k                     o            ',
      'p         |              g       |          ^^        g          g        g            F     ',
      'XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    ],
  ),

  // ------------------------------------------------------------------ LEVEL 2
  LevelData(
    name: 'WORLD 1-2  CAVERN LEAP',
    backgroundThemeIndex: 1,
    rows: [
      '                                                                                              ',
      '          o o o                              ?                          o o o                 ',
      '                            P P P                      P P                                    ',
      '     ?B?              o o                                       o o o           B B B         ',
      '                                      P P P                                                   ',
      '              o o              g                      o o            k                        ',
      '         P P P          BBBB                P P P              BBBB            P P P           ',
      '                                k                                                             ',
      '   o                                      o o o                       g            o o        ',
      '  P P        =         g              P P         ^^^^        g                P P            ',
      'p            |              ^^^^                          g              k            F       ',
      'XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXX     XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXX     XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXX     XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXX     XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXX',
    ],
  ),

  // ------------------------------------------------------------------ LEVEL 3
  LevelData(
    name: 'WORLD 1-3  SKY CASTLE',
    backgroundThemeIndex: 2,
    rows: [
      '                                                                                              ',
      '   c         o o o           c                   o o o            c              o o o         ',
      '        ?B?B?                       B B B                   ?B?B?                              ',
      '                   P P P                      P P P                       P P P               ',
      '      o o                   g           o o              k           o o               g      ',
      '  P P P        ^^^      P P P      ^^^^        P P P          ^^^^         P P P               ',
      '                                                                                              ',
      '           g         k              g              k              g            k              ',
      '     P P P      P P        P P P          P P P        P P P            P P P        P P       ',
      '                                                                                              ',
      'p         ^^^^        ^^^^         ^^^^^         ^^^^         ^^^^^         ^^^^          F     ',
      'XXXXXX    XXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXX    XXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXX    XXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXXXXXXXXXXXXXXXX',
      'XXXXXX    XXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXX    XXXXXX    XXXXXXXXXXXXXXXXXXXXXX',
    ],
  ),
];

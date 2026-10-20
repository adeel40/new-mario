# 🍄 New Mario — Flutter + Flame Platformer

A polished 2D Mario-style platformer built with **Flutter** and the **[Flame](https://flame-engine.org/) game engine**. All graphics are hand-drawn with Flutter's `Canvas` (no external art assets), so the project is fully self-contained and builds into an installable Android **APK**.

![badge](https://img.shields.io/badge/Flutter-Flame-blue) ![badge](https://img.shields.io/badge/platform-Android-green)

## ✨ Features

- **3 hand-crafted levels** (Green Hills, Cavern Leap, Sky Castle), each with its own themed sky.
- **Responsive platforming physics** — acceleration/friction, run button, variable jump height, plus **coyote time** and **jump buffering** for forgiving, satisfying controls.
- **Enemies** — walking Goombas and faster Koopas. Stomp them from above, or lose a life on contact.
- **Interactables** — coins, `?` blocks, bricks, pipes, floating platforms, and deadly spikes.
- **Full game flow** — main menu, HUD (score / coins / lives), pause, level-complete, game-over, and win screens.
- **High score** saved locally with `shared_preferences`.
- **Cross-input** — keyboard (desktop/web) **and** on-screen touch controls (D-pad + A/B buttons) for mobile.
- **Fixed-resolution camera** (1280×720) so the game looks consistent on every device.

## 🎮 Controls

| Action | Keyboard | Touch |
|--------|----------|-------|
| Move   | `←` `→` / `A` `D` | on-screen ◀ ▶ |
| Jump   | `Space` / `↑` / `W` | **A** button |
| Run    | `Shift` | **B** button |
| Pause  | `P` | ⏸ button |

## 📁 Project structure

```
lib/
├── main.dart                     # App entry, orientation lock, GameWidget + overlays
├── game/
│   ├── mario_game.dart           # Core game: state, camera, level flow, input
│   ├── levels.dart               # ASCII tilemap level definitions
│   ├── world/
│   │   └── level_world.dart      # Parses a level map into components
│   └── components/
│       ├── player.dart           # Player physics + hand-painted sprite
│       ├── solid.dart            # Base class for collidable blocks
│       ├── ground_block.dart     # Grass-topped ground
│       ├── brick_block.dart      # Brick block
│       ├── question_block.dart   # ? block (coins/score on bump)
│       ├── platform_block.dart   # Floating platform
│       ├── pipe.dart             # Green pipe
│       ├── coin.dart             # Spinning collectible
│       ├── goomba.dart           # Walking enemy
│       ├── koopa.dart            # Faster enemy
│       ├── spikes.dart           # Hazard
│       ├── flag.dart             # Level-end flag
│       ├── decorations.dart      # Clouds & hills
│       └── background.dart       # Themed gradient sky
└── ui/
    ├── overlays.dart             # Menu / HUD / dialogs (Flutter widgets)
    └── touch_controls.dart       # Multi-touch on-screen controls
```

## 📦 Download & play (no build needed)

A ready-to-install, signed release APK is included in this repo:

➡️ **[`release/new-mario-v1.0.0.apk`](release/new-mario-v1.0.0.apk)** (~46 MB)

Download it to an Android device, enable *Install from unknown sources*, and open it to play. It was built with Flutter 3.47.7 and is signed with a debug key (fine for sideloading; use your own key for a Play Store release).

## 🛠️ Build the APK yourself

> This repository is the complete **source**. You need the Flutter SDK installed to recompile the `.apk`.

1. **Install Flutter** (3.19 or newer) — https://docs.flutter.dev/get-started/install, and the Android SDK (via Android Studio).
2. Verify your setup:
   ```bash
   flutter doctor
   ```
3. From the project root, fetch dependencies:
   ```bash
   flutter pub get
   ```
4. **Build a release APK:**
   ```bash
   flutter build apk --release
   ```
   The output APK is written to:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```
5. (Optional) Smaller, per-architecture APKs:
   ```bash
   flutter build apk --release --split-per-abi
   ```
6. Install on a connected device:
   ```bash
   flutter install
   ```
   …or just copy `app-release.apk` to your phone and open it (enable *Install from unknown sources*).

### Run in debug on a device/emulator
```bash
flutter run
```

### Run the tests
```bash
flutter test
```

## 📝 Notes

- The release build is signed with the **debug keystore** so `flutter build apk --release` works out-of-the-box. For a Play Store release, configure a proper signing key in `android/app/build.gradle`.
- No internet or runtime permissions are required to play; the `INTERNET` permission is only declared for Flutter tooling in debug.
- Levels are plain ASCII in `lib/game/levels.dart` — tweak the maps or add new `LevelData` entries to design your own worlds.

Enjoy! 🎉

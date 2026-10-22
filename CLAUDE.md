# CLAUDE.md - MyMusic Assistant & Contributor Guide

This repository is **MyMusic**, an offline retro-themed music player and YouTube Music streaming client built with Flutter, Drift (SQLite), and Just Audio.

---

## 🛠️ Essential Commands

### Dependency Management & Setup
```bash
# Get dependencies
flutter pub get

# Generate Drift database code (run whenever modifying data/database/ tables or daos)
dart run build_runner build --delete-conflicting-outputs

# Watch Drift schema changes during development
dart run build_runner watch --delete-conflicting-outputs
```

### Analysis & Testing
```bash
# Run static analysis and linting
flutter analyze

# Run unit and widget tests
flutter test

# Run a specific test file
flutter test test/path_to_test.dart
```

### Running the App
```bash
# Debug mode on connected device / emulator
flutter run

# Release build for Android APK
flutter build apk --release
```

---

## 🏗️ Architecture & Core Components

```
lib/
├── app.dart                           # Main app shell, Offstage navigation tabs, theme config
├── main.dart                          # App initialization, JustAudioBackground, Provider injection
├── core/
│   ├── constants/                     # Global constants (AppConstants)
│   ├── theme/                         # AppColors, AppTheme, AppTypography, Glassmorphic styles
│   └── utils/                         # File helpers, duration formatters, cover art extractors
├── data/
│   ├── database/                      # Drift SQLite database (AppDatabase)
│   │   ├── daos/                      # SongDao, TagDao, SongTagDao
│   │   └── tables/                    # Songs, Tags, SongTags definitions
│   └── models/                        # QueueState, Song, Tag models
├── providers/                         # ChangeNotifier ViewModels
│   ├── audio_provider.dart            # Local playback, queues, shuffle, repeat, seek
│   ├── song_provider.dart             # Song library, scanning, directory config, file ops
│   └── tag_provider.dart              # Tag management, counts, song-tag relationships
├── services/                          # Core business logic and hardware/native integrations
│   ├── ad_block/                      # Scriptlet engine & network blocker for streaming
│   ├── stream/                        # InAppWebView controller, JS injection, media observer
│   ├── custom_art_service.dart        # User-selected album art storage
│   ├── directory_settings_service.dart# Scanned music folder persistence
│   ├── permission_service.dart        # Android 13+ READ_MEDIA_AUDIO & POST_NOTIFICATIONS
│   ├── playback_coordinator.dart      # Mutex controller between offline & web stream playback
│   ├── song_import_service.dart       # Directory scanner & ID3 metadata extractor
│   ├── system_media_session_adapter.dart # Android notification & lock screen controls
│   └── unified_audio_service.dart     # Singleton owner of JustAudio AudioPlayer
├── widgets/                           # Reusable UI components (MiniPlayer, VinylSpinner, etc.)
└── pages/                             # Screens: vibe (home), stream, tags, search, player, settings
```

---

## ⚠️ Critical Architectural Rules for Claude

1. **State Mutation via Providers**:
   - UI widgets must never mutate database or audio state directly. Use `AudioProvider`, `SongProvider`, or `TagProvider`.
   - Use `context.read<T>()` inside callbacks and `context.watch<T>()` or `Consumer<T>` for rebuilds.
   - For seek bars and progress sliders, use `ValueNotifier<Duration>` / `AudioProvider.positionNotifier` to avoid rebuilding whole widget trees every 100ms.

2. **Playback Coordination (Mutex)**:
   - Never start local playback without notifying `PlaybackCoordinator` (or routing through `UnifiedAudioService`).
   - The app has two audio sources: **Offline JustAudio** and **Web YouTube Music InAppWebView**. `PlaybackCoordinator` prevents both from playing simultaneously.

3. **Persistent Navigation Shell**:
   - `_AppShell` in `lib/app.dart` utilizes `Stack` with `Offstage` + `TickerMode` for the 3 tabs (`Home`, `Stream`, `Library`).
   - **Do NOT** replace this with simple `IndexedStack` or destroy web view state upon tab switches; doing so kills active streaming playback when switching tabs.

4. **Database Changes**:
   - When modifying Drift tables (`data/database/tables/`), update the schema version in `lib/data/database/app_database.dart` and provide a migration step.
   - Always run `dart run build_runner build --delete-conflicting-outputs` after editing database files.

5. **Styling & Theming**:
   - Use `AppColors` and `AppTypography` from `lib/core/theme/`.
   - Maintain the retro-futuristic dark glassmorphic aesthetic (`AppColors.background` `#0A0A0F`, `AppColors.surface` `#141420`, `AppColors.primary` `#6C63FF`).

6. **Multi-Platform Readiness (Future Windows, Linux, macOS, iOS)**:
   - Avoid invoking Android-only method channels or Android-specific APIs directly in UI/domain code.
   - Guard platform-specific calls behind `defaultTargetPlatform` or platform service interfaces (refer to [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md)).
   - Do not assume touch-only input; preserve support for pointer events and desktop window resizing.

---

## 🤖 Guidelines for Contributing via Claude

- **Run analysis**: Always run `flutter analyze` after making changes to ensure zero compiler warnings or lint errors.
- **Null Safety**: Strict null safety is enabled. Do not use force unwrap (`!`) without prior null checks.
- **Imports**: Use relative imports for project files (e.g., `import '../core/theme/app_colors.dart';`) rather than package imports where appropriate, maintaining consistency with existing code.
- **Commits**: Use concise, conventional commit messages: `feat:`, `fix:`, `refactor:`, `perf:`, `docs:`.

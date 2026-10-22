# Multi-Platform Support Roadmap & Architecture

This document outlines the roadmap, architectural structure, and dependency strategy to expand **MyMusic** from Android to **Windows, Linux, macOS, and iOS**.

---

## 🗺️ Platform Support Status

| Platform | Current Status | Target Milestone | Primary UI Paradigm |
| :--- | :--- | :--- | :--- |
| **Android** | 🟢 **Supported (Active)** | Current (`v1.0.x`) | Mobile Touch & Notification MediaSession |
| **Windows** | 🟡 **Future Work (Roadmap)** | `v1.2.0` | Desktop Window / System Media Transport Controls (SMTC) |
| **Linux** | 🟡 **Future Work (Roadmap)** | `v1.2.0` | Desktop Window / MPRIS D-Bus Media Controls |
| **macOS** | 🟡 **Future Work (Roadmap)** | `v1.3.0` | Desktop Window / macOS NowPlaying & Menu Bar |
| **iOS** | 🟡 **Future Work (Roadmap)** | `v1.3.0` | Mobile Touch & iOS Lockscreen Control Center |

---

## 🏗️ Architectural Strategy for Multi-Platform

To keep the Flutter codebase clean, portable, and free of platform spaghetti, the application will use the **Platform Service Abstraction Layer** pattern:

```
                      ┌────────────────────────┐
                      │    Flutter UI Layer    │
                      │  (Responsive Widgets)  │
                      └───────────┬────────────┘
                                  │
                      ┌───────────▼────────────┐
                      │    Provider Layer      │
                      │ (Audio, Song, Tag)     │
                      └───────────┬────────────┘
                                  │
            ┌─────────────────────┴─────────────────────┐
            │                                           │
 ┌──────────▼───────────────┐               ┌───────────▼───────────────┐
 │   Portable Core Services │               │ Platform Abstraction Layer│
 │  (Drift DB, ID3 Reader,  │               │ (MediaSession, Permissions│
 │   Playback Coordinator)  │               │  Windowing & Web Bridge)  │
 └──────────────────────────┘               └───────────┬───────────────┘
                                                        │
                      ┌─────────────────────────────────┼─────────────────────────────────┐
                      │                                 │                                 │
           ┌──────────▼──────────┐           ┌──────────▼──────────┐           ┌──────────▼──────────┐
           │ Android / iOS       │           │ Windows (Desktop)   │           │ Linux (Desktop)     │
           │ JustAudioBackground │           │ SMTC Media Service  │           │ MPRIS D-Bus Service │
           │ InAppWebView (WK/AS)│           │ WebView2 Embedder   │           │ Desktop Fallback    │
           └─────────────────────┘           └─────────────────────┘           └─────────────────────┘
```

---

## 📦 Dependency Compatibility Matrix

| Package | Android | iOS | macOS | Windows | Linux | Multi-Platform Strategy |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| `just_audio` | ✅ | ✅ | ✅ | ✅ | ✅ | Universal audio backend. On Linux requires `libmpv`. |
| `just_audio_background` | ✅ | ✅ | ❌ | ❌ | ❌ | Isolate behind `MediaSessionAdapter`. On Desktop, route to native SMTC/MPRIS. |
| `drift` + `sqlite3_flutter_libs` | ✅ | ✅ | ✅ | ✅ | ✅ | Universal local relational database across all platforms. |
| `audio_metadata_reader` | ✅ | ✅ | ✅ | ✅ | ✅ | Pure Dart binary parser for ID3 tags and cover art. |
| `file_picker` | ✅ | ✅ | ✅ | ✅ | ✅ | Universal directory and file selection dialogs. |
| `path_provider` | ✅ | ✅ | ✅ | ✅ | ✅ | Universal system directories (Documents, Cache, Music). |
| `flutter_inappwebview` | ✅ | ✅ | ✅ | ✅ | ⚠️ | Official support for Android, iOS, macOS, and Windows (via Edge WebView2). |
| `permission_handler` | ✅ | ✅ | ⚠️ | ❌ | ❌ | Bypass on Desktop (Windows/Linux/macOS filesystem access does not need mobile permissions). |

---

## 🧩 Architectural Implementation Blueprint

### 1. Media Session Abstraction (System Controls)
Instead of invoking Android method channels directly in `PlaybackCoordinator`:
- **Interface**: Create an abstract `MediaSessionAdapter` interface with `updateTrack()`, `updatePlaybackState()`, and action callbacks.
- **Implementations**:
  - `AndroidMediaSessionAdapter`: Uses the current Android `com.example.mymusic/stream_media` method channel and `just_audio_background`.
  - `WindowsMediaSessionAdapter`: Uses `smtc_windows` (System Media Transport Controls).
  - `LinuxMediaSessionAdapter`: Uses MPRIS D-Bus specification.
  - `AppleMediaSessionAdapter`: Uses `MPRemoteCommandCenter` and `MPNowPlayingInfoCenter`.

### 2. Permissions Service Normalization
Desktop operating systems do not require runtime permissions for local user-selected folders:
```dart
bool get requiresRuntimeStoragePermission => 
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
```
On Windows, Linux, and macOS, `PermissionService.requestStoragePermission()` should immediately return `PermissionStatus.granted`.

### 3. Responsive UI Layout (Desktop vs Mobile)
- **Mobile (`width < 720px`)**: Current bottom navigation bar + floating mini-player.
- **Desktop (`width >= 720px`)**:
  - Left navigation rail (Home, Stream, Tags, Settings).
  - Bottom persistent full-width player bar (similar to Spotify / Apple Music desktop).
  - Split-view library browsing.

---

## 🚀 How to Enable Future Platforms (When Ready)

When you are ready to begin compiling for new platforms, Flutter enables generating the native platform scaffolding with a single command:

```bash
# Add desktop & iOS scaffolding to current project
flutter create --platforms=windows,macos,linux,ios .
```

### Platform Prerequisites
- **Windows**: Visual Studio 2022 with *Desktop development with C++*.
- **macOS / iOS**: macOS device with Xcode installed (`xcode-select --install`).
- **Linux**: Clang, CMake, GTK development headers, and MPV library (`sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev libmpv-dev`).

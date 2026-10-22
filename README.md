<div align="center">

# 🎵 MyMusic

### *A modern, retro-futuristic offline music player with tag-based organization and ad-free web streaming.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## 🌟 Overview

**MyMusic** combines the speed and reliability of a local offline audio library with the discovery potential of online streaming. Designed with a sleek dark-mode glassmorphism aesthetic, it re-imagines how you organize music through **tags** instead of cumbersome nested folders.

---

## ✨ Features

- 🎧 **Offline Audio Playback**: Supports `.mp3`, `.m4a`, `.flac`, `.wav`, `.ogg`, and `.aac` with automatic ID3 metadata extraction and cover art caching.
- 🏷️ **Tag-Based Organization**: Assign custom colored tags (e.g. *Chill, Coding, Gym, Focus*) to tracks for instant dynamic playlists.
- 🌐 **Ad-Free Web Streaming**: Embedded YouTube Music client with built-in ad-blocking scriptlets and background audio playback.
- 🎛️ **Audio Coordination Mutex**: Smart `PlaybackCoordinator` ensures seamless transitions between offline files and web streams without dual audio conflicts.
- 📱 **Background & Lock Screen Controls**: Full Android MediaSession support with lock-screen playback controls and notification integration.
- 🎨 **Retro-Futuristic Visuals**: Glassmorphic cards, vinyl spinning animations, waveform indicators, and smooth micro-interactions.
- ⚡ **Reactive SQLite Persistence**: Powered by **Drift (SQLite)** for lightning-fast queries, smooth tag counts, and instant library updates.
- 🔒 **Privacy Focused**: No telemetry, no ads, no trackers. Your library stays 100% on your device.

---

## 🗺️ Platform Support & Roadmap

MyMusic is currently focused on Android, with full desktop (Windows, Linux, macOS) and iOS support planned as future releases:

| Platform | Status | Architecture & Support Details |
| :--- | :---: | :--- |
| 📱 **Android** | 🟢 **Supported** | Native MediaSession, JustAudio background service, InAppWebView stream bridge. |
| 🪟 **Windows** | 🟡 *In Roadmap* | Windows SMTC media transport controls, WebView2 embedder. |
| 🐧 **Linux** | 🟡 *In Roadmap* | MPRIS D-Bus media integration, MPV audio engine backend. |
| 🍏 **iOS** | 🟡 *In Roadmap* | iOS Lockscreen Control Center, AVPlayer audio session. |
| 🍎 **macOS** | 🟡 *In Roadmap* | macOS NowPlaying integration, menu bar quick controls. |

👉 *For detailed multi-platform architecture and instructions on enabling new targets, see [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md).*

---

## 🏗️ Architecture & Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) & [Dart](https://dart.dev) | Cross-platform UI toolkit |
| **Audio Engine** | [just_audio](https://pub.dev/packages/just_audio) & [audio_session](https://pub.dev/packages/audio_session) | Gapless playback, audio focus handling & ducking |
| **Notification / Session**| [just_audio_background](https://pub.dev/packages/just_audio_background) | Android MediaSession and lock screen notification |
| **Database** | [Drift](https://drift.simonbinder.eu/) (SQLite) | Reactive local database with type-safe DAOs |
| **Streaming** | [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) | YouTube Music web bridge with custom JS ad-blockers |
| **State Management** | [Provider](https://pub.dev/packages/provider) | Clean separation of business logic and UI viewmodels |
| **Metadata** | [audio_metadata_reader](https://pub.dev/packages/audio_metadata_reader) | High performance ID3 and embedded cover art extraction |

For an in-depth breakdown of the codebase architecture, read [CODEBASE_ARCHITECTURE.md](CODEBASE_ARCHITECTURE.md).

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11` or higher)
- [Android Studio](https://developer.android.com/studio) / Android SDK (API 24+)
- A physical Android device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/TamimLikhon/mymusiccc.git
   cd mymusiccc
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Generate Drift Database Code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🤖 Contributing with Claude & AI Assistants

This repository includes a dedicated [CLAUDE.md](CLAUDE.md) file configured for **Claude Code** and Anthropic AI tools.

If you are using the **Claude Code CLI**:
```bash
# Install Claude Code globally (if not already installed)
npm install -g @anthropic-ai/claude-code

# Launch Claude Code inside this project
claude
```
Claude will automatically read `CLAUDE.md`, understand the project structure, follow architecture guidelines, and assist in fixing bugs, writing features, or refactoring.

Check out [CONTRIBUTING.md](CONTRIBUTING.md) for full contribution guidelines.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

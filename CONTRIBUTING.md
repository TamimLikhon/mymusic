# Contributing to MyMusic

Thank you for your interest in contributing to **MyMusic**! Whether you are an individual developer or utilizing AI coding agents like **Claude**, your contributions are very welcome.

---

## 🧭 Code of Conduct

Please maintain a respectful, welcoming, and inclusive atmosphere when opening issues, reviewing PRs, and participating in discussions.

---

## 🛠️ Development Setup

1. **Fork and Clone**:
   ```bash
   git clone https://github.com/<your-username>/mymusiccc.git
   cd mymusiccc
   ```
2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate Drift SQLite Code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Verify Analysis**:
   ```bash
   flutter analyze
   ```

---

## 🤖 Contributing with Claude / AI

We actively support contributions made with Anthropic's **Claude** and **Claude Code**:
- Refer to [CLAUDE.md](CLAUDE.md) at the repository root. Claude uses this file to understand the architecture, commands, and rules.
- When prompting Claude to implement a feature or fix a bug, instruct it to run:
  1. `dart run build_runner build --delete-conflicting-outputs` (if database tables/daos changed)
  2. `flutter analyze` to ensure no lint or type warnings are introduced.
- In your PR description, mention if the change was co-authored or generated with Claude.

---

## 📋 Pull Request Guidelines

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feat/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```
2. **Follow Coding Conventions**:
   - **Architecture**: Keep UI widgets separate from database & audio player logic. Use `Provider` viewmodels (`AudioProvider`, `SongProvider`, `TagProvider`).
   - **Theming**: Always use `AppColors` and `AppTypography` from `lib/core/theme/` rather than hardcoded colors or ad-hoc text styles.
   - **Audio Mutex**: Do not bypass `PlaybackCoordinator` or `UnifiedAudioService` when initiating playback.
   - **Navigation Tabs**: Keep the `Offstage` tab shell intact in `lib/app.dart` to prevent web streaming playback from terminating on tab switches.
3. **Run Checks Before Committing**:
   ```bash
   flutter analyze
   flutter test
   ```
4. **Submit Your PR**:
   - Write a clear title and description detailing what changed and why.
   - Reference any relevant open issues (e.g., `Fixes #12`).

---

## 🐛 Reporting Bugs & Requesting Features

- Use [GitHub Issues](https://github.com/TamimLikhon/mymusiccc/issues) to report bugs or propose new features.
- Please include your device model, Android version, and steps to reproduce any playback or UI issues.

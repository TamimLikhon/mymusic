# MyMusic App — UI, Navigation & Permission Audit

## Summary

After reviewing all pages, widgets, providers, services, and manifests, here are the issues and missing pieces found.

---

## 🔴 Critical Issues (Broken / Crashes)

### 1. `TagDetailPage` — Crash if tag is deleted while open

```dart
// tag_detail_page.dart L47
final tag = tagProvider.tags.firstWhere((t) => t.id == widget.tagId);
```

This will throw `StateError` if the tag is deleted while the user is on the page (no `orElse` guard).

### 2. `SettingsPage` — "Clear All Data" is unimplemented

```dart
// settings_page.dart L147
// TODO: Implement clear all data
Navigator.pop(context);
```

Pressing "Clear" shows a snackbar but does **nothing** — data is not cleared.

### 3. `FullPlayerPage` — "Queue" button is unimplemented

```dart
// full_player_page.dart L210–212
onPressed: () {
  // TODO: Show queue
},
```

The Queue button in the full player does nothing.

### 4. `AudioProvider` uses a raw `AudioPlayer` — NOT the `AudioPlayerService`

`AudioProvider` (`audio_provider.dart L8`) creates its own `AudioPlayer` directly and never uses `AudioPlayerService`. This means:

- Audio session configuration (duck on interruption, pause on noise) is **completely bypassed**
- The `AudioPlayerService` class is dead code (never instantiated anywhere)

### 5. `SongImportService` — no `READ_MEDIA_AUDIO` / `READ_EXTERNAL_STORAGE` permission in `AndroidManifest.xml`

The manifest has `WAKE_LOCK`, `FOREGROUND_SERVICE`, and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, but is **missing**:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<!-- fallback for Android < 13 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<!-- fallback for Android < 10 -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
```

Without these, even after the runtime permission dialog, Android may reject file reads silently.

### 6. Missing `POST_NOTIFICATIONS` permission in `AndroidManifest.xml`

Runtime permission is requested via `PermissionService.requestNotificationPermission()`, but `android.permission.POST_NOTIFICATIONS` is not declared in the manifest. On Android 13+ this **must** be declared or the runtime request is ignored.

---

## 🟠 Navigation Issues

### 7. `FullPlayerPage` opens as a `ModalBottomSheet` — back navigation broken

Tapping mini-player shows `FullPlayerPage` via `showModalBottomSheet`. The `TagDetailPage` opened from `AllTagsPage` / Vibe tag chips uses `Navigator.pushNamed('/tag/...')` — **but** `onGenerateRoute` only works when `MaterialApp` does a full push. The `_AppShell._buildPage()` also handles `/tag/` routes by switching state, so there are two parallel navigation systems that can get out of sync.

### 8. No back-button / close button on `FullPlayerPage`

The full player is a modal sheet with just a drag handle. There is no explicit **close/back button** for users who don't know about the swipe-down gesture.

### 9. `Sidebar` — Tags listed under nav but navigating to a tag via sidebar doesn't highlight it as active

When navigating to `/tag/<id>` via the sidebar, `_buildItem` checks `currentRoute == route` but sidebar items for tags use a flat route string. The "Tags" main item won't be highlighted either.

### 10. Settings → About navigation uses `Navigator.pushNamed(context, '/about')` but About is already in sidebar

This creates a second `AboutPage` pushed on top of the modal-sheet-based navigation stack. The back arrow will appear but the sidebar won't reflect the correct state.

### 11. No dedicated **Search** feature

The app has no search bar to find songs by title/artist. With a large library this is a significant UX gap.

---

## 🟡 UI / UX Missing Features

### 12. Vibe page — no shuffle-all button

There is a `shuffleAllSongs()` method in `AudioProvider` but the Vibe page has no UI button to trigger it (only tag pages have shuffle).

### 13. MiniPlayer — no **previous** button

The mini player only shows play/pause and next. The previous track control is only accessible in the full player.

### 14. MiniPlayer — not dismissible / no swipe-to-close

Users cannot dismiss the mini player once a song is loaded without going into the full player and stopping playback manually.

### 15. Song tile — no way to see song duration in the list

`SongTile` doesn't show the duration. The data is available (`song.duration`) but unused in the tile.

### 16. `SettingsPage` — "Scan Directories" tile does nothing

```dart
onTap: () {
  // TODO: Allow customizing scan directories
},
```

### 17. No **onboarding / welcome screen**

First-time users see a blank "No songs yet" empty state with a scan button. There is no explanation of the permission that will be requested, and no onboarding flow to guide the user.

### 18. `PermissionService` — no "permanently denied" handling

If a user denies the permission permanently, the app silently fails. There is no prompt to open app settings via `openAppSettings()` (from `permission_handler`).

### 19. `VibePage` — scan snackbar counts wrong on first scan

```dart
final count = context.read<SongProvider>().songs.length; // total songs
```

This shows _total_ songs, not _newly imported_ songs. `SongProvider.scannedCount` exists for this but isn't used.

### 20. No volume control exposed in UI

`AudioProvider` has no volume state; `AudioPlayerService.setVolume` exists but the provider never exposes it.

### 21. Tags page — no **sort** option for tags or songs within a tag

### 22. Full player — song info text can overflow on long titles (only 2 lines max, truncated ellipsis)

This is minor, but tapping the title to expand it would be a nice-to-have.

---

## 🟢 Minor / Polish

| #   | Issue                                                                                                                                                           |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 23  | `pubspec.yaml` description is `"A new Flutter project."` — should be updated                                                                                    |
| 24  | `app.dart` title is `'MyMusic'` but manifest label is `'mymusic'` (lowercase) — inconsistent                                                                    |
| 25  | `AudioProvider.toggleShuffle()` restores original order sorted by `added_at` when unshuffling — this loses the user's intended play order if they browsed a tag |
| 26  | `google_fonts` is listed as a dependency but no custom Google Font is actually loaded in `AppTypography`                                                        |
| 27  | `file_picker` is listed as a dependency but never used anywhere                                                                                                 |
| 28  | `AudioPlayerService` is a fully written service but is dead code — never used                                                                                   |

---

## Priority Fix Recommendations

1. **Add missing manifest permissions** (`READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`, `POST_NOTIFICATIONS`) — highest priority, breaks core functionality on Android 13+
2. **Fix `AudioProvider` to use `AudioPlayerService`** so audio session and interruption handling actually work
3. **Implement "Clear All Data"** in settings
4. **Add `orElse` guard** in `TagDetailPage` to prevent crashes
5. **Add `openAppSettings()` fallback** when permission is permanently denied
6. **Add a close button** to `FullPlayerPage`
7. **Use `scannedCount`** in scan snackbar message
8. **Add shuffle-all button** to VibePage

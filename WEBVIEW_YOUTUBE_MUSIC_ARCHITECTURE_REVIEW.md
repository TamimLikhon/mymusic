# WebView YouTube Music architecture review

## Status

The stream-session proposal has been implemented in the app. The old WebView
plus DOM polling plus looping silent-audio design has been removed from the
active code path.

The feature remains experimental because YouTube Music is an externally
controlled website. MyMusic now aims to fail predictably when the website DOM,
the Android WebView renderer, or the trusted-message feature is unavailable.

## Original problem

The previous design had two playback owners:

```text
AudioProvider ───── shared just_audio player ───── native notification
WebAudioService ─── looping silence.mp3 ────────── WebView controls
```

That allowed a local-player event to trigger WebView playback, or WebView
metadata to replace local audio with a silent source. It also relied on global
JavaScript handlers, 500 ms polling, auto-clicking buttons, and overriding
`HTMLMediaElement.play`.

## Proposed architecture

```text
Flutter UI / system controls
            │
            ▼
  PlaybackCoordinator (single authority)
      ├── Local playback: just_audio
      ├── Stream session: trusted WebView bridge
      └── Android MediaSession: Kotlin adapter
```

The proposal required mutually exclusive local and stream playback; a
versioned bridge protocol; lazy WebView creation; renderer recovery; navigation
restrictions; capability tiers; and no silent audio workaround.

## Implemented changes

### Playback ownership

- `main.dart` creates and initializes `StreamSessionController` and
  `PlaybackCoordinator`, then supplies the coordinator to `AudioProvider`.
- `PlaybackCoordinator` serializes transitions between local and stream
  playback.
- Starting stream playback stops the local player first.
- Starting local playback requests a stream pause and requires a confirmed
  stopped state. If the stream cannot confirm this, local playback is refused
  instead of risking two audible sources.
- The local mini player is hidden whenever the local session is inactive.
- `WebAudioService`, `silence.mp3`, and the shared-player stream workaround
  were removed.

### Trusted stream bridge

- `StreamSessionController` is the only owner of stream bridge state.
- `WebMessageListener` is restricted to `https://music.youtube.com` and Dart
  also validates origin and main-frame status.
- Messages must contain `version`, `documentGeneration`, `sequenceNumber`,
  `type`, and `payload`. Invalid, stale, replayed, and unsupported-version
  messages are discarded.
- The page adapter is event-driven: media events plus one `MutationObserver`
  are coalesced with `requestAnimationFrame` and a short debounce.
- Metadata and playback state are independent. Receiving a title does not mark
  the stream as playing.
- Commands have IDs, acknowledgements, and a timeout.

### WebView lifecycle and navigation

- The Stream WebView is created only after the Stream tab is first opened and
  is retained only for the current app process.
- `onUpdateVisitedHistory` handles YouTube Music SPA navigation.
- `onRenderProcessGone` invalidates the bridge, clears stream state, recreates
  the WebView, and restores the last approved music URL.
- Only `https://music.youtube.com` is eligible for bridge injection.
- `https://accounts.google.com` is allowed only for sign-in navigation and has
  no bridge or native media session.
- Unknown top-level destinations open in the system browser.
- Mixed content is disabled, the forced stale user agent was removed, and the
  stream request-interception/ad-block path was removed.

### Android system media controls

- `MainActivity` now implements the
  `com.example.mymusic/stream_media` method channel.
- Its Android framework `MediaSession` forwards play, pause, and stop commands
  to Flutter.
- Flutter updates the session only after a trusted WebView state change.
- Renderer recovery and non-music navigation clear the stream media session.

### Capability tiers

- **Full:** trusted bridge and native controls are available.
- **Page-only:** YouTube Music remains usable, but native stream controls are
  unavailable.
- **Unavailable:** a load or renderer failure presents recovery UI.

## Removed legacy behavior

- Global `flutter_inappwebview.callHandler` stream handlers.
- DOM polling loops and autoplay/button-click hacks.
- `HTMLMediaElement.prototype.play` replacement.
- Per-resource `shouldInterceptRequest` callbacks.
- Silent MP3 media-notification emulation.
- Stream-specific ad-block service and blocklist updater.

## Verification

- `flutter analyze` completed with no issues.
- `flutter test test/stream_bridge_message_test.dart` passed. The test covers
  bridge parsing, document generation, sequence ordering, and protocol-version
  rejection.

## Remaining validation

The implementation still needs physical Android-device testing across Android
and System WebView versions. Test sign-in, network switching, Bluetooth and
headset controls, lock/unlock, audio focus, low-memory renderer termination,
and background/foreground transitions. A local HTML player fixture should also
be added for end-to-end page-adapter contract tests.

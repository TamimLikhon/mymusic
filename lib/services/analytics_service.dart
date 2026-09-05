import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized wrapper around [FirebaseAnalytics].
///
/// What gets tracked automatically by the SDK (no code needed):
/// • Session duration   → Analytics > Engagement > Session duration
/// • Total use time     → Analytics > Engagement > Engaged sessions
/// • App opens count    → Analytics > Events > session_start
/// • User retention     → Analytics > Retention
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ── Song tracking ──────────────────────────────────────────────────────────

  /// Fired every time playback starts on a new song.
  /// Visible in Firebase Console: Events → song_played
  /// Drill down to see song_title and artist_name parameters.
  Future<void> logSongPlayed({
    required String title,
    required String artist,
  }) async {
    print('🔥 [Firebase Analytics] Logging event: song_played (title: $title, artist: $artist)');
    await _analytics.logEvent(
      name: 'song_played',
      parameters: {
        'song_title': title.isEmpty ? 'Unknown' : title,
        'artist_name': artist.isEmpty ? 'Unknown' : artist,
      },
    );
  }

  // ── Import tracking ────────────────────────────────────────────────────────

  /// Fired after a scan + import completes.
  /// [count] = number of NEW songs added in this import batch.
  Future<void> logSongImported({required int count}) async {
    print('🔥 [Firebase Analytics] Logging event: song_imported (count: $count)');
    await _analytics.logEvent(
      name: 'song_imported',
      parameters: {'songs_count': count},
    );
  }

  // ── Tag tracking ───────────────────────────────────────────────────────────

  /// Fired when the user creates a new tag/playlist.
  Future<void> logTagCreated({required String tagName}) async {
    print('🔥 [Firebase Analytics] Logging event: tag_created (tagName: $tagName)');
    await _analytics.logEvent(
      name: 'tag_created',
      parameters: {'tag_name': tagName},
    );
  }

  // ── Screen tracking ────────────────────────────────────────────────────────

  /// Call when navigating to a screen that is not auto-detected by the observer.
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ── Navigator observer ─────────────────────────────────────────────────────

  /// Add this to [MaterialApp.navigatorObservers] in app.dart.
  /// It automatically fires screen_view events on every route change.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}

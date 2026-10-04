import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'data/database/app_database.dart';
import 'providers/song_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/audio_provider.dart';
import 'services/unified_audio_service.dart';
import 'services/playback_coordinator.dart';
import 'services/ad_block/ad_block_service.dart';
import 'services/stream/stream_session_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // just_audio_background owns notification controls for local music only.
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.mymusic.audio',
      androidNotificationChannelName: 'MyMusic Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e, st) {
    debugPrint('JustAudioBackground.init error: $e\n$st');
  }

  try {
    // Create the single shared AudioPlayer instance.
    await UnifiedAudioService.instance.initialize();
  } catch (e, st) {
    debugPrint('UnifiedAudioService.initialize error: $e\n$st');
  }

  try {
    // Pre-compile ad-block rules before the WebView is created.
    AdBlockService.instance.initialize();
  } catch (e, st) {
    debugPrint('AdBlockService.initialize error: $e\n$st');
  }

  final database = AppDatabase();
  final streamSession = StreamSessionController();
  final playbackCoordinator = PlaybackCoordinator(streamSession: streamSession);
  
  try {
    await playbackCoordinator.initialize();
  } catch (e, st) {
    debugPrint('playbackCoordinator.initialize error: $e\n$st');
  }
  
  final audioProvider = AudioProvider(database, playbackCoordinator);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (_) => SongProvider(database)),
        ChangeNotifierProvider(create: (_) => TagProvider(database)),
        ChangeNotifierProvider.value(value: audioProvider),
        ChangeNotifierProvider.value(value: streamSession),
        ChangeNotifierProvider.value(value: playbackCoordinator),
      ],
      child: MyMusicApp(audioProvider: audioProvider),
    ),
  );
}

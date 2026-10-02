import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'data/database/app_database.dart';
import 'providers/song_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/audio_provider.dart';
import 'services/unified_audio_service.dart';
import 'services/playback_coordinator.dart';
import 'services/stream/stream_session_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // just_audio_background owns notification controls for local music only.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mymusic.audio',
    androidNotificationChannelName: 'MyMusic Playback',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: false,
  );

  // Create the single shared AudioPlayer first — both the local-music layer
  // and the WebView's lock screen session use this one instance, satisfying
  // the just_audio_background "single player at a time" constraint.
  await UnifiedAudioService.instance.initialize();

  final database = AppDatabase();
  final streamSession = StreamSessionController();
  final playbackCoordinator = PlaybackCoordinator(streamSession: streamSession);
  await playbackCoordinator.initialize();
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

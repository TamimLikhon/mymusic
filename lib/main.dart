import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'data/database/app_database.dart';
import 'providers/song_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/audio_provider.dart';
import 'services/unified_audio_service.dart';
import 'services/web_audio_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize just_audio_background for notification controls (used by both
  // the local music engine and the WebView's silent-audio lock screen trick).
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mymusic.audio',
    androidNotificationChannelName: 'MyMusic Playback',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
  );

  // Create the single shared AudioPlayer first — both the local-music layer
  // and the WebView's lock screen session use this one instance, satisfying
  // the just_audio_background "single player at a time" constraint.
  await UnifiedAudioService.instance.initialize();

  final database = AppDatabase();
  final audioProvider = AudioProvider(database);
  final webAudioService = WebAudioService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (_) => SongProvider(database)),
        ChangeNotifierProvider(create: (_) => TagProvider(database)),
        ChangeNotifierProvider.value(value: audioProvider),
        ChangeNotifierProvider.value(value: webAudioService),
      ],
      child: MyMusicApp(audioProvider: audioProvider),
    ),
  );
}

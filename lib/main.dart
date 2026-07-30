import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'data/database/app_database.dart';
import 'providers/song_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/audio_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize just_audio_background for notification controls
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mymusic.audio',
    androidNotificationChannelName: 'MyMusic Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (_) => SongProvider(database)),
        ChangeNotifierProvider(create: (_) => TagProvider(database)),
        ChangeNotifierProvider(create: (_) => AudioProvider(database)),
      ],
      child: const MyMusicApp(),
    ),
  );
}

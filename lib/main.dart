import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'data/database/app_database.dart';
import 'providers/song_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/audio_provider.dart';
import 'services/unified_audio_service.dart';
import 'services/web_audio_service.dart';
import 'services/ad_block/ad_block_service.dart';
import 'services/ad_block/blocklist_updater.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize just_audio_background for notification controls (used by both
  // the local music engine and the WebView's silent-audio lock screen trick).
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
  final audioProvider = AudioProvider(database);
  final webAudioService = WebAudioService();
  
  final adBlockService = AdBlockService();
  await adBlockService.initialize();
  
  final prefs = await SharedPreferences.getInstance();
  BlocklistUpdater(adBlockService, prefs).checkAndUpdate();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (_) => SongProvider(database)),
        ChangeNotifierProvider(create: (_) => TagProvider(database)),
        ChangeNotifierProvider.value(value: audioProvider),
        ChangeNotifierProvider.value(value: webAudioService),
        ChangeNotifierProvider.value(value: adBlockService),
      ],
      child: MyMusicApp(audioProvider: audioProvider),
    ),
  );
}

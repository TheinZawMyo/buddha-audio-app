import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'src/core/config/app_config.dart';
import 'src/player/audio_player_handler.dart';
import 'src/player/player_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Background playback + lock-screen/notification controls.
  final handler = await AudioService.init(
    builder: AudioPlayerHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'mm.buddha.audio.channel',
      androidNotificationChannelName: 'ဗုဒ္ဓသံသာ အသံဖွင့်ခြင်း',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        audioPlayerHandlerProvider.overrideWithValue(handler),
      ],
      child: const BuddhaAudioApp(),
    ),
  );
}

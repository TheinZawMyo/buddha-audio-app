import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'src/core/config/app_config.dart';
import 'src/core/localization/locale_controller.dart';
import 'src/player/audio_player_handler.dart';
import 'src/player/audio_library.dart';
import 'src/player/player_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final audioLibrary = AudioLibrary();
  final localeCode = prefs.getString(appLocaleKey) ?? 'my';
  audioLibrary.languageCode = localeCode;
  await audioLibrary.initialize();

  final isEnglish = localeCode == 'en';

  // Background playback + lock-screen/notification controls.
  final handler = await AudioService.init(
    builder: AudioPlayerHandler.new,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'mm.buddha.audio.channel',
      androidNotificationChannelName: isEnglish
          ? 'Buddha Dhamma Playback'
          : 'ဗုဒ္ဓသံသာ အသံဖွင့်ခြင်း',
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
        audioLibraryProvider.overrideWithValue(audioLibrary),
      ],
      child: const BuddhaAudioApp(),
    ),
  );
}

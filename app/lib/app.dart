import 'package:flutter/material.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/shell/app_shell.dart';

class BuddhaAudioApp extends StatelessWidget {
  const BuddhaAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ဗုဒ္ဓသံသာ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ဆက်တင်များ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'အက်ပ်',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('ဗားရှင်း'),
            trailing: Text(
              '1.0.0 MVP',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('နောက်ခံဖွင့်ခြင်း'),
            trailing: Text(
              'အမြဲဖွင့်ထားနိုင်သည်',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = <({String title, String body})>[
      (title: l10n.privacyDataTitle, body: l10n.privacyDataBody),
      (title: l10n.privacyLocalTitle, body: l10n.privacyLocalBody),
      (title: l10n.privacyNetworkTitle, body: l10n.privacyNetworkBody),
      (title: l10n.privacySharingTitle, body: l10n.privacySharingBody),
      (title: l10n.privacyChildrenTitle, body: l10n.privacyChildrenBody),
      (title: l10n.privacyChangesTitle, body: l10n.privacyChangesBody),
      (title: l10n.privacyContactTitle, body: l10n.privacyContactBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            l10n.privacyPolicyLastUpdated,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.privacyIntro,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          for (final section in sections) ...[
            const SizedBox(height: 24),
            Text(
              section.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              section.body,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

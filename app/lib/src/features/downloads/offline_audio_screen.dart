import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../player/audio_library.dart';
import '../../player/player_controller.dart';
import '../widgets/audio_list_tile.dart';

class OfflineAudioScreen extends ConsumerWidget {
  const OfflineAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final audios = ref.watch(offlineAudiosProvider);
    final downloadedItems = audios.asData?.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineTitle)),
      body: audios.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.downloadsReadError)),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    l10n.downloadsEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final audio = items[index];
                  return AudioListTile(
                    audio: audio,
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .playAudioList(items, startIndex: index),
                    trailing: IconButton(
                      tooltip: l10n.deleteTooltip,
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        await ref.read(audioLibraryProvider).delete(audio);
                        ref.invalidate(offlineAudiosProvider);
                        ref.invalidate(audioDownloadedProvider(audio));
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: downloadedItems?.isNotEmpty == true
          ? FloatingActionButton.small(
              tooltip: l10n.playAllTooltip,
              onPressed: () => ref
                  .read(playerControllerProvider.notifier)
                  .playAudioList(downloadedItems!),
              child: const Icon(Icons.play_arrow_rounded),
            )
          : null,
    );
  }
}

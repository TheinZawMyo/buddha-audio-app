import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../player/audio_library.dart';
import '../../player/player_controller.dart';
import '../widgets/audio_list_tile.dart';

class OfflineAudioScreen extends ConsumerWidget {
  const OfflineAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audios = ref.watch(offlineAudiosProvider);
    final downloadedItems = audios.asData?.value;
    return Scaffold(
      appBar: AppBar(title: const Text('ဒေါင်းလုဒ်များ')),
      body: audios.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('သိမ်းထားသော အသံများကို ဖတ်မရပါ')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'ဒေါင်းလုဒ်ထားသော အသံ မရှိသေးပါ။\nအသံအသေးစိတ်စာမျက်နှာမှ ဒေါင်းလုဒ်လုပ်နိုင်ပါသည်။',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedText),
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
                      tooltip: 'ဖျက်ရန်',
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
              tooltip: 'ဒေါင်းလုဒ်အားလုံး ဖွင့်ရန်',
              onPressed: () => ref
                  .read(playerControllerProvider.notifier)
                  .playAudioList(downloadedItems!),
              child: const Icon(Icons.play_arrow_rounded),
            )
          : null,
    );
  }
}

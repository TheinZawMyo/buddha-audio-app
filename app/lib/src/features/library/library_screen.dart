import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../player/audio_library.dart';
import '../../player/player_controller.dart';
import '../favorites/favorites_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('သိမ်းဆည်းထားသည်'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.favorite_outline_rounded),
                text: 'ကြိုက်နှစ်သက်',
              ),
              Tab(icon: Icon(Icons.download_outlined), text: 'ဒေါင်းလုဒ်'),
            ],
          ),
        ),
        body: const TabBarView(children: [_FavoritesTab(), _DownloadsTab()]),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoriteAudiosProvider);
    final slugs = ref.watch(favoritesProvider);
    if (slugs.isEmpty) {
      return const EmptyView(
        icon: Icons.favorite_border_rounded,
        title: 'ကြိုက်နှစ်သက်သော မရှိသေးပါ',
        subtitle: 'နှစ်သက်သော တရားတော်များကို နှလုံးသွင်း သိမ်းဆည်းနိုင်ပါသည်။',
      );
    }
    return async.when(
      loading: () => const LoadingView(),
      error: (error, _) => AudioErrorView(
        message: error,
        onRetry: () => ref.invalidate(favoriteAudiosProvider),
      ),
      data: (audios) => audios.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'ဖိုင်များ ရှာမတွေ့ပါ',
              subtitle: 'ခဏစောင့်ပြီး ထပ်ကြည့်ပါ။',
            )
          : ListView.builder(
              itemCount: audios.length,
              itemBuilder: (context, index) => AudioListTile(
                audio: audios[index],
                trailing: IconButton(
                  onPressed: () => ref
                      .read(playerControllerProvider.notifier)
                      .playAudioList(audios, startIndex: index),
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ),
    );
  }
}

class _DownloadsTab extends ConsumerWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offlineAudiosProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          const Center(child: Text('သိမ်းထားသော အသံများကို ဖတ်မရပါ')),
      data: (audios) => audios.isEmpty
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
              itemCount: audios.length,
              itemBuilder: (context, index) {
                final audio = audios[index];
                return AudioListTile(
                  audio: audio,
                  onTap: () => ref
                      .read(playerControllerProvider.notifier)
                      .playAudioList(audios, startIndex: index),
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
    );
  }
}

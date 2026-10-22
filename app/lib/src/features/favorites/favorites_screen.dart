import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../player/player_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoriteAudiosProvider);
    final slugs = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ကြိုက်နှစ်သက်သော')),
      body: slugs.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'ကြိုက်နှစ်သက်သော မရှိသေးပါ',
              subtitle: 'နှစ်သက်သော တရားတော်များကို နှလုံးသွင်း သိမ်းဆည်းနိုင်ပါသည်။',
            )
          : async.when(
              loading: () => const LoadingView(),
              error: (error, _) => AudioErrorView(
                message: error,
                onRetry: () => ref.invalidate(favoriteAudiosProvider),
              ),
              data: (audios) {
                if (audios.isEmpty) {
                  return const EmptyView(
                    icon: Icons.favorite_border_rounded,
                    title: 'ဖိုင်များ ရှာမတွေ့ပါ',
                    subtitle: 'ခဏစောင့်ပြီး ထပ်ကြည့်ပါ။',
                  );
                }
                return ListView.builder(
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
                );
              },
            ),
    );
  }
}

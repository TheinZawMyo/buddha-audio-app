import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../player/player_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(favoriteAudiosProvider);
    final slugs = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryFavoritesTab)),
      body: slugs.isEmpty
          ? EmptyView(
              icon: Icons.favorite_border_rounded,
              title: l10n.favoritesEmptyTitle,
              subtitle: l10n.favoritesEmptySubtitle,
            )
          : async.when(
              loading: () => const LoadingView(),
              error: (error, _) => AudioErrorView(
                message: error,
                onRetry: () => ref.invalidate(favoriteAudiosProvider),
              ),
              data: (audios) {
                if (audios.isEmpty) {
                  return EmptyView(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.filesNotFoundTitle,
                    subtitle: l10n.filesNotFoundSubtitle,
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

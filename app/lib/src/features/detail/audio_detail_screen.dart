import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../data/catalog_providers.dart';
import '../../data/models/catalog_models.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../player/player_controller.dart';
import '../../player/audio_library.dart';
import '../favorites/favorites_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/media_widgets.dart';
import '../widgets/state_views.dart';

class AudioDetailScreen extends ConsumerWidget {
  const AudioDetailScreen({super.key, required this.slug});

  final String slug;

  static Future<void> open(BuildContext context, String slug) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => AudioDetailScreen(slug: slug)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(audioDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, _) => AudioErrorView(
          message: error,
          onRetry: () => ref.invalidate(audioDetailProvider(slug)),
        ),
        data: (audio) => _DetailBody(audio: audio),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = ref.watch(playerControllerProvider);
    final isCurrent = player.current?.id == audio.id && player.playing;
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(audio.slug);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Hero(
              tag: 'cover-${audio.slug}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: CoverImage(
                  url: audio.coverImageUrl,
                  size: (MediaQuery.sizeOf(context).width - 96)
                      .clamp(160.0, 420.0)
                      .toDouble(),
                  borderRadius: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            audio.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${audio.teacher.shortName ?? audio.teacher.name} · ${audio.type.name} · ${formatDurationSeconds(audio.durationSeconds)}',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
          if (audio.categories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in audio.categories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => ref
                      .read(playerControllerProvider.notifier)
                      .playAudioList([audio]),
                  icon: Icon(
                    isCurrent ? Icons.graphic_eq : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    isCurrent ? l10n.detailListening : l10n.detailListen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _OfflineAudioAction(audio: audio),
              IconButton.outlined(
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).toggle(audio),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.primary : AppColors.dark,
                ),
              ),
            ],
          ),
          if (audio.description != null && audio.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.detailDescription,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              audio.description!,
              style: const TextStyle(
                color: AppColors.mutedText,
                height: 1.6,
                fontSize: 14.5,
              ),
            ),
          ],
          _MoreFromTeacher(current: audio),
        ],
      ),
    );
  }
}

class _OfflineAudioAction extends ConsumerWidget {
  const _OfflineAudioAction({required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final downloaded = ref.watch(audioDownloadedProvider(audio));
    return downloaded.when(
      loading: () => const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (isDownloaded) => IconButton.outlined(
        tooltip: isDownloaded
            ? l10n.detailDownloadedTooltip
            : l10n.detailDownloadTooltip,
        onPressed: isDownloaded
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final repository = ref.read(catalogRepositoryProvider);
                  final url = await repository.getPlaybackUrl(audio);
                  await ref
                      .read(audioLibraryProvider)
                      .startDownload(audio, url);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.detailDownloadStarted)),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.detailDownloadFailed)),
                  );
                }
              },
        icon: Icon(
          isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
        ),
      ),
    );
  }
}

class _MoreFromTeacher extends ConsumerWidget {
  const _MoreFromTeacher({required this.current});

  final Audio current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(
      audiosProvider(AudiosQuery(teacher: current.teacher.slug)),
    );

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final others = state.items
            .where((a) => a.slug != current.slug)
            .take(6)
            .toList();
        if (others.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.detailMoreFromTeacher(current.teacher.name),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            for (final (index, audio) in others.indexed)
              AudioListTile(
                audio: audio,
                trailing: IconButton(
                  onPressed: () => ref
                      .read(playerControllerProvider.notifier)
                      .playAudioList(others, startIndex: index),
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

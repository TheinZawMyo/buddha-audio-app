import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:background_downloader/background_downloader.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalog_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../player/audio_library.dart';
import '../../player/player_controller.dart';
import '../favorites/favorites_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.favorite_outline_rounded),
                text: l10n.libraryFavoritesTab,
              ),
              Tab(
                icon: const Icon(Icons.download_outlined),
                text: l10n.libraryDownloadsTab,
              ),
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
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(favoriteAudiosProvider);
    final slugs = ref.watch(favoritesProvider);
    if (slugs.isEmpty) {
      return EmptyView(
        icon: Icons.favorite_border_rounded,
        title: l10n.favoritesEmptyTitle,
        subtitle: l10n.favoritesEmptySubtitle,
      );
    }
    return async.when(
      loading: () => const LoadingView(),
      error: (error, _) => AudioErrorView(
        message: error,
        onRetry: () => ref.invalidate(favoriteAudiosProvider),
      ),
      data: (audios) => audios.isEmpty
          ? EmptyView(
              icon: Icons.favorite_border_rounded,
              title: l10n.filesNotFoundTitle,
              subtitle: l10n.filesNotFoundSubtitle,
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
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(offlineAudiosProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.downloadsReadError)),
      data: (audios) => ValueListenableBuilder<List<AudioDownloadEntry>>(
        valueListenable: ref.watch(audioLibraryProvider).downloadsNotifier,
        builder: (context, downloads, _) {
          if (downloads.isEmpty && audios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  l10n.downloadsEmpty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
            );
          }
          return ListView(
            children: [
              if (downloads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    l10n.downloadsInProgress,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              for (final entry in downloads)
                _DownloadProgressTile(entry: entry),
              if (audios.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    l10n.downloadsCompleted,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              for (final (index, audio) in audios.indexed)
                AudioListTile(
                  audio: audio,
                  onTap: () => ref
                      .read(playerControllerProvider.notifier)
                      .playAudioList(audios, startIndex: index),
                  trailing: IconButton(
                    tooltip: l10n.deleteTooltip,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      await ref.read(audioLibraryProvider).delete(audio);
                      ref.invalidate(audioDownloadedProvider(audio));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DownloadProgressTile extends ConsumerWidget {
  const _DownloadProgressTile({required this.entry});

  final AudioDownloadEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final audio = entry.audio;
    final library = ref.read(audioLibraryProvider);
    final progress = entry.progress;
    final isPaused = entry.status == TaskStatus.paused;
    final hasFailed =
        entry.status == TaskStatus.failed ||
        entry.status == TaskStatus.notFound;
    final status = hasFailed
        ? l10n.downloadFailedStatus
        : isPaused
        ? l10n.downloadPausedStatus
        : l10n.downloadInProgressStatus;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audio.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasFailed)
                  IconButton(
                    tooltip: l10n.retryTooltip,
                    onPressed: () async {
                      try {
                        final url = await ref
                            .read(catalogRepositoryProvider)
                            .getPlaybackUrl(audio);
                        await library.retryDownload(audio, url);
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  )
                else
                  IconButton(
                    tooltip: isPaused ? l10n.resumeTooltip : l10n.pauseTooltip,
                    onPressed: () => isPaused
                        ? library.resumeDownload(audio)
                        : library.pauseDownload(audio),
                    icon: Icon(
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    ),
                  ),
                IconButton(
                  tooltip: l10n.cancelTooltip,
                  onPressed: () => library.cancelDownload(audio),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, minHeight: 4),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                progress == null ? '…' : '${(progress * 100).floor()}%',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

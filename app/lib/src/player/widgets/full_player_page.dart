import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/detail/audio_detail_screen.dart';
import '../../features/favorites/favorites_controller.dart';
import '../../features/widgets/media_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../player_controller.dart';
import 'seek_bar.dart';
import 'sheets.dart';

class FullPlayerPage extends ConsumerWidget {
  const FullPlayerPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const FullPlayerPage(),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = ref.watch(playerControllerProvider);
    final audio = player.current;
    if (audio == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(audio.slug);
    final controller = ref.read(playerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.playerBackgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.playerBackgroundTop,
              AppColors.playerBackgroundBottom,
            ],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artSize = math
                  .min(
                    (constraints.maxWidth - 96).clamp(160.0, 320.0),
                    math.max(140.0, constraints.maxHeight * 0.38),
                  )
                  .toDouble();

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.playerText,
                                size: 32,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                l10n.playerNowPlaying,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.playerMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.toggleShuffle(),
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: player.shuffle
                                    ? AppColors.playerText
                                    : AppColors.playerMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: artSize,
                          height: artSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .35),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: CoverImage(
                              url: audio.coverImageUrl,
                              size: artSize,
                              borderRadius: 28,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        audio.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.playerText,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${audio.teacher.shortName ?? audio.teacher.name} · ${audio.type.name}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.playerMuted,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref
                                      .read(favoritesProvider.notifier)
                                      .toggle(audio),
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? AppColors.primary
                                        : AppColors.playerMuted,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          PlayerSeekBar(
                            position: player.position,
                            duration:
                                player.duration ??
                                Duration(seconds: audio.durationSeconds),
                            enabled:
                                player.duration != null &&
                                player.duration! > Duration.zero,
                            onSeek: controller.seek,
                          ),
                          if (player.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                              child: Text(
                                _localizedError(l10n, player.errorMessage!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFB4A8),
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: controller.cycleRepeatMode,
                                    icon: Icon(
                                      player.repeatMode == PlayerRepeatMode.one
                                          ? Icons.repeat_one_rounded
                                          : Icons.repeat_rounded,
                                      color:
                                          player.repeatMode ==
                                              PlayerRepeatMode.off
                                          ? AppColors.playerMuted
                                          : AppColors.playerText,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: controller.previous,
                                    icon: const Icon(
                                      Icons.skip_previous_rounded,
                                      color: AppColors.playerText,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: AppColors.playerText,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: controller.togglePlayPause,
                                    child: SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: player.buffering
                                          ? const Padding(
                                              padding: EdgeInsets.all(22),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: AppColors.dark,
                                              ),
                                            )
                                          : Icon(
                                              player.playing
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: AppColors
                                                  .playerBackgroundBottom,
                                              size: 44,
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: controller.next,
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: AppColors.playerText,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => showModalBottomSheet<void>(
                                      context: context,
                                      builder: (_) => const SpeedSheet(),
                                    ),
                                    icon: Text(
                                      '${player.speed}x',
                                      style: TextStyle(
                                        color: (player.speed - 1).abs() > .001
                                            ? AppColors.playerText
                                            : AppColors.playerMuted,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _SecondaryAction(
                                    icon: Icons.replay_10_rounded,
                                    label: l10n.playerRewind10,
                                    onTap: () => controller.skipBy(
                                      const Duration(seconds: -10),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _SecondaryAction(
                                    icon: Icons.queue_music_rounded,
                                    label: l10n.playerQueue(
                                      player.queue.length,
                                    ),
                                    onTap: () => showModalBottomSheet<void>(
                                      context: context,
                                      builder: (_) => const QueueSheet(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _SecondaryAction(
                                    icon: Icons.info_outline_rounded,
                                    label: l10n.playerDetails,
                                    onTap: () => AudioDetailScreen.open(
                                      context,
                                      audio.slug,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String _localizedError(AppLocalizations l10n, String key) => switch (key) {
  'network' => l10n.playerErrorNetwork,
  'source' => l10n.playerErrorSource,
  'generic' => l10n.playerErrorGeneric,
  _ => key,
};

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.playerMuted, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.playerMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

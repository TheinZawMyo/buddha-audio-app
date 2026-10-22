import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../player_controller.dart';
import '../../features/widgets/media_widgets.dart';
import 'full_player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final current = player.current;
    if (current == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.playerBackgroundTop, AppColors.dark],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => FullPlayerPage.open(context),
                      child: Row(
                        children: [
                          CoverImage(
                            url: current.coverImageUrl,
                            size: 44,
                            borderRadius: 12,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.playerText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  current.teacher.shortName ??
                                      current.teacher.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.playerMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(playerControllerProvider.notifier).skipBy(
                              const Duration(seconds: -10),
                            ),
                    icon: const Icon(
                      Icons.replay_10_rounded,
                      color: AppColors.playerMuted,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .togglePlayPause(),
                    iconSize: 34,
                    icon: player.buffering
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.playerText,
                            ),
                          )
                        : Icon(
                            player.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.playerText,
                          ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(playerControllerProvider.notifier).next(),
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: AppColors.playerText,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

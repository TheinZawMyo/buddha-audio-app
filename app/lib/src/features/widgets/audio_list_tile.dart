import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/catalog_models.dart';
import '../../player/player_controller.dart';
import '../detail/audio_detail_screen.dart';
import 'media_widgets.dart';

class AudioListTile extends ConsumerWidget {
  const AudioListTile({
    super.key,
    required this.audio,
    this.trailing,
    this.onTap,
  });

  final Audio audio;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final isCurrent = player.current?.id == audio.id;
    final isPlaying = isCurrent && player.playing;

    return Material(
      color: isCurrent
          ? AppColors.primaryContainer.withValues(alpha: .45)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => AudioDetailScreen.open(context, audio.slug),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  CoverImage(url: audio.coverImageUrl, size: 56),
                  if (isPlaying)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black38,
                        ),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isCurrent ? AppColors.dark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${audio.teacher.shortName ?? audio.teacher.name} · ${formatDurationSeconds(audio.durationSeconds)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  IconButton(
                    onPressed: () => _play(context, ref),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle_outline,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _play(BuildContext context, WidgetRef ref) {
    ref.read(playerControllerProvider.notifier).playAudioList([audio]);
  }
}

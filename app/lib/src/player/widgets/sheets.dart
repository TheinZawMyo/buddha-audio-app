import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/catalog_models.dart';
import '../../features/widgets/media_widgets.dart';
import '../player_controller.dart';

class SpeedSheet extends ConsumerWidget {
  const SpeedSheet({super.key});

  static const speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playerControllerProvider.select((s) => s.speed));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ဖွင့်နှုန်း',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final speed in speeds)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontWeight:
                        speed == current ? FontWeight.w800 : FontWeight.w500,
                    color: speed == current ? AppColors.primary : AppColors.text,
                  ),
                ),
                trailing: speed == current
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(playerControllerProvider.notifier).setSpeed(speed);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final current = player.current;
    final queue = player.queue;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'နားထောင်စာရင်း',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            if (queue.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'စာရင်း မရှိသေးပါ',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final audio = queue[index];
                    final isCurrent = audio.id == current?.id;
                    return ListTile(
                      selected: isCurrent,
                      selectedColor: AppColors.text,
                      tileColor:
                          isCurrent ? AppColors.primaryContainer.withValues(alpha: .4) : null,
                      leading: CoverThumb(audio: audio),
                      title: Text(
                        audio.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${audio.teacher.shortName ?? audio.teacher.name} · ${formatDurationSeconds(audio.durationSeconds)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.graphic_eq, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref
                            .read(playerControllerProvider.notifier)
                            .playQueueIndex(index);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CoverThumb extends StatelessWidget {
  const CoverThumb({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 42,
        height: 42,
        child: CoverImage(url: audio.coverImageUrl, size: 42, borderRadius: 10),
      ),
    );
  }
}

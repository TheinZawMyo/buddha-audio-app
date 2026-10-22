import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';

class PlayerSeekBar extends StatelessWidget {
  const PlayerSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.enabled = true,
  });

  final Duration position;
  final Duration? duration;
  final ValueChanged<Duration> onSeek;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final total = duration ?? Duration.zero;
    final maxMs = total.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs > 0 ? maxMs : 0.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.playerText,
            inactiveTrackColor: Colors.white24,
            thumbColor: AppColors.playerText,
            overlayColor: Colors.white12,
            trackHeight: 4,
          ),
          child: Slider(
            value: maxMs > 0 ? valueMs : 0,
            max: maxMs > 0 ? maxMs : 1,
            onChanged: enabled && maxMs > 0
                ? (value) => onSeek(Duration(milliseconds: value.round()))
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: const TextStyle(
                  color: AppColors.playerMuted,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                formatDuration(total),
                style: const TextStyle(
                  color: AppColors.playerMuted,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

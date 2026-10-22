String formatDuration(Duration d) {
  final total = d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
}

String formatDurationSeconds(int seconds) =>
    formatDuration(Duration(seconds: seconds));

String formatRemaining(Duration position, Duration? duration) {
  if (duration == null || duration <= Duration.zero) return '-:--';
  final remaining = duration - position;
  final clamped = remaining.isNegative ? Duration.zero : remaining;
  return '-${formatDuration(clamped)}';
}

import 'package:buddha_audio/src/core/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDuration renders m:ss and h:mm:ss', () {
    expect(formatDuration(const Duration(seconds: 72)), '1:12');
    expect(formatDuration(const Duration(seconds: 3725)), '1:02:05');
    expect(formatDurationSeconds(300), '5:00');
  });
}

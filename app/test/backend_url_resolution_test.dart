import 'package:buddha_audio/src/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const apiBaseUrl = 'http://10.0.2.2:8000/api/v1';

  late ApiClient client;

  setUp(() {
    client = ApiClient(apiBaseUrl);
  });

  test('resolves backend image URLs to the configured API host', () {
    expect(
      client.resolveBackendUrl(
        'http://localhost:8000/api/v1/media/covers/cover.jpg',
      ),
      'http://10.0.2.2:8000/api/v1/media/covers/cover.jpg',
    );
  });

  test('resolves backend audio media URLs to the configured API host', () {
    expect(
      client.resolveBackendUrl(
        'http://localhost:8000/api/v1/media/audio/test.mp3',
      ),
      'http://10.0.2.2:8000/api/v1/media/audio/test.mp3',
    );
  });

  test('resolves signed backend stream URLs and preserves their query', () {
    const url =
        'http://localhost:8000/api/v1/audios/talk/stream?expires=123&signature=abc';

    expect(
      client.resolveBackendUrl(url),
      'http://10.0.2.2:8000/api/v1/audios/talk/stream?expires=123&signature=abc',
    );
  });

  test('leaves external playback URLs unchanged', () {
    const url = 'https://cdn.example.com/audio/talk.mp3';

    expect(client.resolveBackendUrl(url), url);
  });

  test('leaves URLs on the configured API host unchanged', () {
    const url = 'http://10.0.2.2:8000/api/v1/media/teachers/teacher.jpg';

    expect(client.resolveBackendUrl(url), url);
  });
}

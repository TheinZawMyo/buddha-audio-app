import '../../core/network/api_client.dart';
import '../models/catalog_models.dart';

/// Reads only `published` catalog data over `/api/v1` (architecture.md §6).
class RemoteCatalogSource {
  RemoteCatalogSource(this._client);

  final ApiClient _client;

  Future<HomeData> fetchHome() async {
    final body = await _client.get('/home');
    final data = asJsonMap(body['data']) ?? body;
    return HomeData.fromJson(data);
  }

  Future<PaginatedList<Audio>> fetchAudios({
    String? query,
    String? teacher,
    String? category,
    String? type,
    String? cursor,
    int limit = 20,
  }) async {
    final body = await _client.get(
      '/audios',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (teacher != null && teacher.isNotEmpty) 'teacher': teacher,
        if (category != null && category.isNotEmpty) 'category': category,
        if (type != null && type.isNotEmpty) 'type': type,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    return PaginatedList<Audio>(
      items: (body['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Audio.fromJson)
          .toList(),
      pagination: Pagination.fromJson(asJsonMap(body['meta']?['pagination'])),
    );
  }

  Future<Audio> fetchAudio(String slug) async {
    final body = await _client.get('/audios/$slug');
    return Audio.fromJson(asJsonMap(body['data']) ?? const {});
  }

  Future<List<Teacher>> fetchTeachers() async {
    final body = await _client.get('/teachers');
    return (body['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Teacher.fromJson)
        .toList();
  }

  Future<Teacher> fetchTeacher(String slug) async {
    final body = await _client.get('/teachers/$slug');
    return Teacher.fromJson(asJsonMap(body['data']) ?? const {});
  }

  Future<List<AudioCategory>> fetchCategories() async {
    final body = await _client.get('/categories');
    return (body['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AudioCategory.fromJson)
        .toList();
  }

  Future<List<AudioType>> fetchAudioTypes() async {
    final body = await _client.get('/audio-types');
    return (body['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AudioType.fromJson)
        .toList();
  }

  /// Short-lived signed stream URL; falls back to the public CDN URL.
  Future<String> fetchPlaybackUrl(String slug) async {
    final body = await _client.post('/audios/$slug/playback-url');
    final data = asJsonMap(body['data']) ?? body;
    final url = data['playback_url'] ?? data['url'];
    if (url is String && url.isNotEmpty) return url;
    throw ApiException('ဖွင့်ရန် လင့်ခ် ရနိုင်ခြင်း မရှိပါ။');
  }
}

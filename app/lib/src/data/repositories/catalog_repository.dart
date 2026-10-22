import '../models/catalog_models.dart';
import '../sources/remote_catalog_source.dart';

abstract class CatalogRepository {
  Future<HomeData> getHome();

  Future<PaginatedList<Audio>> getAudios({
    String? query,
    String? teacher,
    String? category,
    String? type,
    String? cursor,
    int limit,
  });

  Future<Audio> getAudio(String slug);

  Future<List<Teacher>> getTeachers();

  Future<Teacher> getTeacher(String slug);

  Future<List<AudioCategory>> getCategories();

  Future<List<AudioType>> getAudioTypes();

  Future<String> getPlaybackUrl(Audio audio);
}

class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository(this._source);

  final RemoteCatalogSource _source;

  @override
  Future<HomeData> getHome() => _source.fetchHome();

  @override
  Future<PaginatedList<Audio>> getAudios({
    String? query,
    String? teacher,
    String? category,
    String? type,
    String? cursor,
    int limit = 20,
  }) =>
      _source.fetchAudios(
        query: query,
        teacher: teacher,
        category: category,
        type: type,
        cursor: cursor,
        limit: limit,
      );

  @override
  Future<Audio> getAudio(String slug) => _source.fetchAudio(slug);

  @override
  Future<List<Teacher>> getTeachers() => _source.fetchTeachers();

  @override
  Future<Teacher> getTeacher(String slug) => _source.fetchTeacher(slug);

  @override
  Future<List<AudioCategory>> getCategories() => _source.fetchCategories();

  @override
  Future<List<AudioType>> getAudioTypes() => _source.fetchAudioTypes();

  @override
  Future<String> getPlaybackUrl(Audio audio) async {
    if (audio.playbackUrl case final url when url != null && url.isNotEmpty) {
      return url;
    }
    return _source.fetchPlaybackUrl(audio.slug);
  }
}


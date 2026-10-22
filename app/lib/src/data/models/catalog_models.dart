class Teacher {
  const Teacher({
    required this.id,
    required this.slug,
    required this.name,
    this.shortName,
    this.bio,
    this.photoUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String slug;
  final String name;
  final String? shortName;
  final String? bio;
  final String? photoUrl;
  final int sortOrder;
  final bool isActive;

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: _id(json),
        slug: json['slug'] as String,
        name: json['name'] as String,
        shortName: json['short_name'] as String?,
        bio: json['bio'] as String?,
        photoUrl: json['photo_url'] as String?,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class AudioCategory {
  const AudioCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String slug;
  final String name;
  final int sortOrder;
  final bool isActive;

  factory AudioCategory.fromJson(Map<String, dynamic> json) => AudioCategory(
        id: _id(json),
        slug: json['slug'] as String,
        name: json['name'] as String,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class AudioType {
  const AudioType({
    required this.id,
    required this.slug,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String slug;
  final String name;
  final int sortOrder;
  final bool isActive;

  factory AudioType.fromJson(Map<String, dynamic> json) => AudioType(
        id: _id(json),
        slug: json['slug'] as String,
        name: json['name'] as String,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class Audio {
  const Audio({
    required this.id,
    required this.slug,
    required this.title,
    required this.teacher,
    required this.type,
    required this.categories,
    required this.durationSeconds,
    this.description,
    this.language = 'my',
    this.coverImageUrl,
    this.playbackUrl,
    this.publishedAt,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final Teacher teacher;
  final AudioType type;
  final List<AudioCategory> categories;
  final int durationSeconds;
  final String language;
  final String? coverImageUrl;
  final String? playbackUrl;
  final DateTime? publishedAt;

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
        id: _id(json),
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
        type: AudioType.fromJson(json['type'] as Map<String, dynamic>),
        categories: (json['categories'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AudioCategory.fromJson)
            .toList(),
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
        language: json['language'] as String? ?? 'my',
        coverImageUrl: json['cover_image_url'] as String?,
        playbackUrl: json['playback_url'] as String?,
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      );
}

class Pagination {
  const Pagination({this.nextCursor, this.hasMore = false, this.total});

  final String? nextCursor;
  final bool hasMore;
  final int? total;

  factory Pagination.fromJson(Map<String, dynamic>? json) => Pagination(
        nextCursor: json?['next_cursor'] as String?,
        hasMore: json?['has_more'] as bool? ?? false,
        total: (json?['total'] as num?)?.toInt(),
      );

  static const empty = Pagination();
}

class PaginatedList<T> {
  const PaginatedList({required this.items, this.pagination = Pagination.empty});

  final List<T> items;
  final Pagination pagination;
}

class HomeData {
  const HomeData({
    required this.featured,
    required this.latest,
    required this.teachers,
    required this.categories,
    required this.types,
  });

  final List<Audio> featured;
  final List<Audio> latest;
  final List<Teacher> teachers;
  final List<AudioCategory> categories;
  final List<AudioType> types;

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        featured: _audioList(json['featured']),
        latest: _audioList(json['latest']),
        teachers: _list(json['teachers'], Teacher.fromJson),
        categories: _list(json['categories'], AudioCategory.fromJson),
        types: _list(json['audio_types'] ?? json['types'], AudioType.fromJson),
      );
}

String _id(Map<String, dynamic> json) {
  final value = json['id'] ?? json['uuid'];
  if (value is String) return value;
  if (value is num) return value.toString();
  return json['slug'] as String? ?? '';
}

List<Audio> _audioList(dynamic value) =>
    _list(value, Audio.fromJson);

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

Map<String, dynamic>? asJsonMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;

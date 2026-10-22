import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import 'models/catalog_models.dart';
import 'repositories/catalog_repository.dart';
import 'sources/remote_catalog_source.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return RemoteCatalogRepository(RemoteCatalogSource(ApiClient(apiBaseUrl)));
});

final homeProvider = FutureProvider.autoDispose<HomeData>(
  (ref) => ref.watch(catalogRepositoryProvider).getHome(),
);

final teacherListProvider = FutureProvider.autoDispose<List<Teacher>>(
  (ref) => ref.watch(catalogRepositoryProvider).getTeachers(),
);

final categoryListProvider = FutureProvider.autoDispose<List<AudioCategory>>(
  (ref) => ref.watch(catalogRepositoryProvider).getCategories(),
);

final audioTypeListProvider = FutureProvider.autoDispose<List<AudioType>>(
  (ref) => ref.watch(catalogRepositoryProvider).getAudioTypes(),
);

final audioDetailProvider = FutureProvider.autoDispose.family<Audio, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).getAudio(slug),
);

class AudiosQuery {
  const AudiosQuery({
    this.query = '',
    this.teacher = '',
    this.category = '',
    this.type = '',
  });

  final String query;
  final String teacher;
  final String category;
  final String type;

  AudiosQuery copyWith({
    String? query,
    String? teacher,
    String? category,
    String? type,
  }) =>
      AudiosQuery(
        query: query ?? this.query,
        teacher: teacher ?? this.teacher,
        category: category ?? this.category,
        type: type ?? this.type,
      );

  AudiosQuery copyWithNullable({
    String? query,
    String? teacher,
    String? category,
    String? type,
  }) =>
      AudiosQuery(
        query: query ?? this.query,
        teacher: teacher ?? this.teacher,
        category: category ?? this.category,
        type: type ?? this.type,
      );

  @override
  bool operator ==(Object other) =>
      other is AudiosQuery &&
      other.query == query &&
      other.teacher == teacher &&
      other.category == category &&
      other.type == type;

  @override
  int get hashCode => Object.hash(query, teacher, category, type);
}

class AudiosState {
  const AudiosState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<Audio> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  AudiosState copyWith({
    List<Audio>? items,
    String? Function()? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      AudiosState(
        items: items ?? this.items,
        nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class AudiosController extends AsyncNotifier<AudiosState> {
  AudiosController(this.query);

  final AudiosQuery query;

  @override
  Future<AudiosState> build() async {
    final result = await ref.watch(catalogRepositoryProvider).getAudios(
          query: query.query.isEmpty ? null : query.query,
          teacher: query.teacher.isEmpty ? null : query.teacher,
          category: query.category.isEmpty ? null : query.category,
          type: query.type.isEmpty ? null : query.type,
        );
    return AudiosState(
      items: result.items,
      nextCursor: result.pagination.nextCursor,
      hasMore: result.pagination.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await ref.read(catalogRepositoryProvider).getAudios(
            query: query.query.isEmpty ? null : query.query,
            teacher: query.teacher.isEmpty ? null : query.teacher,
            category: query.category.isEmpty ? null : query.category,
            type: query.type.isEmpty ? null : query.type,
            cursor: current.nextCursor,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...result.items],
          nextCursor: () => result.pagination.nextCursor,
          hasMore: result.pagination.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final audiosProvider = AsyncNotifierProvider.autoDispose
    .family<AudiosController, AudiosState, AudiosQuery>(AudiosController.new);

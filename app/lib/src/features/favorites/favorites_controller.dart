import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../data/catalog_providers.dart';
import '../../data/models/catalog_models.dart';

const _favoritesKey = 'favorites.audio_slugs';

/// Local (guest) favorites stored on device — accounts come later.
/// Keys are public slugs from the API.
class FavoritesNotifier extends Notifier<Set<String>> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Set<String> build() =>
      _prefs.getStringList(_favoritesKey)?.toSet() ?? <String>{};

  bool isFavorite(String slug) => state.contains(slug);

  Future<void> toggle(Audio audio) async {
    final next = Set<String>.from(state);
    if (!next.remove(audio.slug)) {
      next.add(audio.slug);
    }
    state = next;
    await _prefs.setStringList(_favoritesKey, next.toList());
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

final favoriteAudiosProvider = FutureProvider.autoDispose<List<Audio>>((ref) async {
  final slugs = ref.watch(favoritesProvider).toList(growable: false);
  if (slugs.isEmpty) return const <Audio>[];

  final repository = ref.watch(catalogRepositoryProvider);
  final results = await Future.wait(slugs.map((slug) async {
    try {
      return await repository.getAudio(slug);
    } catch (_) {
      return null;
    }
  }));
  return results.whereType<Audio>().toList(growable: false);
});

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/catalog_providers.dart';
import '../../player/player_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';

class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final _searchQueryProvider =
    NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  static const _recentKey = 'search.recent';
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _recent = ref.read(sharedPreferencesProvider).getStringList(_recentKey) ?? [];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(_searchQueryProvider.notifier).set(value.trim());
    });
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    _debounce?.cancel();
    ref.read(_searchQueryProvider.notifier).set(query);
    _recent = [query, ..._recent.where((r) => r != query)].take(8).toList();
    ref.read(sharedPreferencesProvider).setStringList(_recentKey, _recent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ရှာဖွေရန်'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'ခေါင်းစဉ်၊ ဆရာတော် ရှာရန်...',
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(_searchQueryProvider.notifier).set('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: query.isEmpty
          ? _RecentSearches(
              recent: _recent,
              onPick: (term) {
                _controller.text = term;
                _submit(term);
              },
              onClear: () {
                _recent = [];
                ref.read(sharedPreferencesProvider).remove(_recentKey);
                setState(() {});
              },
            )
          : _SearchResults(query: query),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recent,
    required this.onPick,
    required this.onClear,
  });

  final List<String> recent;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return const EmptyView(
        icon: Icons.search_rounded,
        title: 'တရားတော် ရှာဖွေပါ',
        subtitle: 'ခေါင်းစဉ် သို့မဟုတ် ဆရာတော်အမည်ဖြင့် ရှာနိုင်ပါသည်။',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'မကြာသေးမီက ရှာဖွေမှုများ',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('ဖျက်')),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in recent)
              ActionChip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(term),
                onPressed: () => onPick(term),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiosQuery = AudiosQuery(query: query);
    final async = ref.watch(audiosProvider(audiosQuery));

    return async.when(
      loading: () => const LoadingView(),
      error: (error, _) => AudioErrorView(
        message: error,
        onRetry: () => ref.invalidate(audiosProvider(audiosQuery)),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const EmptyView(
            icon: Icons.search_off_rounded,
            title: 'တွေ့မတွေ့ပါ',
            subtitle: 'အခြားစကားလုံးဖြင့် ထပ်ရှာကြည့်ပါ။',
          );
        }
        return ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (context, index) => AudioListTile(
            audio: state.items[index],
            trailing: IconButton(
              onPressed: () => ref
                  .read(playerControllerProvider.notifier)
                  .playAudioList(state.items, startIndex: index),
              icon: const Icon(
                Icons.play_circle_outline,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}

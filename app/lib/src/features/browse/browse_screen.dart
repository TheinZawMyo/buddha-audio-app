import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalog_providers.dart';
import '../../data/models/catalog_models.dart';
import '../../player/player_controller.dart';
import '../browse/browse_filter.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/state_views.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(audiosProvider(_query()).notifier).loadMore();
    }
  }

  AudiosQuery _query() {
    final filter = ref.read(browseFilterProvider);
    return AudiosQuery(
      teacher: filter.teacher,
      category: filter.category,
      type: filter.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(browseFilterProvider);
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final types = ref.watch(audioTypeListProvider).value ?? const [];
    final teachers = ref.watch(teacherListProvider).value ?? const [];
    final query = AudiosQuery(
      teacher: filter.teacher,
      category: filter.category,
      type: filter.type,
    );
    final audios = ref.watch(audiosProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('ရှာဖွေရန်')),
      body: Column(
        children: [
          _FilterRow(
            filter: filter,
            categories: categories,
            types: types,
            teachers: teachers,
          ),
          Expanded(
            child: audios.when(
              loading: () => const LoadingView(),
              error: (error, _) => AudioErrorView(
                message: error,
                onRetry: () => ref.invalidate(audiosProvider(query)),
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return const EmptyView(
                    icon: Icons.library_music_outlined,
                    title: 'တရားတော် မတွေ့ပါ',
                    subtitle: 'စစ်ထုတ်မှုများကို ပြောင်းလဲကြည့်ပါ။',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(audiosProvider(query)),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      final audio = state.items[index];
                      return AudioListTile(
                        audio: audio,
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
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({
    required this.filter,
    required this.categories,
    required this.types,
    required this.teachers,
  });

  final BrowseFilter filter;
  final List<AudioCategory> categories;
  final List<AudioType> types;
  final List<Teacher> teachers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget dropdown<T extends Object>({
      required String label,
      required String value,
      required List<T> items,
      required String Function(T) nameOf,
      required String Function(T) slugOf,
      required void Function(T) onSelected,
    }) {
      return Expanded(
        child: PopupMenuButton<T>(
          tooltip: label,
          padding: EdgeInsets.zero,
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final item in items)
              PopupMenuItem(
                value: item,
                child: Text(
                  nameOf(item),
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: value.isEmpty ? AppColors.outline : AppColors.primary,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty
                        ? label
                        : nameOf(items.firstWhere(
                            (i) => slugOf(i) == value,
                            orElse: () => items.first,
                          )),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: value.isEmpty
                          ? AppColors.mutedText
                          : AppColors.dark,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          if (!filter.isEmpty)
            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref.read(browseFilterProvider.notifier).clear(),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('စစ်ထုတ်မှု ဖျက်'),
                ),
              ],
            ),
          Row(
            children: [
              dropdown(
                label: 'အမျိုးအစား',
                value: filter.category,
                items: categories,
                nameOf: (c) => c.name,
                slugOf: (c) => c.slug,
                onSelected: (c) =>
                    ref.read(browseFilterProvider.notifier).setCategory(c.slug),
              ),
              const SizedBox(width: 8),
              dropdown(
                label: 'အမျိုးအစား(type)',
                value: filter.type,
                items: types,
                nameOf: (t) => t.name,
                slugOf: (t) => t.slug,
                onSelected: (t) =>
                    ref.read(browseFilterProvider.notifier).setType(t.slug),
              ),
              const SizedBox(width: 8),
              dropdown(
                label: 'ဆရာတော်',
                value: filter.teacher,
                items: teachers,
                nameOf: (t) => t.shortName ?? t.name,
                slugOf: (t) => t.slug,
                onSelected: (t) =>
                    ref.read(browseFilterProvider.notifier).setTeacher(t.slug),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

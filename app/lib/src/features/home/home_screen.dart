import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/catalog_providers.dart';
import '../../data/models/catalog_models.dart';
import '../../player/player_controller.dart';
import '../detail/audio_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../shell/shell_controller.dart';
import '../widgets/audio_list_tile.dart';
import '../widgets/media_widgets.dart';
import '../widgets/state_views.dart';
import '../browse/browse_filter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.dark],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'ဗုဒ္ဓသံသာ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => SettingsScreen.open(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: home.when(
        loading: () => const LoadingView(message: 'တရားတော်များ ရယူနေသည်...'),
        error: (error, _) => AudioErrorView(
          message: error,
          onRetry: () => ref.invalidate(homeProvider),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(homeProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => ref.read(shellProvider.notifier).openSearch(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.mutedText),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'တရားတော် ရှာမည်...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.mutedText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (data.featured.isNotEmpty) ...[
                const SectionHeader(title: 'ထူးခြားသော တရားတော်များ'),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: data.featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) =>
                        _FeaturedCard(audio: data.featured[index]),
                  ),
                ),
              ],
              if (data.teachers.isNotEmpty) ...[
                const SectionHeader(title: 'ဆရာတော်များ'),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: data.teachers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 18),
                    itemBuilder: (context, index) {
                      final teacher = data.teachers[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(36),
                        onTap: () {
                          ref.read(shellProvider.notifier).goTo(1);
                          ref
                              .read(browseFilterProvider.notifier)
                              .setTeacher(teacher.slug);
                        },
                        child: ArtistCircle(
                          photoUrl: teacher.photoUrl,
                          name: teacher.shortName ?? teacher.name,
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (data.categories.isNotEmpty) ...[
                const SectionHeader(title: 'အမျိုးအစားများ'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in data.categories)
                        ActionChip(
                          label: Text(category.name),
                          onPressed: () {
                            ref.read(shellProvider.notifier).goTo(1);
                            ref
                                .read(browseFilterProvider.notifier)
                                .setCategory(category.slug);
                          },
                        ),
                    ],
                  ),
                ),
              ],
              if (data.latest.isNotEmpty) ...[
                const SectionHeader(title: 'အသစ်ထွက် တရားတော်များ'),
                for (final audio in data.latest)
                  AudioListTile(
                    audio: audio,
                    trailing: IconButton(
                      onPressed: () {
                        final index =
                            data.latest.indexWhere((a) => a.id == audio.id);
                        ref.read(playerControllerProvider.notifier).playAudioList(
                              data.latest,
                              startIndex: index < 0 ? 0 : index,
                            );
                      },
                      icon: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends ConsumerWidget {
  const _FeaturedCard({required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => AudioDetailScreen.open(context, audio.slug),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.playerBackgroundTop, AppColors.dark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: .18,
                child: Icon(
                  Icons.self_improvement,
                  size: 140,
                  color: Colors.white.withValues(alpha: .6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      audio.type.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    audio.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    audio.teacher.shortName ?? audio.teacher.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => ref
                              .read(playerControllerProvider.notifier)
                              .playAudioList([audio]),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.dark,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.schedule, color: Colors.white54, size: 16),
                      Text(
                        _formatMinutes(audio.durationSeconds),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int seconds) {
    final m = (seconds / 60).ceil();
    return '$m မိနစ်';
  }
}

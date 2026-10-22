import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../player/widgets/mini_player.dart';
import '../browse/browse_screen.dart';
import '../library/library_screen.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import 'shell_controller.dart';

/// Bottom navigation shell. Tabs keep their own state via [IndexedStack];
/// the mini player docks above the navigation bar so playback is reachable
/// from every screen (music-app pattern).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          BrowseScreen(),
          SearchScreen(),
          LibraryScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.outline, width: .8),
              ),
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) =>
                  ref.read(shellProvider.notifier).goTo(value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'ပင်မ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'ရှာဖွေ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: 'ရှာရန်',
                ),
                NavigationDestination(
                  icon: Icon(Icons.video_library_outlined),
                  selectedIcon: Icon(Icons.video_library_rounded),
                  label: 'သိမ်းဆည်း',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

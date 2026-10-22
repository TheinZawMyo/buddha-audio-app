import 'package:buddha_audio/l10n/generated/app_localizations.dart';
import 'package:buddha_audio/src/core/config/app_config.dart';
import 'package:buddha_audio/src/data/catalog_providers.dart';
import 'package:buddha_audio/src/data/models/catalog_models.dart';
import 'package:buddha_audio/src/data/repositories/catalog_repository.dart';
import 'package:buddha_audio/src/features/detail/audio_detail_screen.dart';
import 'package:buddha_audio/src/features/settings/settings_screen.dart';
import 'package:buddha_audio/src/features/shell/app_shell.dart';
import 'package:buddha_audio/src/player/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _teacher = Teacher(id: 't-1', slug: 'teacher', name: 'ဆရာတော်');

const _audio = Audio(
  id: 'a-1',
  slug: 'audio',
  title: 'စိတ်၏ ငြိမ်းချမ်းမှု',
  teacher: _teacher,
  type: AudioType(id: 'ty-1', slug: 'talk', name: 'တရားနာ'),
  categories: [AudioCategory(id: 'c-1', slug: 'dhamma', name: 'တရားတော်')],
  durationSeconds: 372,
  description: 'စိတ်ကို တည်ငြိမ်အောင် ထားနည်း။',
);

const _relatedAudio = Audio(
  id: 'a-2',
  slug: 'related-audio',
  title: 'မေတ္တာဘာဝနာ ကျင့်စဉ်',
  teacher: _teacher,
  type: AudioType(id: 'ty-1', slug: 'talk', name: 'တရားနာ'),
  categories: [AudioCategory(id: 'c-1', slug: 'dhamma', name: 'တရားတော်')],
  durationSeconds: 480,
);

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<HomeData> getHome() async => const HomeData(
    featured: [_audio],
    latest: [_audio],
    teachers: [_teacher],
    categories: [AudioCategory(id: 'c-1', slug: 'dhamma', name: 'တရားတော်')],
    types: [AudioType(id: 'ty-1', slug: 'talk', name: 'တရားနာ')],
  );

  @override
  Future<PaginatedList<Audio>> getAudios({
    String? query,
    String? teacher,
    String? category,
    String? type,
    String? cursor,
    int limit = 20,
  }) async => const PaginatedList(
    items: [_audio, _relatedAudio],
    pagination: Pagination(total: 2),
  );

  @override
  Future<Audio> getAudio(String slug) async => _audio;

  @override
  Future<List<Teacher>> getTeachers() async => const [_teacher];

  @override
  Future<Teacher> getTeacher(String slug) async => _teacher;

  @override
  Future<List<AudioCategory>> getCategories() async => const [
    AudioCategory(id: 'c-1', slug: 'dhamma', name: 'တရားတော်'),
  ];

  @override
  Future<List<AudioType>> getAudioTypes() async => const [
    AudioType(id: 'ty-1', slug: 'talk', name: 'တရားနာ'),
  ];

  @override
  Future<String> getPlaybackUrl(Audio audio) async =>
      'https://example.com/audio.mp3';
}

class _FakePlayerController extends PlayerController {
  @override
  PlayerUiState build() => const PlayerUiState(
    queue: [_audio],
    current: _audio,
    playing: true,
    duration: Duration(seconds: 372),
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository()),
          playerControllerProvider.overrideWith(_FakePlayerController.new),
        ],
        child: MaterialApp(
          locale: const Locale('my'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }

  testWidgets('app shell fits on a small screen', (tester) async {
    await pumpScreen(tester, const AppShell());

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('audio detail fits on a small screen', (tester) async {
    await pumpScreen(tester, const AudioDetailScreen(slug: 'audio'));

    expect(find.text(_audio.title), findsOneWidget);
    expect(find.text(_relatedAudio.title), findsOneWidget);
  });

  testWidgets('settings fits on a small screen', (tester) async {
    await pumpScreen(tester, const SettingsScreen());

    expect(find.text('ဗားရှင်း'), findsOneWidget);
  });
}

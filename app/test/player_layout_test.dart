import 'package:buddha_audio/src/core/config/app_config.dart';
import 'package:buddha_audio/src/data/models/catalog_models.dart';
import 'package:buddha_audio/src/player/player_controller.dart';
import 'package:buddha_audio/src/player/widgets/full_player_page.dart';
import 'package:buddha_audio/src/player/widgets/mini_player.dart';
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
  categories: [],
  durationSeconds: 372,
);

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

  Widget wrap(Widget child) => ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerControllerProvider.overrideWith(_FakePlayerController.new),
        ],
        child: MaterialApp(home: child),
      );

  testWidgets('full player fits on a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(const FullPlayerPage()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('နားထောင်နေသည်'), findsOneWidget);
  });

  testWidgets('mini player fits on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        const Scaffold(
          body: Column(
            children: [
              Spacer(),
              MiniPlayer(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('စိတ်၏ ငြိမ်းချမ်းမှု'), findsOneWidget);
  });
}

// Screenshot harness (NOT part of the normal test suite — filename has no
// `_test` suffix, so `flutter test` skips it). Generate with:
//
//   flutter test test/screenshots.dart --update-goldens
//
// Renders real screens at phone size with the bundled fonts loaded, so the
// output reflects the true type, colour, and layout.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sukoon/application/providers.dart';
import 'package:sukoon/core/core.dart';
import 'package:sukoon/data/mock/dev_scenario.dart';
import 'package:sukoon/presentation/app/app.dart';
import 'package:sukoon/presentation/commitment/commitment_setup_screen.dart';
import 'package:sukoon/presentation/widgets/app_icons.dart';

const _phone = Size(390, 844);

Widget _app(DevScenario s, {ThemeMode mode = ThemeMode.light}) => ProviderScope(
      overrides: [
        scenarioProvider.overrideWith((_) => s),
        reduceMotionOverrideProvider.overrideWith((_) => true),
        themeModeProvider.overrideWith((_) => mode),
      ],
      child: const SukoonApp(),
    );

Future<void> _loadFont(String family, String asset) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

void _phoneSize(WidgetTester t) {
  t.view.physicalSize = Size(_phone.width * 3, _phone.height * 3);
  t.view.devicePixelRatio = 3.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
}

Future<void> _settle(WidgetTester t) async {
  // Reduced-motion is forced on, so there are no infinite tickers — this flushes
  // the mock streams and settles the arc-light tween before capture.
  await t.pumpAndSettle(const Duration(milliseconds: 16));
}

Future<void> _shot(WidgetTester t, String name) =>
    expectLater(find.byType(SukoonApp), matchesGoldenFile('../screenshots/$name.png'));

void main() {
  setUpAll(() async {
    await _loadFont('Newsreader', 'assets/fonts/Newsreader.ttf');
    await _loadFont('Hanken Grotesk', 'assets/fonts/HankenGrotesk.ttf');
    await _loadFont('Amiri', 'assets/fonts/Amiri-Regular.ttf');
    // Best-effort: render real Material icons instead of tofu boxes.
    try {
      await _loadFont('MaterialIcons', 'fonts/MaterialIcons-Regular.otf');
    } catch (_) {}
  });

  testWidgets('today + tabs (light)', (t) async {
    _phoneSize(t);
    await t.pumpWidget(_app(DevScenario.active));
    await _settle(t);
    await _shot(t, '01_today_light');

    await t.tap(find.text('Wallet'));
    await _settle(t);
    await _shot(t, '02_wallet');

    await t.tap(find.text('Giving'));
    await _settle(t);
    await _shot(t, '03_giving');

    await t.tap(find.text('History'));
    await _settle(t);
    await _shot(t, '04_history');

    await t.tap(find.text('Today'));
    await _settle(t);
    await t.tap(find.byIcon(AppIcons.settings));
    await _settle(t);
    await _shot(t, '05_settings');
  });

  testWidgets('today (dark / Layl)', (t) async {
    _phoneSize(t);
    await t.pumpWidget(_app(DevScenario.active, mode: ThemeMode.dark));
    await _settle(t);
    await _shot(t, '06_today_dark');
  });

  testWidgets('onboarding (fresh user)', (t) async {
    _phoneSize(t);
    await t.pumpWidget(_app(DevScenario.freshUser));
    await _settle(t);
    await _shot(t, '07_onboarding');
  });

  testWidgets('commitment setup', (t) async {
    _phoneSize(t);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          scenarioProvider.overrideWith((_) => DevScenario.active),
          reduceMotionOverrideProvider.overrideWith((_) => true),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const CommitmentSetupScreen(),
        ),
      ),
    );
    await _settle(t);
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('../screenshots/08_setup.png'));
  });

  testWidgets('depleted wallet (today)', (t) async {
    _phoneSize(t);
    await t.pumpWidget(_app(DevScenario.depletedWallet));
    await _settle(t);
    await _shot(t, '09_today_depleted');
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sukoon/application/providers.dart';
import 'package:sukoon/data/mock/dev_scenario.dart';
import 'package:sukoon/presentation/app/app.dart';

/// Builds the app for a given scenario with ambient motion off, so tests don't
/// leave repeating tickers / staggered intro timers pending at teardown.
Widget _app(DevScenario scenario) => ProviderScope(
      overrides: [
        scenarioProvider.overrideWith((ref) => scenario),
        reduceMotionOverrideProvider.overrideWith((ref) => true),
      ],
      child: const SukoonApp(),
    );

void main() {
  testWidgets('boots into the active commitment (Today)', (tester) async {
    await tester.pumpWidget(_app(DevScenario.active));
    await tester.pump(); // settle the auth stream
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('As-salāmu'), findsOneWidget);
    expect(find.textContaining('Day 12 of 30'), findsOneWidget);
  });

  testWidgets('fresh user lands in onboarding', (tester) async {
    await tester.pumpWidget(_app(DevScenario.freshUser));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('quiet commitment'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('depleted wallet shows the calm top-up prompt', (tester) async {
    await tester.pumpWidget(_app(DevScenario.depletedWallet));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('rested at zero'), findsOneWidget);
  });
}

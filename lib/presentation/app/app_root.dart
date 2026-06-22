import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../onboarding/onboarding_flow.dart';
import '../widgets/arabic_phrase.dart';
import 'main_shell.dart';

/// Decides the top-level destination: a brief splash while the (mock) auth
/// stream settles, then onboarding (signed out) or the main shell (signed in).
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(signedInProvider);
    final colors = context.colors;

    final Widget child = signedIn.when(
      loading: () => const _Splash(key: ValueKey('splash')),
      error: (_, _) => const _Splash(key: ValueKey('splash')),
      data: (isIn) => isIn
          ? const MainShell(key: ValueKey('main'))
          : const OnboardingFlow(key: ValueKey('onboarding')),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: colors.isNight
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colors.surface,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colors.surface,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: AnimatedSwitcher(
        duration: Motion.transition,
        switchInCurve: Motion.decelerate,
        switchOutCurve: Motion.standard,
        child: child,
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sukoon', style: context.text.serifDisplay),
            const SizedBox(height: Space.sm),
            ArabicPhrase('سُكُون', color: colors.primary, fontSize: 18),
          ],
        ),
      ),
    );
  }
}

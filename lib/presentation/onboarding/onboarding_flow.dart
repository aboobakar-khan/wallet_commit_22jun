import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../widgets/app_button.dart';
import '../widgets/arabic_phrase.dart';

/// Three calm screens — the idea · the honesty principle · the transparency
/// promise — then a mock sign-in. Copy is held strictly to the §2 framing:
/// self-discipline, never expiation; encouragement, never shame.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _controller = PageController();
  final _nameController = TextEditingController();
  int _page = 0;
  bool _signingIn = false;

  static const _pages = <_IntroContent>[
    _IntroContent(
      litCount: 5,
      title: 'A quiet commitment\nto your salah.',
      body:
          'Set this as self-discipline for a number of days, and set aside a small '
          'amount for each prayer. Keep your prayers — in sha Allah you will — and '
          'nothing moves.',
    ),
    _IntroContent(
      litCount: 4,
      title: 'It stays between\nyou and Allah.',
      body:
          'The money is only a nudge, never a payment for prayer. Qada and tawbah '
          'always stand. A missed prayer is met with quiet dignity and an offer to '
          'make it up — never shame.',
    ),
    _IntroContent(
      litCount: 5,
      title: 'Every rupee\nis an amanah.',
      body:
          'If a prayer is genuinely missed, its small amount later joins a pooled '
          'sadaqah for people in need, in sha Allah — with the amount, a note, and '
          'proof shown to you.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length) {
      _controller.nextPage(duration: Motion.transition, curve: Motion.decelerate);
    }
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    Haptics.commit();
    final name = _nameController.text.trim();
    await ref.read(actionsProvider).signIn(name.isEmpty ? 'Friend' : name);
    // AppRoot will swap to the main shell once signedIn flips.
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSignIn = _page == _pages.length;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  for (final p in _pages) _IntroPage(content: p),
                  _SignInPage(nameController: _nameController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.screenGutter, Space.xs, Space.screenGutter, Space.md),
              child: Column(
                children: [
                  _Dots(count: _pages.length + 1, index: _page),
                  const SizedBox(height: Space.md),
                  if (isSignIn)
                    AppButton(
                      label: 'Begin',
                      loading: _signingIn,
                      onPressed: _signIn,
                    )
                  else
                    AppButton(label: 'Continue', onPressed: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroContent {
  const _IntroContent({
    required this.litCount,
    required this.title,
    required this.body,
  });
  final int litCount;
  final String title;
  final String body;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.content});
  final _IntroContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.screenGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),
          Center(
            child: SizedBox(
              height: 120,
              width: 240,
              child: CustomPaint(
                painter: _ArcEmblemPainter(
                  litCount: content.litCount,
                  arc: colors.ink.withValues(alpha: 0.18),
                  lit: colors.dawn,
                  unlit: colors.inkMuted.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          Text(content.title, style: context.text.serifDisplay),
          const SizedBox(height: Space.md),
          Text(
            content.body,
            style: context.type.bodyLarge?.copyWith(color: colors.inkMuted, height: 1.5),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _SignInPage extends StatelessWidget {
  const _SignInPage({required this.nameController});
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.screenGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),
          ArabicPhrase('بِسْمِ اللَّٰهِ', color: colors.primary, fontSize: 22),
          const SizedBox(height: Space.lg),
          Text('In sha Allah,\nlet us begin.', style: context.text.serifDisplay),
          const SizedBox(height: Space.lg),
          Text(
            'What may we call you?',
            style: context.type.labelMedium?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: Space.xs),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: context.type.titleMedium,
            cursorColor: colors.primary,
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: context.type.titleMedium?.copyWith(color: colors.inkMuted),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: Space.md, vertical: Space.md),
              enabledBorder: OutlineInputBorder(
                borderRadius: Radii.card_,
                borderSide: BorderSide(color: colors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radii.card_,
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: Space.md),
          Text(
            'A demo sign-in for now — no account, no password. Your real sign-in '
            'arrives with the backend.',
            style: context.type.bodySmall,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: Motion.state,
            curve: Motion.decelerate,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 6,
            width: i == index ? 20 : 6,
            decoration: BoxDecoration(
              color: i == index ? colors.primary : colors.hairline,
              borderRadius: Radii.pill,
            ),
          ),
      ],
    );
  }
}

class _ArcEmblemPainter extends CustomPainter {
  _ArcEmblemPainter({
    required this.litCount,
    required this.arc,
    required this.lit,
    required this.unlit,
  });
  final int litCount;
  final Color arc;
  final Color lit;
  final Color unlit;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    Offset point(double t) {
      final x = size.width * (0.08 + 0.84 * t);
      final y = size.height * 0.92 - math.sin(math.pi * t) * size.height * 0.78;
      return Offset(x, y);
    }

    for (var i = 0; i <= 60; i++) {
      final o = point(i / 60);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = arc,
    );

    const ts = [0.07, 0.34, 0.55, 0.78, 0.93];
    for (var i = 0; i < ts.length; i++) {
      final o = point(ts[i]);
      final on = i < litCount;
      if (on) {
        canvas.drawCircle(
          o,
          12,
          Paint()
            ..shader = RadialGradient(colors: [
              lit.withValues(alpha: 0.35),
              lit.withValues(alpha: 0.0),
            ]).createShader(Rect.fromCircle(center: o, radius: 12)),
        );
        canvas.drawCircle(o, 4.5, Paint()..color = lit);
      } else {
        canvas.drawCircle(
          o,
          4.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = unlit,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArcEmblemPainter old) => old.litCount != litCount;
}

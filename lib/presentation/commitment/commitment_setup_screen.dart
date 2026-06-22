import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../payments/top_up_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_toast.dart';
import '../widgets/pill_choice.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

class CommitmentSetupScreen extends ConsumerStatefulWidget {
  const CommitmentSetupScreen({super.key});

  @override
  ConsumerState<CommitmentSetupScreen> createState() =>
      _CommitmentSetupScreenState();
}

class _CommitmentSetupScreenState extends ConsumerState<CommitmentSetupScreen> {
  static const _durations = [7, 30, 40];
  static const _stakes = [1000, 2000, 3000, 5000];

  int _days = 30;
  bool _customDays = false;
  int _stake = 2000;
  bool _busy = false;

  int get _maxSadaqah => _days * 5 * _stake;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    final today = ref.read(todayProvider);
    final start = today;
    final end = today.add(Duration(days: _days - 1));
    final recommended = (_stake * _days).clamp(10000, 100000);

    final funded = await showTopUpSheet(
      context,
      recommendedPaise: recommended,
      title: 'Fund your commitment',
    );
    if (funded != true) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    await ref.read(actionsProvider).createCommitment(
          startDate: start,
          endDate: end,
          stakePerPrayerPaise: _stake,
        );
    if (!mounted) return;
    showAppToast(context, 'Your commitment has begun. In sha Allah.',
        icon: AppIcons.today);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ScreenScaffold(
      title: 'Set your commitment',
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.screenGutter, Space.xs, Space.screenGutter, Space.sm),
          child: AppButton(
            label: 'Continue',
            loading: _busy,
            onPressed: _confirm,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.xs),
          Text(
            'You’re setting this once, as self-discipline — for a set number '
            'of days. Not a daily vow.',
            style: context.type.bodyLarge?.copyWith(color: colors.inkMuted, height: 1.5),
          ),
          const SizedBox(height: Space.xl),
          const SectionLabel('For how many days'),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final d in _durations)
                PillChoice(
                  label: '$d days',
                  selected: !_customDays && _days == d,
                  onTap: () => setState(() {
                    _customDays = false;
                    _days = d;
                  }),
                ),
              PillChoice(
                label: 'Custom',
                selected: _customDays,
                onTap: () => setState(() => _customDays = true),
              ),
            ],
          ),
          if (_customDays) ...[
            const SizedBox(height: Space.md),
            _Stepper(
              value: _days,
              min: 3,
              max: 90,
              label: 'days',
              onChanged: (v) => setState(() => _days = v),
            ),
          ],
          const SizedBox(height: Space.xl),
          const SectionLabel('Set aside per prayer'),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final s in _stakes)
                PillChoice(
                  label: Money.format(s),
                  selected: _stake == s,
                  onTap: () => setState(() => _stake = s),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          SurfaceCard(
            color: colors.surfaceMuted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.heart, size: 16, color: colors.sadaqah),
                    const SizedBox(width: Space.xs),
                    Text('In honesty',
                        style: context.type.labelLarge?.copyWith(color: colors.ink)),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text.rich(
                  TextSpan(
                    style: context.type.bodyMedium?.copyWith(height: 1.5),
                    children: [
                      const TextSpan(
                          text:
                              'If every prayer were missed — and in sha Allah it won’t be — '
                              'that would be at most '),
                      TextSpan(
                        text: Money.format(_maxSadaqah),
                        style: context.text.money.copyWith(color: colors.ink),
                      ),
                      const TextSpan(
                          text:
                              '. Anything unused is refunded or rolls into your next commitment.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });
  final int value;
  final int min;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget btn(IconData icon, VoidCallback? onTap) => Material(
          color: colors.surface,
          shape: CircleBorder(side: BorderSide(color: colors.hairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap == null
                ? null
                : () {
                    Haptics.select();
                    onTap();
                  },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 20, color: onTap == null ? colors.inkMuted : colors.ink),
            ),
          ),
        );
    return Row(
      children: [
        btn(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null),
        Expanded(
          child: Center(
            child: Text('$value $label', style: context.text.serifTitle),
          ),
        ),
        btn(AppIcons.add, value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

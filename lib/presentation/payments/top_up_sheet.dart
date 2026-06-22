import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';

/// The simulated top-up sheet. Styled to feel like a real, trustworthy payment
/// step, but it only credits the mock wallet — real Razorpay drops in behind
/// [PaymentService] later. Returns true if funds were added.
Future<bool?> showTopUpSheet(
  BuildContext context, {
  int? recommendedPaise,
  String title = 'Add to your wallet',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _TopUpSheet(recommendedPaise: recommendedPaise, title: title),
  );
}

class _TopUpSheet extends ConsumerStatefulWidget {
  const _TopUpSheet({this.recommendedPaise, required this.title});
  final int? recommendedPaise;
  final String title;

  @override
  ConsumerState<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends ConsumerState<_TopUpSheet> {
  static const _presets = [10000, 30000, 50000, 100000];
  late int _amount = widget.recommendedPaise ?? 30000;
  bool _processing = false;

  Future<void> _confirm() async {
    setState(() => _processing = true);
    Haptics.commit();
    // Simulate the gateway round-trip.
    await Future.delayed(const Duration(milliseconds: 1150));
    if (!mounted) return;
    await ref.read(actionsProvider).topUp(_amount);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.large)),
          border: Border.all(color: colors.hairline),
        ),
        padding: const EdgeInsets.fromLTRB(
            Space.screenGutter, Space.sm, Space.screenGutter, Space.lg),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.hairline,
                    borderRadius: Radii.pill,
                  ),
                ),
              ),
              const SizedBox(height: Space.lg),
              Text(widget.title, style: context.text.serifTitle),
              const SizedBox(height: Space.xs),
              Row(
                children: [
                  Icon(AppIcons.shield, size: 15, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'A demo top-up — no real charge. Secure payment arrives later.',
                      style: context.type.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              Text(
                Money.format(_amount),
                style: context.text.moneyLarge.copyWith(color: colors.ink),
              ),
              const SizedBox(height: Space.md),
              Wrap(
                spacing: Space.xs,
                runSpacing: Space.xs,
                children: [
                  for (final p in _presets)
                    _AmountChip(
                      label: Money.format(p),
                      selected: p == _amount,
                      onTap: _processing ? null : () => setState(() => _amount = p),
                    ),
                ],
              ),
              const SizedBox(height: Space.lg),
              AppButton(
                label: _processing ? 'Adding…' : 'Add ${Money.format(_amount)}',
                loading: _processing,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              Haptics.select();
              onTap!();
            },
      child: AnimatedContainer(
        duration: Motion.state,
        curve: Motion.standard,
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceMuted,
          borderRadius: Radii.pill,
          border: Border.all(color: selected ? colors.primary : colors.hairline),
        ),
        child: Text(
          label,
          style: context.text.money.copyWith(
            fontSize: 14,
            color: selected ? colors.onPrimary : colors.ink,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'app_icons.dart';

/// A deliberately *quiet* balance chip. Money is an amanah, never the hero — it
/// sits small and calm, the prayer and the day carry the screen (THESIS §2.4).
class BalanceChip extends StatelessWidget {
  const BalanceChip({
    super.key,
    required this.balancePaise,
    this.onTap,
    this.overSky = false,
  });

  final int balancePaise;
  final VoidCallback? onTap;
  final bool overSky;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = overSky ? const Color(0xFFF1ECE2) : colors.inkMuted;
    final bg = overSky
        ? const Color(0xFF071018).withValues(alpha: 0.28)
        : colors.surface;
    final border = overSky
        ? const Color(0xFFF1ECE2).withValues(alpha: 0.18)
        : colors.hairline;

    return Material(
      color: Colors.transparent,
      borderRadius: Radii.pill,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                Haptics.select();
                onTap!();
              },
        borderRadius: Radii.pill,
        child: Container(
          padding: const EdgeInsets.fromLTRB(Space.sm, 7, Space.md, 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: Radii.pill,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.wallet, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                Money.format(balancePaise),
                style: context.text.money.copyWith(fontSize: 14, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

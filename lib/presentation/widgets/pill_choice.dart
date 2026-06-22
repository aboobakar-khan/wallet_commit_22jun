import 'package:flutter/material.dart';

import '../../core/core.dart';

/// A selectable pill — the app's one selection-chip shape (setup, presets…).
class PillChoice extends StatelessWidget {
  const PillChoice({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.sublabel,
  });
  final String label;
  final String? sublabel;
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
          color: selected ? colors.primary : colors.surface,
          borderRadius: Radii.pill,
          border: Border.all(color: selected ? colors.primary : colors.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.type.labelLarge?.copyWith(
                color: selected ? colors.onPrimary : colors.ink,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(width: 5),
              Text(
                sublabel!,
                style: context.type.bodySmall?.copyWith(
                  color: selected
                      ? colors.onPrimary.withValues(alpha: 0.8)
                      : colors.inkMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

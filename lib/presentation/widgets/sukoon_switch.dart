import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Hand-built switch — the stock Material Switch at defaults is a slop tell. The
/// thumb slides with a quick, critically-damped motion (Register B); no bounce.
class SukoonSwitch extends StatelessWidget {
  const SukoonSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: enabled
            ? () {
                Haptics.select();
                onChanged!(!value);
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: Motion.state,
            curve: Motion.decelerate,
            width: 50,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? colors.primary : colors.surfaceMuted,
              borderRadius: Radii.pill,
              border: Border.all(
                  color: value ? colors.primary : colors.hairline),
            ),
            child: AnimatedAlign(
              duration: Motion.state,
              curve: Motion.decelerate,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? colors.onPrimary : colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.ink.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../domain/enums/prayer_status.dart';

/// Hand-built segmented control for a single prayer: Prayed / Late / Not yet.
/// The selection indicator slides (Register B, critically damped). Late is kept
/// — the control never frames it as a failure. `null` clears to "not yet".
class PrayerStatusToggle extends StatelessWidget {
  const PrayerStatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final PrayerStatus? value;
  final ValueChanged<PrayerStatus?> onChanged;
  final bool enabled;

  static const _options = <(PrayerStatus?, String)>[
    (PrayerStatus.prayed, 'Prayed'),
    (PrayerStatus.late, 'Late'),
    (null, 'Not yet'),
  ];

  int get _selectedIndex => switch (value) {
        PrayerStatus.prayed => 0,
        PrayerStatus.late => 1,
        _ => 2,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const pad = 4.0;
          final segW = (constraints.maxWidth - pad * 2) / _options.length;
          return Container(
            padding: const EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: Radii.pill,
              border: Border.all(color: colors.hairline),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Motion.state,
                  curve: Motion.decelerate,
                  left: segW * _selectedIndex,
                  top: 0,
                  bottom: 0,
                  width: segW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIndex == 2 ? colors.surface : colors.primary,
                      borderRadius: Radii.pill,
                      border: _selectedIndex == 2
                          ? Border.all(color: colors.hairline)
                          : null,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _options.length; i++)
                      SizedBox(
                        width: segW,
                        height: 40,
                        child: _Segment(
                          label: _options[i].$2,
                          selected: _selectedIndex == i,
                          onTap: enabled
                              ? () {
                                  if (_selectedIndex == i) return;
                                  Haptics.select();
                                  onChanged(_options[i].$1);
                                }
                              : null,
                          selectedColor:
                              i == 2 ? colors.ink : colors.onPrimary,
                          unselectedColor: colors.inkMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: Motion.state,
          style: context.type.labelLarge!.copyWith(
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

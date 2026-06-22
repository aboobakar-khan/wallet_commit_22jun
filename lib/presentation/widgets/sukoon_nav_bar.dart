import 'package:flutter/material.dart';

import '../../core/core.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Hand-built bottom navigation. Selected destination warms to primary with a
/// soft seat behind it; transitions are quick and damped (Register B). No stock
/// NavigationBar at defaults (a slop tell).
class SukoonNavBar extends StatelessWidget {
  const SukoonNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavCell(
                    item: items[i],
                    selected: i == index,
                    onTap: () {
                      if (i == index) return;
                      Haptics.select();
                      onChanged(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary : colors.inkMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Motion.state,
              curve: Motion.standard,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? colors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: Radii.pill,
              ),
              child: Icon(item.icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: Motion.state,
              style: context.type.labelSmall!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

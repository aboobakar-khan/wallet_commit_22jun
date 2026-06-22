import 'package:flutter/material.dart';

import '../../core/core.dart';

/// A surface — hairline + faint tint + low soft shadow. The app's structural
/// unit. Elevation is minimal by role, never a uniform drop-shadow on all.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.md),
    this.onTap,
    this.color,
    this.radius = Radii.card,
    this.elevated = false,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  final bool elevated;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius_ = BorderRadius.circular(radius);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius_,
        border: border ? Border.all(color: colors.hairline) : null,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.ink.withValues(alpha: colors.isNight ? 0.32 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: radius_,
      child: InkWell(
        onTap: () {
          Haptics.select();
          onTap!();
        },
        borderRadius: radius_,
        child: content,
      ),
    );
  }
}

/// A small uppercase-ish section label — used to title groups quietly.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: context.type.labelSmall?.copyWith(
                letterSpacing: 1.4,
                color: context.colors.inkMuted,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A single hairline.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});
  final double indent;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: indent),
        child: Container(height: 1, color: context.colors.hairline),
      );
}

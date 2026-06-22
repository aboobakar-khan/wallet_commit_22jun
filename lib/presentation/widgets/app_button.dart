import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'pulse.dart';

enum AppButtonTone { primary, sadaqah, neutral }

/// The primary action — hand-built, critically-damped press (Register B), no
/// gradient glow. Differentiated by [tone], not by stacking shadows.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.tone = AppButtonTone.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final AppButtonTone tone;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onPressed != null && !widget.loading;
    final (bg, fg, border) = switch (widget.tone) {
      AppButtonTone.primary => (colors.primary, colors.onPrimary, null),
      AppButtonTone.sadaqah => (colors.sadaqah, colors.onPrimary, null),
      AppButtonTone.neutral => (colors.surface, colors.ink, colors.hairline),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                Haptics.select();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: Motion.tap,
          curve: Motion.standard,
          child: AnimatedOpacity(
            duration: Motion.state,
            opacity: enabled ? 1 : 0.45,
            child: Container(
              width: widget.expand ? double.infinity : null,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: Radii.card_,
                border: border == null ? null : Border.all(color: border),
                boxShadow: widget.tone == AppButtonTone.neutral || !enabled
                    ? null
                    : [
                        BoxShadow(
                          color: bg.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Center(
                child: widget.loading
                    ? Pulse(color: fg)
                    : Row(
                        mainAxisSize:
                            widget.expand ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: fg),
                            const SizedBox(width: Space.xs),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: context.type.labelLarge
                                  ?.copyWith(color: fg, fontSize: 16),
                            ),
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

/// A quiet, borderless text action for secondary paths.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              Haptics.select();
              onPressed!();
            },
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        shape: const RoundedRectangleBorder(borderRadius: Radii.small_),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
          Text(label, style: context.type.labelLarge?.copyWith(color: colors.primary)),
        ],
      ),
    );
  }
}

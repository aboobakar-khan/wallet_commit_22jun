import 'package:flutter/material.dart';

import '../../core/core.dart';

enum ToastTone { neutral, light, sadaqah }

/// A calm toast — a hand-built replacement for the Material SnackBar (a slop
/// tell). Rises gently, rests, fades. In-voice, never system-voiced.
void showAppToast(
  BuildContext context,
  String message, {
  IconData? icon,
  ToastTone tone = ToastTone.neutral,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _Toast(
      message: message,
      icon: icon,
      tone: tone,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.onDone,
    this.icon,
    this.tone = ToastTone.neutral,
  });
  final String message;
  final VoidCallback onDone;
  final IconData? icon;
  final ToastTone tone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.transition);

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _c.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (widget.tone) {
      ToastTone.sadaqah => colors.sadaqah,
      ToastTone.light => colors.dawn,
      ToastTone.neutral => colors.primary,
    };
    final curve = CurvedAnimation(parent: _c, curve: Motion.decelerate);
    return Positioned(
      left: Space.lg,
      right: Space.lg,
      bottom: 0,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 96),
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: curve,
            builder: (context, child) => Opacity(
              opacity: curve.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - curve.value) * 14),
                child: child,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Space.md, vertical: Space.sm),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: Radii.pill,
                  border: Border.all(color: colors.hairline),
                  boxShadow: [
                    BoxShadow(
                      color: colors.ink.withValues(alpha: colors.isNight ? 0.4 : 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: accent),
                      const SizedBox(width: Space.xs),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: context.type.labelMedium
                            ?.copyWith(color: colors.ink),
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

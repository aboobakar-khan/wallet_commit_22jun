import 'package:flutter/material.dart';

/// A quiet three-dot breathing loader — replaces the stock spinner (a slop
/// tell). Dots fade in sequence like a slow pulse, in the ceremonial register.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.color, this.size = 7});
  final Color color;
  final double size;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_c.value - i * 0.18) % 1.0;
            final wave = (0.4 + 0.6 * (1 - (phase - 0.5).abs() * 2)).clamp(0.3, 1.0);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.35),
              child: Opacity(
                opacity: wave,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

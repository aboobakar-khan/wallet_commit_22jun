import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';

/// The living sky behind the Day's Arc. Maps the real current time to a
/// pre-dawn → midday → dusk → night gradient and breathes a faint luminance
/// shimmer (~7s). The single aesthetic risk of the app (THESIS), mitigated by a
/// constant contrast scrim drawn by the content above it and a tiny shimmer
/// amplitude so it never becomes a colour rave.
class _SkyStop {
  const _SkyStop(this.hour, this.top, this.bottom);
  final double hour;
  final Color top;
  final Color bottom;
}

abstract final class SkyPalette {
  // Anchored across the day. Colours are desaturated on purpose.
  static const List<_SkyStop> _stops = [
    _SkyStop(0.0, Color(0xFF0B1A26), Color(0xFF112A36)), // deep night
    _SkyStop(5.0, Color(0xFF18253B), Color(0xFF34324C)), // pre-dawn indigo
    _SkyStop(6.5, Color(0xFF324369), Color(0xFFC8895F)), // dawn — amber horizon
    _SkyStop(8.0, Color(0xFF6F97B7), Color(0xFFDBC8A4)), // early morning
    _SkyStop(12.0, Color(0xFF8FB3C3), Color(0xFFE9EDE7)), // midday clarity
    _SkyStop(15.5, Color(0xFF85ABBE), Color(0xFFEBD9B3)), // warm afternoon
    _SkyStop(18.0, Color(0xFF3C4E74), Color(0xFFE0915E)), // dusk amber/rose
    _SkyStop(19.5, Color(0xFF1F2C46), Color(0xFF8A5A6A)), // deep dusk
    _SkyStop(21.0, Color(0xFF0E1E2C), Color(0xFF163040)), // night
  ];

  /// (top, bottom) gradient colours for a given local time.
  static (Color, Color) at(DateTime time) {
    final h = time.hour + time.minute / 60.0;
    for (var i = 0; i < _stops.length; i++) {
      final a = _stops[i];
      final b = i + 1 < _stops.length ? _stops[i + 1] : null;
      if (b == null) {
        // wrap from last stop (21:00) to first (24:00 == 0:00)
        final span = 24.0 - a.hour;
        final t = ((h - a.hour) / span).clamp(0.0, 1.0);
        return (
          Color.lerp(a.top, _stops.first.top, t)!,
          Color.lerp(a.bottom, _stops.first.bottom, t)!,
        );
      }
      if (h >= a.hour && h < b.hour) {
        final t = (h - a.hour) / (b.hour - a.hour);
        return (Color.lerp(a.top, b.top, t)!, Color.lerp(a.bottom, b.bottom, t)!);
      }
    }
    return (_stops.first.top, _stops.first.bottom);
  }
}

class SkyBackdrop extends StatefulWidget {
  const SkyBackdrop({
    super.key,
    required this.time,
    required this.reduceMotion,
    this.child,
  });

  final DateTime time;
  final bool reduceMotion;
  final Widget? child;

  @override
  State<SkyBackdrop> createState() => _SkyBackdropState();
}

class _SkyBackdropState extends State<SkyBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(vsync: this, duration: Motion.ambientBreath);
    if (!widget.reduceMotion) _breath.repeat();
  }

  @override
  void didUpdateWidget(covariant SkyBackdrop old) {
    super.didUpdateWidget(old);
    if (widget.reduceMotion && _breath.isAnimating) {
      _breath.stop();
    } else if (!widget.reduceMotion && !_breath.isAnimating) {
      _breath.repeat();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (top, bottom) = SkyPalette.at(widget.time);
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        // Tiny luminance breath — never more than a few percent.
        final shimmer = widget.reduceMotion
            ? 0.0
            : math.sin(_breath.value * 2 * math.pi) * 0.03;
        return CustomPaint(
          painter: _SkyPainter(top: top, bottom: bottom, shimmer: shimmer),
          isComplex: true,
          willChange: !widget.reduceMotion,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.top, required this.bottom, required this.shimmer});

  final Color top;
  final Color bottom;
  final double shimmer;

  Color _breathe(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + shimmer).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_breathe(top), _breathe(bottom)],
      stops: const [0.0, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // A soft bloom of light low on the horizon — where the sun lives.
    final glowCenter = Offset(size.width * 0.5, size.height * 0.86);
    final glow = RadialGradient(
      colors: [
        _breathe(bottom).withValues(alpha: 0.55),
        _breathe(bottom).withValues(alpha: 0.0),
      ],
    );
    final glowRect = Rect.fromCircle(center: glowCenter, radius: size.width * 0.7);
    canvas.drawRect(glowRect, Paint()..shader = glow.createShader(glowRect));
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.top != top || old.bottom != bottom || old.shimmer != shimmer;
}

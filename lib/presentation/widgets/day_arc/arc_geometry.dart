import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The shared geometry of the Day's Arc, used identically by the painter (sky,
/// line, light) and by the positioned prayer nodes so they always agree.
///
/// A prayer's horizontal position is its fixed [Prayer.arcT]; the vertical
/// position follows a sun-path lift (`sin(πt)`) so the day rises to a midday
/// apex and settles toward night — Fajr dawn-left low, Isha night-right low.
class DayArcGeometry {
  DayArcGeometry({
    required this.size,
    double horizontalPadFraction = 0.13,
    double apexFraction = 0.32,
    double baseFraction = 0.72,
  })  : hPad = size.width * horizontalPadFraction,
        apexY = size.height * apexFraction,
        baseY = size.height * baseFraction;

  final Size size;
  final double hPad;
  final double apexY;
  final double baseY;

  Offset pointAt(double t) {
    final x = hPad + t * (size.width - 2 * hPad);
    final lift = math.sin(math.pi * t.clamp(0.0, 1.0)); // 0 → 1 → 0
    final y = baseY - lift * (baseY - apexY);
    return Offset(x, y);
  }

  /// A smooth sampled path of the whole arc.
  Path arcPath({int samples = 96}) {
    final path = Path();
    for (var i = 0; i <= samples; i++) {
      final o = pointAt(i / samples);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  /// The arc path from 0 up to [t] — used to draw accumulated light.
  Path arcPathTo(double t, {int samples = 96}) {
    final path = Path();
    final end = t.clamp(0.0, 1.0);
    final count = math.max(1, (samples * end).round());
    path.moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i <= count; i++) {
      final o = pointAt(end * i / count);
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }
}

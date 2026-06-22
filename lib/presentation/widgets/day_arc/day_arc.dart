import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/motion.dart';
import '../../../domain/domain.dart';
import 'arc_geometry.dart';
import 'prayer_node.dart';
import 'sky.dart';

/// Hero tag for a prayer's node → its detail screen.
String prayerHeroTag(Prayer p) => 'prayer-node-${p.name}';

/// The signature element. Five prayer nodes along a sun-path arc over a living
/// sky; the arc fills with light as prayers are kept (THESIS §6).
class DayArc extends StatelessWidget {
  const DayArc({
    super.key,
    required this.dayLog,
    required this.time,
    required this.reduceMotion,
    this.onTapPrayer,
    this.interactive = true,
    this.heroes = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  final DayLog dayLog;
  final DateTime time;
  final bool reduceMotion;
  final void Function(Prayer prayer)? onTapPrayer;
  final bool interactive;
  final bool heroes;
  final BorderRadius borderRadius;

  double get _litProgress {
    var maxT = 0.0;
    for (final e in dayLog.entries) {
      if (e.isKept && e.prayer.arcT > maxT) maxT = e.prayer.arcT;
    }
    return maxT;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geo = DayArcGeometry(size: size);
        final d = (size.width * 0.135).clamp(46.0, 62.0);

        return ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              Positioned.fill(
                child: SkyBackdrop(time: time, reduceMotion: reduceMotion),
              ),
              // a gentle top-down scrim keeps text legible on any sky hour
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF071018).withValues(alpha: 0.18),
                        const Color(0xFF071018).withValues(alpha: 0.0),
                        const Color(0xFF071018).withValues(alpha: 0.12),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: TweenAnimationBuilder<double>(
                    duration: reduceMotion
                        ? const Duration(milliseconds: 180)
                        : Motion.settle,
                    curve: Motion.sine,
                    tween: Tween<double>(end: _litProgress),
                    builder: (context, value, _) => CustomPaint(
                      painter: _ArcLinePainter(geometry: geo, progress: value),
                    ),
                  ),
                ),
              ),
              for (final entry in dayLog.entries)
                ..._nodeAndLabel(context, geo, entry, d),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _nodeAndLabel(
    BuildContext context,
    DayArcGeometry geo,
    DayPrayerEntry entry,
    double d,
  ) {
    final p = geo.pointAt(entry.prayer.arcT);
    const labelW = 72.0;
    final caption = switch (entry.effective) {
      PrayerStatus.late => 'kept · late',
      PrayerStatus.missed => 'missed',
      _ => null,
    };
    return [
      Positioned(
        left: p.dx - d / 2,
        top: p.dy - d / 2,
        width: d,
        height: d,
        child: PrayerNode(
          prayer: entry.prayer,
          status: entry.effective,
          reduceMotion: reduceMotion,
          diameter: d,
          introIndex: entry.prayer.index,
          enabled: interactive && onTapPrayer != null,
          heroTag: heroes ? prayerHeroTag(entry.prayer) : null,
          onTap: onTapPrayer == null ? null : () => onTapPrayer!(entry.prayer),
        ),
      ),
      Positioned(
        left: p.dx - labelW / 2,
        top: p.dy + d / 2 + 6,
        width: labelW,
        child: IgnorePointer(
          child: Column(
            children: [
              Text(
                entry.prayer.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.newsreader(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF4EFE6),
                  shadows: const [Shadow(color: Color(0xCC04101A), blurRadius: 6)],
                ),
              ),
              if (caption != null)
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.4,
                    color: entry.isMissed
                        ? const Color(0xFFE7AFA4)
                        : const Color(0xFFE8C98E),
                    shadows: const [
                      Shadow(color: Color(0xCC04101A), blurRadius: 6)
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _ArcLinePainter extends CustomPainter {
  _ArcLinePainter({required this.geometry, required this.progress});

  final DayArcGeometry geometry;
  final double progress;

  static const _seat = Color(0xFF071018);
  static const _light = Color(0xFFF2ECE0);
  static const _amber = Color(0xFFE8B468);

  @override
  void paint(Canvas canvas, Size size) {
    final base = geometry.arcPath();

    // A soft dark under-stroke so the line reads on a bright sky.
    canvas.drawPath(
      base,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = _seat.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      base,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = _light.withValues(alpha: 0.30),
    );

    if (progress > 0.001) {
      final lit = geometry.arcPathTo(progress);
      // glow under the lit portion
      canvas.drawPath(
        lit,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = _amber.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawPath(
        lit,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..color = _amber.withValues(alpha: 0.95),
      );
    }
  }

  @override
  bool shouldRepaint(_ArcLinePainter old) => old.progress != progress;
}

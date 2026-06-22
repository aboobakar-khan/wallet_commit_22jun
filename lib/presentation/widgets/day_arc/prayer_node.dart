import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../domain/enums/prayer.dart';
import '../../../domain/enums/prayer_status.dart';

double _lerp(double a, double b, double t) => a + (b - a) * t;

bool _isKept(PrayerStatus? s) => s == PrayerStatus.prayed || s == PrayerStatus.late;

/// A single node on the Day's Arc. Logging blooms it into light (THESIS §5):
/// a radial light scales up and fades in, a faint ring expands and fades, the
/// core settles with a critically-damped ease — light arriving, not a button.
class PrayerNode extends StatefulWidget {
  const PrayerNode({
    super.key,
    required this.prayer,
    required this.status,
    required this.reduceMotion,
    this.diameter = 58,
    this.introIndex = 0,
    this.onTap,
    this.enabled = true,
    this.heroTag,
    this.playIntro = true,
  });

  /// The *effective* status: null = pending (unlit), or prayed / late / missed.
  final PrayerStatus? status;
  final Prayer prayer;
  final bool reduceMotion;
  final double diameter;
  final int introIndex;
  final VoidCallback? onTap;
  final bool enabled;
  final Object? heroTag;

  /// When false, the node appears at full presence immediately (used as a Hero
  /// destination, where the Hero itself carries the motion).
  final bool playIntro;

  @override
  State<PrayerNode> createState() => _PrayerNodeState();
}

class _PrayerNodeState extends State<PrayerNode>
    with TickerProviderStateMixin {
  late final AnimationController _bloom;
  late final AnimationController _intro;
  late final CurvedAnimation _bloomCurve;

  @override
  void initState() {
    super.initState();
    _bloom = AnimationController(
      vsync: this,
      duration: Motion.bloom,
      value: _isKept(widget.status) ? 1.0 : 0.0,
    );
    _bloomCurve = CurvedAnimation(parent: _bloom, curve: Motion.sine);
    _intro = AnimationController(vsync: this, duration: Motion.state);
    if (widget.reduceMotion || !widget.playIntro) {
      _intro.value = 1.0;
    } else {
      Future.delayed(Motion.nodeStagger * widget.introIndex, () {
        if (mounted) _intro.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant PrayerNode old) {
    super.didUpdateWidget(old);
    final wasKept = _isKept(old.status);
    final nowKept = _isKept(widget.status);
    if (!wasKept && nowKept) {
      widget.reduceMotion ? _bloom.value = 1.0 : _bloom.forward(from: 0.0);
    } else if (wasKept && !nowKept) {
      _bloom.value = 0.0;
    }
  }

  @override
  void dispose() {
    _bloomCurve.dispose();
    _bloom.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const scheme = _NodeColors.sky;
    Widget node = AnimatedBuilder(
      animation: Listenable.merge([_bloom, _intro]),
      builder: (context, _) {
        final introT = _intro.value;
        return Opacity(
          opacity: introT.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - introT) * 6),
            child: Transform.scale(
              scale: _lerp(0.96, 1.0, introT),
              child: CustomPaint(
                size: Size.square(widget.diameter),
                painter: _PrayerNodePainter(
                  status: widget.status,
                  bloom: _bloomCurve.value,
                  colors: scheme,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.heroTag != null) {
      node = Hero(
        tag: widget.heroTag!,
        child: Material(type: MaterialType.transparency, child: node),
      );
    }

    return Semantics(
      button: widget.enabled && widget.onTap != null,
      label: _semanticLabel(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: node,
      ),
    );
  }

  String _semanticLabel() {
    final s = switch (widget.status) {
      PrayerStatus.prayed => 'prayed',
      PrayerStatus.late => 'prayed, late',
      PrayerStatus.missed => 'missed',
      null => 'not yet logged',
    };
    return '${widget.prayer.displayName}, $s';
  }
}

/// Node colours, chosen for the *sky* (not the theme) so light reads on any hour.
class _NodeColors {
  const _NodeColors({
    required this.amber,
    required this.missed,
    required this.lightRing,
    required this.seat,
  });

  final Color amber;
  final Color missed;
  final Color lightRing;
  final Color seat;

  static const sky = _NodeColors(
    amber: Color(0xFFE8B468),
    missed: Color(0xFFC97A6D),
    lightRing: Color(0xFFF2ECE0),
    seat: Color(0xFF071018),
  );
}

class _PrayerNodePainter extends CustomPainter {
  _PrayerNodePainter({
    required this.status,
    required this.bloom,
    required this.colors,
  });

  final PrayerStatus? status;
  final double bloom;
  final _NodeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final coreR = size.shortestSide * 0.19;

    // A soft seat so any node reads against any sky.
    canvas.drawCircle(
      c,
      coreR * 1.3,
      Paint()
        ..color = colors.seat.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, coreR * 0.6),
    );

    if (_isKept(status)) {
      // Radial light: scales 0.6 → 1.0, opacity 0 → 1 (Register A).
      final glowScale = _lerp(0.6, 1.0, bloom);
      final glowR = coreR * 3.0 * glowScale;
      final glowRect = Rect.fromCircle(center: c, radius: glowR);
      canvas.drawCircle(
        c,
        glowR,
        Paint()
          ..shader = RadialGradient(colors: [
            colors.amber.withValues(alpha: 0.45 * bloom),
            colors.amber.withValues(alpha: 0.0),
          ]).createShader(glowRect),
      );

      // A faint ring expands and fades on a fresh bloom only.
      if (bloom > 0 && bloom < 1) {
        canvas.drawCircle(
          c,
          coreR * _lerp(1.0, 2.6, bloom),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = colors.amber.withValues(alpha: (1 - bloom) * 0.5),
        );
      }

      final coreScale = _lerp(0.92, 1.0, bloom);
      if (status == PrayerStatus.prayed) {
        canvas.drawCircle(c, coreR * coreScale, Paint()..color = colors.amber);
        // a small warm highlight — the light has a centre
        canvas.drawCircle(
          c.translate(-coreR * 0.22, -coreR * 0.22),
          coreR * 0.34,
          Paint()
            ..color = Color.lerp(colors.amber, Colors.white, 0.5)!
                .withValues(alpha: 0.7),
        );
      } else {
        // late — kept, but ringed to note the lateness, calmly.
        canvas.drawCircle(
          c,
          coreR * coreScale,
          Paint()..color = colors.amber.withValues(alpha: 0.22),
        );
        canvas.drawCircle(
          c,
          coreR * coreScale,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..color = colors.amber,
        );
        canvas.drawCircle(c, coreR * 0.4, Paint()..color = colors.amber);
      }
    } else if (status == PrayerStatus.missed) {
      // Quiet dignity — a recessive ring, never an alarm.
      canvas.drawCircle(
        c,
        coreR,
        Paint()..color = colors.missed.withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        c,
        coreR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = colors.missed.withValues(alpha: 0.6),
      );
    } else {
      // Pending — an unlit lantern waiting for light.
      canvas.drawCircle(
        c,
        coreR * 0.92,
        Paint()..color = colors.lightRing.withValues(alpha: 0.06),
      );
      canvas.drawCircle(
        c,
        coreR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = colors.lightRing.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_PrayerNodePainter old) =>
      old.status != status || old.bloom != bloom;
}

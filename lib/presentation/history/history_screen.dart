import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../today/prayer_detail_screen.dart';
import '../widgets/app_icons.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final commitments = ref.watch(commitmentsProvider).value ?? const <Commitment>[];
    final active = ref.watch(activeCommitmentProvider).value;
    final today = ref.watch(todayProvider);
    final focus = active ?? (commitments.isNotEmpty ? commitments.last : null);

    if (focus == null) {
      return ScreenScaffold(
        title: 'History',
        body: Padding(
          padding: const EdgeInsets.only(top: Space.xxl),
          child: Column(
            children: [
              Icon(AppIcons.history, size: 36, color: colors.inkMuted),
              const SizedBox(height: Space.md),
              Text('No days yet',
                  style: context.text.serifTitle, textAlign: TextAlign.center),
              const SizedBox(height: Space.xs),
              Text(
                'Once you begin a commitment, each day’s light gathers here.',
                textAlign: TextAlign.center,
                style: context.type.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final elapsed =
        (Day.between(focus.startDate, today) + 1).clamp(1, focus.totalDays);
    final days = [
      for (var i = 0; i < elapsed; i++) focus.startDate.add(Duration(days: i)),
    ];

    return ScreenScaffold(
      title: 'History',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.xs),
          const SectionLabel('This commitment'),
          LayoutBuilder(
            builder: (context, c) {
              const cols = 7;
              const gap = 8.0;
              final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final date in days)
                    SizedBox(
                      width: cellW,
                      height: cellW * 1.15,
                      child: _DayCell(date: date),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: Space.lg),
          _Legend(),
          const SizedBox(height: Space.xl),
          const SectionLabel('Commitments'),
          for (final c in commitments.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: _CommitmentRow(commitment: c),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dayLog = ref.watch(dayLogProvider(date));
    final statuses = [for (final e in dayLog.entries) e.effective];
    return GestureDetector(
      onTap: () {
        Haptics.select();
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DayReviewScreen(date: date)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: Radii.small_,
          border: Border.all(color: colors.hairline),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Text('${date.day}',
                style: context.type.labelSmall?.copyWith(color: colors.inkMuted, fontSize: 10)),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _MiniDayPainter(
                  statuses: statuses,
                  amber: colors.dawn,
                  missed: colors.sadaqah,
                  pending: colors.inkMuted.withValues(alpha: 0.4),
                  arc: colors.hairline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDayPainter extends CustomPainter {
  _MiniDayPainter({
    required this.statuses,
    required this.amber,
    required this.missed,
    required this.pending,
    required this.arc,
  });
  final List<PrayerStatus?> statuses;
  final Color amber;
  final Color missed;
  final Color pending;
  final Color arc;

  static const _ts = [0.1, 0.32, 0.5, 0.68, 0.9];

  Offset _point(Size s, double t) {
    final x = s.width * (0.1 + 0.8 * t);
    final y = s.height * 0.86 - math.sin(math.pi * t) * s.height * 0.62;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i <= 24; i++) {
      final o = _point(size, i / 24);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = arc,
    );
    for (var i = 0; i < _ts.length; i++) {
      final o = _point(size, _ts[i]);
      final s = statuses[i];
      if (s == PrayerStatus.prayed || s == PrayerStatus.late) {
        canvas.drawCircle(
          o,
          5,
          Paint()
            ..shader = RadialGradient(colors: [
              amber.withValues(alpha: 0.4),
              amber.withValues(alpha: 0.0),
            ]).createShader(Rect.fromCircle(center: o, radius: 5)),
        );
        canvas.drawCircle(o, 2.2, Paint()..color = amber);
      } else if (s == PrayerStatus.missed) {
        canvas.drawCircle(
          o,
          2.2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = missed.withValues(alpha: 0.7),
        );
      } else {
        canvas.drawCircle(o, 1.4, Paint()..color = pending);
      }
    }
  }

  @override
  bool shouldRepaint(_MiniDayPainter old) => true;
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget dot(Color c, String label, {bool ring = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ring ? Colors.transparent : c,
                shape: BoxShape.circle,
                border: ring ? Border.all(color: c) : null,
              ),
            ),
            const SizedBox(width: 5),
            Text(label, style: context.type.bodySmall),
          ],
        );
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.xs,
      children: [
        dot(colors.dawn, 'Kept'),
        dot(colors.sadaqah, 'Missed', ring: true),
        dot(colors.inkMuted.withValues(alpha: 0.4), 'Not logged'),
      ],
    );
  }
}

class _CommitmentRow extends StatelessWidget {
  const _CommitmentRow({required this.commitment});
  final Commitment commitment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = commitment;
    final range =
        '${DateFormat('d MMM').format(c.startDate)} – ${DateFormat('d MMM').format(c.endDate)}';
    final (statusLabel, statusColor) = switch (c.status) {
      CommitmentStatus.active => ('Active', colors.primary),
      CommitmentStatus.completed => ('Completed', colors.dawn),
      CommitmentStatus.cancelled => ('Cancelled', colors.inkMuted),
    };
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c.totalDays}-day commitment',
                    style: context.type.labelLarge?.copyWith(color: colors.ink)),
                const SizedBox(height: 2),
                Text('$range · ${Money.format(c.stakePerPrayerPaise)} / prayer',
                    style: context.type.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: Radii.pill,
            ),
            child: Text(statusLabel,
                style: context.type.labelSmall?.copyWith(color: statusColor)),
          ),
        ],
      ),
    );
  }
}

/// A read-only review of one past day — five prayers, each opening its detail.
class DayReviewScreen extends ConsumerWidget {
  const DayReviewScreen({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayLog = ref.watch(dayLogProvider(date));
    return ScreenScaffold(
      title: DateFormat('EEEE, d MMM').format(date),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.xs),
          Text(
            dayLog.locked
                ? '${dayLog.keptCount} of 5 kept · this day has settled'
                : '${dayLog.keptCount} of 5 kept · still open until 2 a.m.',
            style: context.type.bodyMedium,
          ),
          const SizedBox(height: Space.lg),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < dayLog.entries.length; i++) ...[
                  _PrayerRow(entry: dayLog.entries[i], date: date),
                  if (i != dayLog.entries.length - 1) const Hairline(indent: Space.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.entry, required this.date});
  final DayPrayerEntry entry;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () {
        Haptics.select();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PrayerDetailScreen(prayer: entry.prayer, date: date),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
        child: Row(
          children: [
            Expanded(
              child: Text(entry.prayer.displayName, style: context.text.prayerName),
            ),
            StatusChip(status: entry.effective),
            const SizedBox(width: Space.xs),
            Icon(AppIcons.chevron, size: 18, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final PrayerStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, color) = switch (status) {
      PrayerStatus.prayed => ('Kept', colors.dawn),
      PrayerStatus.late => ('Kept · late', colors.dawn),
      PrayerStatus.missed => ('Missed', colors.sadaqah),
      null => ('Not logged', colors.inkMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: Radii.pill,
      ),
      child: Text(label, style: context.type.labelSmall?.copyWith(color: color)),
    );
  }
}

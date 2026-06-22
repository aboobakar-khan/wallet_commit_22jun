import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../data/repositories.dart' show DayLockedException;
import '../../domain/domain.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_toast.dart';
import '../widgets/arabic_phrase.dart';
import '../widgets/day_arc/day_arc.dart';
import '../widgets/day_arc/prayer_node.dart';
import '../widgets/day_arc/sky.dart';
import '../widgets/prayer_status_toggle.dart';
import '../widgets/surface_card.dart';

/// Detail for one prayer on one day — the full control: prayed / late / not yet,
/// the lock explanation when past, and the always-present qada note. No shame.
class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({
    super.key,
    required this.prayer,
    required this.date,
  });

  final Prayer prayer;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dayLog = ref.watch(dayLogProvider(date));
    final entry = dayLog.entry(prayer);
    final commitment = ref.watch(activeCommitmentProvider).value;
    final now = ref.watch(clockProvider).now();
    final (skyTop, skyBottom) = SkyPalette.at(now);

    Future<void> set(PrayerStatus? status) async {
      try {
        if (status == null) {
          await ref.read(actionsProvider).clearPrayer(date, prayer);
        } else {
          if (entry.logged == null) Haptics.log();
          await ref.read(actionsProvider).logPrayer(date, prayer, status);
        }
      } on DayLockedException {
        if (context.mounted) {
          showAppToast(context, 'This day has locked and can’t be edited.',
              icon: AppIcons.lock);
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(
        children: [
          // A small sky band so the hero node reads continuously with Today.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [skyTop, skyBottom],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.lg),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _LightBack(onTap: () => Navigator.of(context).maybePop()),
                    ),
                    const SizedBox(height: Space.xs),
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: PrayerNode(
                        prayer: prayer,
                        status: entry.effective,
                        reduceMotion: effectiveReduceMotion(ref, context),
                        diameter: 96,
                        playIntro: false,
                        enabled: false,
                        heroTag: prayerHeroTag(prayer),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    Text(
                      prayer.displayName,
                      style: context.text.serifTitle.copyWith(
                        color: const Color(0xFFF4EFE6),
                        fontSize: 28,
                        shadows: const [Shadow(color: Color(0xAA04101A), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    ArabicPhrase(prayer.arabicName,
                        color: const Color(0xFFEAD9B6), fontSize: 20),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  Space.screenGutter, Space.lg, Space.screenGutter, Space.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dateLabel(ref), style: context.type.bodyMedium),
                  const SizedBox(height: Space.lg),
                  if (dayLog.locked)
                    _LockedNotice(status: entry.effective)
                  else ...[
                    Text('How was $prayerNameLower?',
                        style: context.type.titleMedium),
                    const SizedBox(height: Space.sm),
                    PrayerStatusToggle(
                      value: entry.logged,
                      onChanged: set,
                    ),
                    const SizedBox(height: Space.sm),
                    Text('Late counts as kept — it’s never charged.',
                        style: context.type.bodySmall),
                  ],
                  const SizedBox(height: Space.xl),
                  if (commitment != null)
                    _StakeNote(stakePaise: commitment.stakePerPrayerPaise),
                  const SizedBox(height: Space.md),
                  const _QadaNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get prayerNameLower => prayer.displayName;

  String _dateLabel(WidgetRef ref) {
    final today = ref.read(todayProvider);
    if (Day.isSame(date, today)) return 'Today';
    final diff = Day.between(date, today);
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _LightBack extends StatelessWidget {
  const _LightBack({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF071018).withValues(alpha: 0.22),
      shape: CircleBorder(
          side: BorderSide(color: const Color(0xFFF4EFE6).withValues(alpha: 0.16))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Haptics.select();
          onTap();
        },
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(AppIcons.back, size: 20, color: Color(0xFFF4EFE6)),
        ),
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  const _LockedNotice({required this.status});
  final PrayerStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = switch (status) {
      PrayerStatus.prayed => 'Kept — prayed.',
      PrayerStatus.late => 'Kept — prayed late.',
      PrayerStatus.missed => 'Genuinely missed.',
      null => 'Not logged.',
    };
    return SurfaceCard(
      color: colors.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.lock, size: 16, color: colors.inkMuted),
              const SizedBox(width: Space.xs),
              Text('This day has settled',
                  style: context.type.labelLarge?.copyWith(color: colors.ink)),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(label, style: context.type.titleMedium),
          const SizedBox(height: Space.xs),
          Text(
            'Days stay open to edit until 2 a.m. the next morning, then they '
            'settle. This one is now part of your record.',
            style: context.type.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StakeNote extends StatelessWidget {
  const _StakeNote({required this.stakePaise});
  final int stakePaise;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.info, size: 16, color: colors.inkMuted),
        const SizedBox(width: Space.xs),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: context.type.bodyMedium?.copyWith(height: 1.5),
              children: [
                const TextSpan(text: 'If genuinely missed, '),
                TextSpan(
                    text: Money.format(stakePaise),
                    style: context.text.money.copyWith(color: colors.ink)),
                const TextSpan(
                    text:
                        ' later joins the sadaqah pool — a nudge, never a payment for the prayer.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QadaNote extends StatelessWidget {
  const _QadaNote();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.heart, size: 16, color: colors.primary),
              const SizedBox(width: Space.xs),
              Text('Making it up (qada)',
                  style: context.type.labelLarge?.copyWith(color: colors.ink)),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            'A missed prayer can always be made up. Qada and tawbah stand — this '
            'is between you and Allah, and the door is always open.',
            style: context.type.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

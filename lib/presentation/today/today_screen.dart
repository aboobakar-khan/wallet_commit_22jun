import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../commitment/commitment_end_screen.dart';
import '../commitment/commitment_setup_screen.dart';
import '../dev/dev_panel.dart';
import '../payments/top_up_sheet.dart';
import '../settings/settings_screen.dart';
import '../wallet/wallet_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';
import '../widgets/balance_chip.dart';
import '../widgets/day_arc/day_arc.dart';
import '../widgets/surface_card.dart';
import 'prayer_detail_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCommitmentProvider).value;
    final pendingEnd = ref.watch(pendingEndCommitmentProvider);

    if (active != null) return _ActiveToday(commitment: active);
    if (pendingEnd != null) return _PendingEndToday(commitment: pendingEnd);
    return const _EmptyToday();
  }
}

void _openSettings(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SettingsScreen()));

Widget _topBar(BuildContext context, WidgetRef ref, {required bool overSky}) {
  final colors = context.colors;
  final name = ref.watch(profileProvider).value?.displayName ?? 'Friend';
  final fg = overSky ? const Color(0xFFF4EFE6) : colors.ink;
  final shadows = overSky
      ? const [Shadow(color: Color(0xAA04101A), blurRadius: 8)]
      : null;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'As-salāmu alaykum',
              style: context.type.labelMedium?.copyWith(
                color: overSky ? const Color(0xFFE7E0D2) : colors.inkMuted,
                shadows: shadows,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: context.text.serifTitle.copyWith(color: fg, shadows: shadows),
            ),
          ],
        ),
      ),
      if (kDebugMode)
        _SkyIconButton(
          icon: Icons.science_outlined,
          overSky: overSky,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const DevPanel())),
        ),
      const SizedBox(width: Space.xs),
      _SkyIconButton(
        icon: AppIcons.settings,
        overSky: overSky,
        onTap: () => _openSettings(context),
      ),
    ],
  );
}

class _ActiveToday extends ConsumerWidget {
  const _ActiveToday({required this.commitment});
  final Commitment commitment;

  void _onTapPrayer(BuildContext context, WidgetRef ref, DayLog dayLog,
      DateTime today, Prayer prayer) {
    final entry = dayLog.entry(prayer);
    if (entry.locked || entry.effective != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PrayerDetailScreen(prayer: prayer, date: today),
      ));
      return;
    }
    // Fast path — a pending prayer, kept. Haptic on the same frame the bloom
    // begins; the node blooms via its state change.
    Haptics.log();
    ref.read(actionsProvider).logPrayer(today, prayer, PrayerStatus.prayed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final today = ref.watch(todayProvider);
    final dayLog = ref.watch(todayDayLogProvider);
    final wallet = ref.watch(walletProvider).value;
    final reduceMotion = effectiveReduceMotion(ref, context);
    final now = ref.watch(clockProvider).now();
    final size = MediaQuery.sizeOf(context);
    final arcH = (size.height * 0.5).clamp(330.0, 470.0);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(
        children: [
          SizedBox(
            height: arcH,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DayArc(
                    dayLog: dayLog,
                    time: now,
                    reduceMotion: reduceMotion,
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(30)),
                    onTapPrayer: (p) =>
                        _onTapPrayer(context, ref, dayLog, today, p),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Space.screenGutter, Space.xs, Space.md, 0),
                      child: _topBar(context, ref, overSky: true),
                    ),
                  ),
                ),
                Positioned(
                  left: Space.screenGutter,
                  right: Space.screenGutter,
                  bottom: 16,
                  child: Row(
                    children: [
                      Text(
                        'Day ${commitment.dayNumber(today)} of ${commitment.totalDays}',
                        style: context.type.labelMedium?.copyWith(
                          color: const Color(0xFFF4EFE6),
                          shadows: const [
                            Shadow(color: Color(0xAA04101A), blurRadius: 8)
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (wallet != null)
                        BalanceChip(
                          balancePaise: wallet.balancePaise,
                          overSky: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const WalletScreen()),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  Space.screenGutter, Space.lg, Space.screenGutter, Space.xl),
              child: _belowArc(context, ref, dayLog, wallet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _belowArc(
      BuildContext context, WidgetRef ref, DayLog dayLog, Wallet? wallet) {
    final colors = context.colors;
    final kept = dayLog.keptCount;
    final reflection = kept == 5
        ? 'A full day of light. Alhamdulillah.'
        : 'May the rest of your day be light.';
    return Column(
      children: [
        Center(
          child: Text(
            reflection,
            textAlign: TextAlign.center,
            style: context.text.serifTitle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: Space.xs),
        Center(
          child: Text(
            '$kept of 5 kept today',
            style: context.type.bodyMedium,
          ),
        ),
        const SizedBox(height: Space.lg),
        if (wallet != null && wallet.isEmpty)
          _DepletedCard(onAdd: () => showTopUpSheet(context))
        else if (dayLog.loggedCount == 0)
          SurfaceCard(
            color: colors.surfaceMuted,
            child: Row(
              children: [
                Icon(AppIcons.today, size: 18, color: colors.primary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    'Tap each prayer along the arc as you keep it.',
                    style: context.type.bodyMedium?.copyWith(color: colors.ink),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DepletedCard extends StatelessWidget {
  const _DepletedCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SurfaceCard(
      color: colors.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.moon, size: 16, color: colors.dawn),
              const SizedBox(width: Space.xs),
              Text('Your wallet has rested at zero',
                  style: context.type.labelLarge?.copyWith(color: colors.ink)),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Setting-aside has paused — nothing more will move. Add funds when '
            'you’re ready. Your prayers are what matter.',
            style: context.type.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: Space.md),
          AppButton(label: 'Add funds', icon: AppIcons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _EmptyToday extends ConsumerWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screenGutter),
          child: Column(
            children: [
              const SizedBox(height: Space.xs),
              _topBar(context, ref, overSky: false),
              const Spacer(flex: 2),
              Text('A new beginning,\nin sha Allah.',
                  textAlign: TextAlign.center, style: context.text.serifDisplay),
              const SizedBox(height: Space.md),
              Text(
                'Set a quiet commitment to your salah — a number of days, and a '
                'small amount set aside for each prayer.',
                textAlign: TextAlign.center,
                style: context.type.bodyLarge?.copyWith(color: colors.inkMuted, height: 1.5),
              ),
              const Spacer(flex: 3),
              AppButton(
                label: 'Set your commitment',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CommitmentSetupScreen())),
              ),
              const SizedBox(height: Space.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingEndToday extends ConsumerWidget {
  const _PendingEndToday({required this.commitment});
  final Commitment commitment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screenGutter),
          child: Column(
            children: [
              const SizedBox(height: Space.xs),
              _topBar(context, ref, overSky: false),
              const Spacer(flex: 2),
              Icon(AppIcons.moon, size: 40, color: colors.dawn),
              const SizedBox(height: Space.lg),
              Text('Your ${commitment.totalDays} days\nare complete.',
                  textAlign: TextAlign.center, style: context.text.serifDisplay),
              const SizedBox(height: Space.md),
              Text(
                'May Allah accept every prayer you kept. Take a moment to review.',
                textAlign: TextAlign.center,
                style: context.type.bodyLarge?.copyWith(color: colors.inkMuted, height: 1.5),
              ),
              const Spacer(flex: 3),
              AppButton(
                label: 'Review',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CommitmentEndScreen(commitment: commitment))),
              ),
              const SizedBox(height: Space.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkyIconButton extends StatelessWidget {
  const _SkyIconButton({
    required this.icon,
    required this.onTap,
    required this.overSky,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool overSky;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = overSky ? const Color(0xFFF4EFE6) : colors.ink;
    final bg = overSky
        ? const Color(0xFF071018).withValues(alpha: 0.22)
        : colors.surface;
    final border = overSky
        ? const Color(0xFFF4EFE6).withValues(alpha: 0.16)
        : colors.hairline;
    return Material(
      color: bg,
      shape: CircleBorder(side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Haptics.select();
          onTap();
        },
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 19, color: fg)),
      ),
    );
  }
}

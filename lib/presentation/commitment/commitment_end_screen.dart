import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_toast.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

/// A calm close to a commitment. We celebrate the salah kept — never the money.
/// Then: roll the remaining balance into the next commitment (default) or
/// refund it to source.
class CommitmentEndScreen extends ConsumerStatefulWidget {
  const CommitmentEndScreen({super.key, required this.commitment});
  final Commitment commitment;

  @override
  ConsumerState<CommitmentEndScreen> createState() =>
      _CommitmentEndScreenState();
}

class _CommitmentEndScreenState extends ConsumerState<CommitmentEndScreen> {
  bool _busy = false;

  ({int kept, int missed, int total}) _tally(List<PrayerLog> logs) {
    final c = widget.commitment;
    var kept = 0;
    var missed = 0;
    final total = c.totalDays * Prayer.ordered.length;
    for (var i = 0; i < c.totalDays; i++) {
      final date = c.startDate.add(Duration(days: i));
      for (final p in Prayer.ordered) {
        final log = logs
            .where((l) => Day.isSame(l.prayerDate, date) && l.prayer == p)
            .firstOrNull;
        // Past commitment → every day has settled (locked).
        final status = log?.status ?? PrayerStatus.missed;
        if (status.isKept) {
          kept++;
        } else {
          missed++;
        }
      }
    }
    return (kept: kept, missed: missed, total: total);
  }

  Future<void> _finish({required bool rollover}) async {
    if (_busy) return;
    setState(() => _busy = true);
    Haptics.completion();
    await ref
        .read(actionsProvider)
        .completeCommitment(widget.commitment.id, rollover: rollover);
    if (!mounted) return;
    showAppToast(
      context,
      rollover ? 'Rolled into your next commitment.' : 'Refund on its way to source.',
      icon: rollover ? AppIcons.today : AppIcons.wallet,
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final logs = ref.watch(allLogsProvider).value ?? const <PrayerLog>[];
    final wallet = ref.watch(walletProvider).value;
    final tally = _tally(logs);
    final remaining = wallet?.balancePaise ?? 0;

    return ScreenScaffold(
      title: 'A commitment kept',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.md),
          Center(
            child: Column(
              children: [
                Icon(AppIcons.moon, size: 36, color: colors.dawn),
                const SizedBox(height: Space.md),
                Text(
                  '${tally.kept}',
                  style: context.text.serifDisplay.copyWith(fontSize: 56, color: colors.primary),
                ),
                Text('prayers kept over ${widget.commitment.totalDays} days',
                    style: context.type.titleMedium),
                const SizedBox(height: Space.xs),
                Text('May Allah accept them.', style: context.type.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          SurfaceCard(
            color: colors.surfaceMuted,
            child: Column(
              children: [
                _StatRow(label: 'Days completed', value: '${widget.commitment.totalDays}'),
                const SizedBox(height: Space.sm),
                _StatRow(label: 'Prayers kept', value: '${tally.kept} of ${tally.total}'),
                const SizedBox(height: Space.sm),
                _StatRow(
                  label: 'Set aside for sadaqah',
                  value: Money.format(_setAside(logs)),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          Text('What would you like to do with the ${Money.format(remaining)} remaining?',
              style: context.type.titleMedium),
          const SizedBox(height: Space.md),
          AppButton(
            label: 'Roll into my next commitment',
            loading: _busy,
            onPressed: () => _finish(rollover: true),
          ),
          const SizedBox(height: Space.sm),
          AppButton(
            label: 'Refund to source',
            tone: AppButtonTone.neutral,
            onPressed: _busy ? null : () => _finish(rollover: false),
          ),
          const SizedBox(height: Space.md),
          Text(
            'Either way, nothing of yours is kept by Sukoon. Only genuinely '
            'missed prayers ever contributed to sadaqah.',
            style: context.type.bodySmall,
          ),
        ],
      ),
    );
  }

  int _setAside(List<PrayerLog> logs) {
    final settlements = ref.read(settlementsProvider).value ?? const <Settlement>[];
    return settlements
        .where((s) => s.commitmentId == widget.commitment.id)
        .fold(0, (sum, s) => sum + s.deductedPaise);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.type.bodyMedium?.copyWith(color: colors.inkMuted)),
        Text(value, style: context.text.money.copyWith(color: colors.ink)),
      ],
    );
  }
}

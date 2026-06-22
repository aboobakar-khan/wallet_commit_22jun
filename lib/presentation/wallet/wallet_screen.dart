import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../payments/top_up_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_toast.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final wallet = ref.watch(walletProvider).value;
    final active = ref.watch(activeCommitmentProvider).value;
    final ledger = ref.watch(ledgerProvider).value ?? const <LedgerEntry>[];
    final entries = [...ledger]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Future<void> refund() async {
      final amount = await ref.read(actionsProvider).refund();
      if (context.mounted) {
        showAppToast(context, 'Refund of ${Money.format(amount)} on its way.',
            icon: AppIcons.wallet);
      }
    }

    return ScreenScaffold(
      title: 'Wallet',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.sm),
          Text('Balance',
              style: context.type.labelMedium?.copyWith(color: colors.inkMuted)),
          const SizedBox(height: Space.xxs),
          Text(Money.format(wallet?.balancePaise ?? 0),
              style: context.text.moneyLarge.copyWith(color: colors.ink)),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Icon(AppIcons.shield, size: 14, color: colors.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  active != null
                      ? 'Withdrawal is paused while a commitment is active — your balance stays yours, refundable to source.'
                      : 'Refundable to source anytime. Money is an amanah.',
                  style: context.type.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add funds',
                  icon: AppIcons.add,
                  onPressed: () => showTopUpSheet(context),
                ),
              ),
              if (active == null && (wallet?.balancePaise ?? 0) > 0) ...[
                const SizedBox(width: Space.sm),
                Expanded(
                  child: AppButton(
                    label: 'Refund',
                    tone: AppButtonTone.neutral,
                    onPressed: refund,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Space.xl),
          const SectionLabel('Activity'),
          if (entries.isEmpty)
            _EmptyActivity()
          else
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    _LedgerTile(entry: entries[i]),
                    if (i != entries.length - 1) const Hairline(indent: 56),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SurfaceCard(
      color: colors.surfaceMuted,
      child: Row(
        children: [
          Icon(AppIcons.wallet, size: 18, color: colors.inkMuted),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              'Nothing here yet. When you load funds or a prayer is set aside, it '
              'will appear as a quiet, honest timeline.',
              style: context.type.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.entry});
  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, icon, accent) = switch (entry.type) {
      LedgerType.load => ('Loaded', AppIcons.add, colors.primary),
      LedgerType.refund => ('Refunded to source', AppIcons.refresh, colors.primary),
      LedgerType.deduct => ('Set aside for sadaqah', AppIcons.giving, colors.sadaqah),
      LedgerType.rollover => ('Rolled into next commitment', AppIcons.today, colors.inkMuted),
      LedgerType.withdraw => ('Withdrawn', AppIcons.wallet, colors.inkMuted),
    };
    final sign = entry.type.isCredit
        ? '+'
        : (entry.type == LedgerType.deduct || entry.type == LedgerType.withdraw)
            ? '−'
            : '';
    final dateStr = DateFormat('d MMM').format(entry.createdAt);
    final subtitle = entry.type == LedgerType.deduct && entry.prayerDate != null
        ? 'A missed prayer · ${DateFormat('d MMM').format(entry.prayerDate!)}'
        : dateStr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.type.labelLarge?.copyWith(color: colors.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: context.type.bodySmall),
              ],
            ),
          ),
          Text(
            '$sign${Money.format(entry.amountPaise)}',
            style: context.text.money.copyWith(
              color: entry.type == LedgerType.deduct ? colors.sadaqah : colors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

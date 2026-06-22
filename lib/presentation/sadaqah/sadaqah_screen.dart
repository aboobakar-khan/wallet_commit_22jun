import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_toast.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

class SadaqahScreen extends ConsumerWidget {
  const SadaqahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final contributed = ref.watch(contributedPaiseProvider);
    final settlements = ref.watch(settlementsProvider).value ?? const <Settlement>[];
    final missed = settlements.fold(0, (s, e) => s + e.missedCount);
    final disbursements =
        ref.watch(charityProvider).value ?? const <CharityDisbursement>[];

    return ScreenScaffold(
      title: 'Giving',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.sm),
          SurfaceCard(
            color: colors.surfaceMuted,
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your contribution so far',
                    style: context.type.labelMedium?.copyWith(color: colors.inkMuted)),
                const SizedBox(height: Space.xs),
                Text(Money.format(contributed),
                    style: context.text.moneyLarge.copyWith(color: colors.sadaqah)),
                const SizedBox(height: Space.xs),
                Text(
                  missed == 0
                      ? 'No prayers have been missed. May it stay so, in sha Allah.'
                      : 'From $missed genuinely missed ${missed == 1 ? 'prayer' : 'prayers'}, set aside for people in need, in sha Allah.',
                  style: context.type.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          // The non-negotiable framing, stated plainly.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.info, size: 16, color: colors.inkMuted),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  'This is sadaqah, not expiation. It does not clear or settle a '
                  'missed prayer — qada and tawbah still stand. The money is only a '
                  'gentle nudge.',
                  style: context.type.bodySmall?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          const SectionLabel('Where it goes'),
          Text(
            'The pooled sadaqah from everyone, disbursed with full transparency.',
            style: context.type.bodyMedium,
          ),
          const SizedBox(height: Space.md),
          for (final d in disbursements) ...[
            _DisbursementCard(disbursement: d),
            const SizedBox(height: Space.sm),
          ],
        ],
      ),
    );
  }
}

class _DisbursementCard extends StatelessWidget {
  const _DisbursementCard({required this.disbursement});
  final CharityDisbursement disbursement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = disbursement;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.sadaqah.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.giving, size: 19, color: colors.sadaqah),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.recipientNote,
                        style: context.type.labelLarge?.copyWith(color: colors.ink, height: 1.3)),
                    const SizedBox(height: 2),
                    Text(DateFormat('d MMM yyyy').format(d.disbursedAt),
                        style: context.type.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Text(Money.format(d.amountPaise),
                  style: context.text.money.copyWith(color: colors.ink)),
            ],
          ),
          if (d.proofUrl != null) ...[
            const SizedBox(height: Space.sm),
            const Hairline(),
            const SizedBox(height: Space.xs),
            InkWell(
              borderRadius: Radii.small_,
              onTap: () {
                Haptics.select();
                showAppToast(context, 'Proof opens in your browser (demo).',
                    icon: AppIcons.proof);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(AppIcons.proof, size: 16, color: colors.primary),
                    const SizedBox(width: Space.xs),
                    Text('View proof of disbursement',
                        style: context.type.labelMedium?.copyWith(color: colors.primary)),
                    const Spacer(),
                    Icon(AppIcons.chevron, size: 18, color: colors.inkMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

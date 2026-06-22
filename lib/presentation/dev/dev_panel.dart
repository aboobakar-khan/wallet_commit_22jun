import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../../data/mock/dev_scenario.dart';
import '../commitment/commitment_end_screen.dart';
import '../history/history_screen.dart';
import '../payments/top_up_sheet.dart';
import '../widgets/app_icons.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';

/// Hidden dev panel (debug only) — jump between seeded scenarios and into the
/// states that aren't a "scenario" (a locked past day, the top-up sheet, the
/// end-of-commitment summary), so every state in §9 is reachable and demoable.
class DevPanel extends ConsumerWidget {
  const DevPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final current = ref.watch(scenarioProvider);
    final today = ref.watch(todayProvider);
    final commitments = ref.watch(commitmentsProvider).value ?? const [];

    return ScreenScaffold(
      title: 'Developer',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.xs),
          Text('Seeded scenarios — switching reseeds the mock backend.',
              style: context.type.bodyMedium),
          const SizedBox(height: Space.md),
          for (final s in DevScenario.values) ...[
            _ScenarioRow(
              scenario: s,
              selected: s == current,
              onTap: () {
                ref.read(scenarioProvider.notifier).state = s;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
            const SizedBox(height: Space.xs),
          ],
          const SizedBox(height: Space.lg),
          const SectionLabel('Jump to a state'),
          _JumpRow(
            icon: AppIcons.lock,
            label: 'A locked past day',
            sub: 'Yesterday — settled, read-only',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  DayReviewScreen(date: today.subtract(const Duration(days: 1))),
            )),
          ),
          _JumpRow(
            icon: AppIcons.wallet,
            label: 'The top-up sheet',
            sub: 'Simulated payment flow',
            onTap: () => showTopUpSheet(context),
          ),
          if (commitments.isNotEmpty)
            _JumpRow(
              icon: AppIcons.moon,
              label: 'Commitment-end summary',
              sub: 'Roll over or refund',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    CommitmentEndScreen(commitment: commitments.last),
              )),
            ),
          const SizedBox(height: Space.lg),
          Container(
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: Radii.card_,
              border: Border.all(color: colors.hairline),
            ),
            child: Text(
              'Debug-only. None of this ships — it exists so every empty, '
              'depleted, locked and pending state is one tap away.',
              style: context.type.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.scenario,
    required this.selected,
    required this.onTap,
  });
  final DevScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SurfaceCard(
      onTap: onTap,
      color: selected ? colors.primary.withValues(alpha: 0.08) : null,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            size: 20,
            color: selected ? colors.primary : colors.inkMuted,
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.label,
                    style: context.type.labelLarge?.copyWith(color: colors.ink)),
                const SizedBox(height: 2),
                Text(scenario.blurb, style: context.type.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JumpRow extends StatelessWidget {
  const _JumpRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: SurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: context.type.labelLarge?.copyWith(color: colors.ink)),
                  const SizedBox(height: 2),
                  Text(sub, style: context.type.bodySmall),
                ],
              ),
            ),
            Icon(AppIcons.chevron, size: 18, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}

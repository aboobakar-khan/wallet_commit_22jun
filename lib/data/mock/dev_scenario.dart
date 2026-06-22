/// Debug-only scenarios the dev panel can jump between, so every state is
/// reachable and demoable (THESIS §3, §9). These are *data* states; a few
/// destination states (locked past day, the simulated top-up sheet) are reached
/// by navigation from within the Active scenario.
enum DevScenario {
  freshUser(
    'Fresh user',
    'Signed out, no commitment — the onboarding journey.',
  ),
  active(
    'Active · mid-commitment',
    'Day 12 of 30. A few honest misses, a live ledger and sadaqah record.',
  ),
  depletedWallet(
    'Depleted wallet',
    'Active commitment, balance rested at zero — the calm top-up prompt.',
  ),
  completedPendingRefund(
    'Completed · pending refund',
    'A finished commitment awaiting roll-over or refund to source.',
  );

  const DevScenario(this.label, this.blurb);
  final String label;
  final String blurb;
}

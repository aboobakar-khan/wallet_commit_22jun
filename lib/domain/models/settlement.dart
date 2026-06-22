class Settlement {
  final String commitmentId;

  /// Date-only.
  final DateTime prayerDate;
  final int missedCount;
  final int deductedPaise;

  const Settlement({
    required this.commitmentId,
    required this.prayerDate,
    required this.missedCount,
    required this.deductedPaise,
  });
}

import '../enums/prayer_status.dart';

/// Lenient settlement (THESIS §3): only genuinely missed prayers count.
/// `late` is kept (never charged); a never-logged prayer becomes `missed` only
/// once the day has locked.
abstract final class SettlementRules {
  /// The effective status used for settlement, given the (nullable) log and
  /// whether the day has locked. Returns null while still pending.
  static PrayerStatus? effective(PrayerStatus? logged, bool locked) {
    if (logged != null) return logged;
    return locked ? PrayerStatus.missed : null;
  }

  static int missedCount(Iterable<PrayerStatus?> effectiveStatuses) =>
      effectiveStatuses.where((s) => s == PrayerStatus.missed).length;

  /// Deduction for a day. Capped to available balance by the wallet layer —
  /// deductions stop at zero (THESIS §3, depleted wallet).
  static int deductionPaise({required int missedCount, required int stakePaise}) =>
      missedCount * stakePaise;
}

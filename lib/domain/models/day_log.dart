import '../enums/prayer.dart';
import '../enums/prayer_status.dart';
import '../rules/settlement_rules.dart';

/// One prayer's state within a day's view.
class DayPrayerEntry {
  final Prayer prayer;

  /// The logged status, or null if never logged.
  final PrayerStatus? logged;

  /// Whether the parent day has locked (drives "missed at lock" + read-only UI).
  final bool locked;

  const DayPrayerEntry({
    required this.prayer,
    required this.logged,
    required this.locked,
  });

  /// Status used for settlement & display: the log if present, else `missed`
  /// once locked, else null (still pending).
  PrayerStatus? get effective => SettlementRules.effective(logged, locked);

  bool get isPending => effective == null;
  bool get isKept => effective?.isKept ?? false;
  bool get isMissed => effective == PrayerStatus.missed;
}

/// A computed view of one calendar day across the five prayers. Built by the
/// presentation layer from raw [PrayerLog]s; carries no storage of its own.
class DayLog {
  /// Date-only (local midnight).
  final DateTime date;
  final bool locked;

  /// Always five entries, in canonical prayer order.
  final List<DayPrayerEntry> entries;

  const DayLog({required this.date, required this.locked, required this.entries});

  factory DayLog.from({
    required DateTime date,
    required bool locked,
    required Map<Prayer, PrayerStatus> logged,
  }) {
    return DayLog(
      date: date,
      locked: locked,
      entries: [
        for (final p in Prayer.ordered)
          DayPrayerEntry(prayer: p, logged: logged[p], locked: locked),
      ],
    );
  }

  DayPrayerEntry entry(Prayer p) => entries[p.index];

  int get keptCount => entries.where((e) => e.isKept).length;
  int get missedCount => entries.where((e) => e.isMissed).length;
  int get pendingCount => entries.where((e) => e.isPending).length;
  int get loggedCount => entries.where((e) => e.logged != null).length;

  /// 0..1 fraction of the day "kept" so far — drives how much light the arc holds.
  double get keptFraction => keptCount / entries.length;
}

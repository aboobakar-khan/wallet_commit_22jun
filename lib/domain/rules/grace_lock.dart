import '../../core/utils/day.dart';

/// Grace rule (THESIS §3): a day stays editable until **02:00 the next day,
/// user's local time**, then locks. After lock the repository rejects writes and
/// the UI disables editing and explains why — calmly, never as a penalty.
abstract final class GraceLock {
  static const int lockHour = 2;

  /// The moment [day] locks: 02:00 on the following calendar day, local time.
  static DateTime lockTimeFor(DateTime day) {
    final d = Day.only(day);
    return DateTime(d.year, d.month, d.day + 1, lockHour);
  }

  static bool isLocked(DateTime day, DateTime now) =>
      !now.isBefore(lockTimeFor(day));

  /// Remaining grace before [day] locks (zero if already locked).
  static Duration timeUntilLock(DateTime day, DateTime now) {
    final lock = lockTimeFor(day);
    return now.isBefore(lock) ? lock.difference(now) : Duration.zero;
  }
}

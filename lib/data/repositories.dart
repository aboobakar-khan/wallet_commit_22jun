import '../domain/domain.dart';

/// Repository interfaces — the only seams the real backend (Supabase + Razorpay)
/// drops into later. No widget or domain rule imports a concrete implementation;
/// everything is wired through these via the provider layer, so swapping
/// mock → real is one binding change per interface.

/// Thrown when a write is attempted against a day that has already locked.
class DayLockedException implements Exception {
  final DateTime day;
  const DayLockedException(this.day);
  @override
  String toString() => 'DayLockedException($day)';
}

abstract interface class AuthRepository {
  Stream<bool> watchSignedIn();
  bool get isSignedIn;
  Future<void> signInMock({required String name});
  Future<void> signOut();
}

abstract interface class ProfileRepository {
  Stream<Profile?> watch();
  Profile? get current;
  Future<void> update({String? displayName, String? timezone});
}

abstract interface class WalletRepository {
  Stream<Wallet> watch();
  Wallet get current;
}

abstract interface class CommitmentRepository {
  Stream<Commitment?> watchActive();

  /// All commitments (newest first stays a UI concern), reactive.
  Stream<List<Commitment>> watchAll();
  Commitment? get active;
  Future<Commitment> create({
    required DateTime startDate,
    required DateTime endDate,
    required int stakePerPrayerPaise,
  });
  Future<List<Commitment>> history();

  /// End an active commitment: roll the remaining balance into the next
  /// commitment (default) or refund it to source.
  Future<void> complete(String id, {required bool rollover});
  Future<void> cancel(String id);
}

abstract interface class PrayerLogRepository {
  /// Reactive stream of every log — UI derives day/range views from this.
  Stream<List<PrayerLog>> watchAll();
  Future<List<PrayerLog>> dayLogs(DateTime date);
  Future<List<PrayerLog>> rangeLogs(DateTime start, DateTime end);

  /// Records (or updates) a prayer. Throws [DayLockedException] if the day has
  /// locked — the lock rule lives behind the repository, not in widgets.
  Future<void> logPrayer({
    required DateTime date,
    required Prayer prayer,
    required PrayerStatus status,
  });

  /// Clears a prayer back to "not logged". Also lock-guarded.
  Future<void> clearPrayer({required DateTime date, required Prayer prayer});
}

abstract interface class LedgerRepository {
  Stream<List<LedgerEntry>> watch();
  List<LedgerEntry> get current;
}

abstract interface class SettlementRepository {
  Stream<List<Settlement>> watch();
  Future<List<Settlement>> all();
}

abstract interface class CharityRepository {
  Stream<List<CharityDisbursement>> watch();
  Future<List<CharityDisbursement>> all();

  /// Total sadaqah attributable to this user's missed prayers, in paise.
  Future<int> contributedPaise();
}

/// Simulated now (a styled fake sheet that just credits/debits the mock wallet);
/// real Razorpay drops in behind this same interface later.
abstract interface class PaymentService {
  /// Credits the mock wallet by [amountPaise]. Returns false if "cancelled".
  Future<bool> startTopUp(int amountPaise);

  /// Refunds the remaining balance to source. Blocked while a commitment is
  /// active (enforced above this layer). Returns the refunded amount in paise.
  Future<int> requestRefund();
}

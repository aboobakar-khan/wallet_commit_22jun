import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/utils/clock.dart';
import '../core/utils/day.dart';
import '../data/mock/dev_scenario.dart';
import '../data/mock/mock_backend.dart';
import '../data/mock/mock_repositories.dart';
import '../data/repositories.dart';
import '../domain/domain.dart';

// ===========================================================================
// Infrastructure
// ===========================================================================

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Debug-only: which seeded scenario is active. Changing it rebuilds the whole
/// mock backend (and therefore every stream), so every state is reachable.
final scenarioProvider = StateProvider<DevScenario>((ref) => DevScenario.active);

/// THE swap point. Today this builds the in-memory mock; the real Supabase +
/// Razorpay arrive by changing only the bindings in this file.
final mockBackendProvider = Provider<MockBackend>((ref) {
  final backend = MockBackend(
    clock: ref.watch(clockProvider),
    scenario: ref.watch(scenarioProvider),
  );
  ref.onDispose(backend.dispose);
  return backend;
});

// ---- repository bindings (interface -> implementation) --------------------

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => MockAuthRepository(ref.watch(mockBackendProvider)));
final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => MockProfileRepository(ref.watch(mockBackendProvider)));
final walletRepositoryProvider = Provider<WalletRepository>(
    (ref) => MockWalletRepository(ref.watch(mockBackendProvider)));
final commitmentRepositoryProvider = Provider<CommitmentRepository>(
    (ref) => MockCommitmentRepository(ref.watch(mockBackendProvider)));
final prayerLogRepositoryProvider = Provider<PrayerLogRepository>(
    (ref) => MockPrayerLogRepository(ref.watch(mockBackendProvider)));
final ledgerRepositoryProvider = Provider<LedgerRepository>(
    (ref) => MockLedgerRepository(ref.watch(mockBackendProvider)));
final settlementRepositoryProvider = Provider<SettlementRepository>(
    (ref) => MockSettlementRepository(ref.watch(mockBackendProvider)));
final charityRepositoryProvider = Provider<CharityRepository>(
    (ref) => MockCharityRepository(ref.watch(mockBackendProvider)));
final paymentServiceProvider =
    Provider<PaymentService>((ref) => MockPaymentService(ref.watch(mockBackendProvider)));

// ===========================================================================
// Reactive reads
// ===========================================================================

final signedInProvider = StreamProvider<bool>(
    (ref) => ref.watch(authRepositoryProvider).watchSignedIn());
final profileProvider = StreamProvider<Profile?>(
    (ref) => ref.watch(profileRepositoryProvider).watch());
final walletProvider =
    StreamProvider<Wallet>((ref) => ref.watch(walletRepositoryProvider).watch());
final activeCommitmentProvider = StreamProvider<Commitment?>(
    (ref) => ref.watch(commitmentRepositoryProvider).watchActive());
final commitmentsProvider = StreamProvider<List<Commitment>>(
    (ref) => ref.watch(commitmentRepositoryProvider).watchAll());
final allLogsProvider = StreamProvider<List<PrayerLog>>(
    (ref) => ref.watch(prayerLogRepositoryProvider).watchAll());
final ledgerProvider = StreamProvider<List<LedgerEntry>>(
    (ref) => ref.watch(ledgerRepositoryProvider).watch());
final settlementsProvider = StreamProvider<List<Settlement>>(
    (ref) => ref.watch(settlementRepositoryProvider).watch());
final charityProvider = StreamProvider<List<CharityDisbursement>>(
    (ref) => ref.watch(charityRepositoryProvider).watch());

/// Today (date-only, local). Stable for the session.
final todayProvider = Provider<DateTime>((ref) => Day.only(ref.watch(clockProvider).now()));

/// The computed [DayLog] for any date — combines the log stream with the lock
/// rule. Callers pass a date-only value.
final dayLogProvider = Provider.family<DayLog, DateTime>((ref, date) {
  final d = Day.only(date);
  final logs = ref.watch(allLogsProvider).value ?? const <PrayerLog>[];
  final now = ref.watch(clockProvider).now();
  final locked = GraceLock.isLocked(d, now);
  final logged = <Prayer, PrayerStatus>{
    for (final l in logs)
      if (Day.isSame(l.prayerDate, d)) l.prayer: l.status,
  };
  return DayLog.from(date: d, locked: locked, logged: logged);
});

/// Today's arc state.
final todayDayLogProvider = Provider<DayLog>(
    (ref) => ref.watch(dayLogProvider(ref.watch(todayProvider))));

/// Total sadaqah this user's misses have contributed (paise).
final contributedPaiseProvider = Provider<int>((ref) {
  final s = ref.watch(settlementsProvider).value ?? const <Settlement>[];
  return s.fold(0, (sum, e) => sum + e.deductedPaise);
});

/// A completed commitment awaiting the user's roll-over / refund decision, if
/// any. "Unresolved" = no rollover/refund ledger entry references it yet.
final pendingEndCommitmentProvider = Provider<Commitment?>((ref) {
  final commitments = ref.watch(commitmentsProvider).value ?? const <Commitment>[];
  final ledger = ref.watch(ledgerProvider).value ?? const <LedgerEntry>[];
  bool resolved(String id) => ledger.any((l) =>
      (l.type == LedgerType.rollover || l.type == LedgerType.refund) &&
      l.commitmentId == id);
  for (final c in commitments.reversed) {
    if (c.status == CommitmentStatus.completed && !resolved(c.id)) return c;
  }
  return null;
});

// ===========================================================================
// Preferences
// ===========================================================================

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// null = follow the platform; true/false = explicit override (settings + dev).
final reduceMotionOverrideProvider = StateProvider<bool?>((ref) => null);

/// null = follow device locale; used by the language switch (en / ar for RTL).
final localeProvider = StateProvider<Locale?>((ref) => null);

// ===========================================================================
// Actions facade — keeps business calls out of widgets
// ===========================================================================

class SalahActions {
  SalahActions(this._ref);
  final Ref _ref;

  Future<void> signIn(String name) =>
      _ref.read(authRepositoryProvider).signInMock(name: name);
  Future<void> signOut() => _ref.read(authRepositoryProvider).signOut();

  Future<void> updateProfile({String? displayName, String? timezone}) => _ref
      .read(profileRepositoryProvider)
      .update(displayName: displayName, timezone: timezone);

  Future<void> logPrayer(DateTime date, Prayer prayer, PrayerStatus status) =>
      _ref.read(prayerLogRepositoryProvider).logPrayer(
          date: date, prayer: prayer, status: status);

  Future<void> clearPrayer(DateTime date, Prayer prayer) =>
      _ref.read(prayerLogRepositoryProvider).clearPrayer(date: date, prayer: prayer);

  Future<bool> topUp(int amountPaise) =>
      _ref.read(paymentServiceProvider).startTopUp(amountPaise);

  Future<int> refund() => _ref.read(paymentServiceProvider).requestRefund();

  Future<Commitment> createCommitment({
    required DateTime startDate,
    required DateTime endDate,
    required int stakePerPrayerPaise,
  }) =>
      _ref.read(commitmentRepositoryProvider).create(
            startDate: startDate,
            endDate: endDate,
            stakePerPrayerPaise: stakePerPrayerPaise,
          );

  Future<void> completeCommitment(String id, {required bool rollover}) =>
      _ref.read(commitmentRepositoryProvider).complete(id, rollover: rollover);
}

final actionsProvider = Provider<SalahActions>((ref) => SalahActions(ref));

/// Effective reduced-motion: explicit override, else the platform preference.
bool effectiveReduceMotion(WidgetRef ref, BuildContext context) {
  final override = ref.watch(reduceMotionOverrideProvider);
  if (override != null) return override;
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

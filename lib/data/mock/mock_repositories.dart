import '../../domain/domain.dart';
import '../repositories.dart';
import 'mock_backend.dart';

/// In-memory implementations of every repository interface, all delegating to a
/// single [MockBackend]. When the real backend arrives, only the provider
/// bindings change — these classes are deleted, nothing else.

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._b);
  final MockBackend _b;
  @override
  Stream<bool> watchSignedIn() => _b.signedIn$;
  @override
  bool get isSignedIn => _b.signedIn;
  @override
  Future<void> signInMock({required String name}) => _b.signInMock(name: name);
  @override
  Future<void> signOut() => _b.signOut();
}

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(this._b);
  final MockBackend _b;
  @override
  Stream<Profile?> watch() => _b.profile$;
  @override
  Profile? get current => _b.profile;
  @override
  Future<void> update({String? displayName, String? timezone}) =>
      _b.updateProfile(displayName: displayName, timezone: timezone);
}

class MockWalletRepository implements WalletRepository {
  MockWalletRepository(this._b);
  final MockBackend _b;
  @override
  Stream<Wallet> watch() => _b.wallet$;
  @override
  Wallet get current => _b.wallet;
}

class MockCommitmentRepository implements CommitmentRepository {
  MockCommitmentRepository(this._b);
  final MockBackend _b;
  @override
  Stream<Commitment?> watchActive() => _b.activeCommitment$;
  @override
  Stream<List<Commitment>> watchAll() => _b.commitments$;
  @override
  Commitment? get active => _b.activeCommitment;
  @override
  Future<Commitment> create({
    required DateTime startDate,
    required DateTime endDate,
    required int stakePerPrayerPaise,
  }) =>
      _b.createCommitment(
        startDate: startDate,
        endDate: endDate,
        stakePerPrayerPaise: stakePerPrayerPaise,
      );
  @override
  Future<List<Commitment>> history() async => _b.commitmentHistory();
  @override
  Future<void> complete(String id, {required bool rollover}) =>
      _b.completeCommitment(id, rollover: rollover);
  @override
  Future<void> cancel(String id) => _b.cancelCommitment(id);
}

class MockPrayerLogRepository implements PrayerLogRepository {
  MockPrayerLogRepository(this._b);
  final MockBackend _b;
  @override
  Stream<List<PrayerLog>> watchAll() => _b.logs$;
  @override
  Future<List<PrayerLog>> dayLogs(DateTime date) async => _b.dayLogs(date);
  @override
  Future<List<PrayerLog>> rangeLogs(DateTime start, DateTime end) async =>
      _b.rangeLogs(start, end);
  @override
  Future<void> logPrayer({
    required DateTime date,
    required Prayer prayer,
    required PrayerStatus status,
  }) =>
      _b.logPrayer(date: date, prayer: prayer, status: status);
  @override
  Future<void> clearPrayer({required DateTime date, required Prayer prayer}) =>
      _b.clearPrayer(date: date, prayer: prayer);
}

class MockLedgerRepository implements LedgerRepository {
  MockLedgerRepository(this._b);
  final MockBackend _b;
  @override
  Stream<List<LedgerEntry>> watch() => _b.ledger$;
  @override
  List<LedgerEntry> get current => _b.ledger;
}

class MockSettlementRepository implements SettlementRepository {
  MockSettlementRepository(this._b);
  final MockBackend _b;
  @override
  Stream<List<Settlement>> watch() => _b.settlements$;
  @override
  Future<List<Settlement>> all() async => _b.settlements;
}

class MockCharityRepository implements CharityRepository {
  MockCharityRepository(this._b);
  final MockBackend _b;
  @override
  Stream<List<CharityDisbursement>> watch() => _b.charity$;
  @override
  Future<List<CharityDisbursement>> all() async => _b.charity;
  @override
  Future<int> contributedPaise() async => _b.contributedPaise();
}

class MockPaymentService implements PaymentService {
  MockPaymentService(this._b);
  final MockBackend _b;
  @override
  Future<bool> startTopUp(int amountPaise) => _b.startTopUp(amountPaise);
  @override
  Future<int> requestRefund() => _b.requestRefund();
}

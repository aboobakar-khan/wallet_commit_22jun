import 'dart:async';

import '../../core/utils/clock.dart';
import '../../core/utils/day.dart';
import '../../domain/domain.dart';
import '../repositories.dart';
import 'dev_scenario.dart';

/// A tiny "behaviour subject": holds the latest value and replays it to each
/// new subscriber, then forwards updates. Keeps the mock reactive without rxdart.
class _Emitter<T> {
  _Emitter(this._value);
  T _value;
  final StreamController<T> _ctrl = StreamController<T>.broadcast();

  T get value => _value;
  set value(T v) {
    _value = v;
    if (!_ctrl.isClosed) _ctrl.add(v);
  }

  Stream<T> get stream => Stream<T>.multi((c) {
        c.add(_value);
        final sub = _ctrl.stream.listen(c.add,
            onError: c.addError, onDone: c.close);
        c.onCancel = sub.cancel;
      });

  Future<void> dispose() => _ctrl.close();
}

/// The single in-memory store behind every mock repository. One backend is
/// rebuilt whenever the dev scenario changes; the repositories are thin views
/// over it. All business rules that must be *visible* in the UI (the lock, the
/// lenient settlement, depletion at zero) are enforced here, isolated from
/// widgets and trivially removable when the server takes over.
class MockBackend {
  MockBackend({required this.clock, required DevScenario scenario}) {
    _seed(scenario);
  }

  final Clock clock;

  int _seq = 0;
  String _id(String prefix) => '${prefix}_${(_seq++).toString().padLeft(4, '0')}';

  // ---- state emitters ----
  final _signedIn = _Emitter<bool>(false);
  final _profile = _Emitter<Profile?>(null);
  final _wallet = _Emitter<Wallet>(const Wallet(balancePaise: 0));
  final _activeCommitment = _Emitter<Commitment?>(null);
  final _logs = _Emitter<List<PrayerLog>>(const []);
  final _ledger = _Emitter<List<LedgerEntry>>(const []);
  final _settlements = _Emitter<List<Settlement>>(const []);
  final _charity = _Emitter<List<CharityDisbursement>>(const []);

  // ---- mutable backing collections (always re-published as fresh lists) ----
  final List<Commitment> _commitments = [];
  final _commitmentsEmit = _Emitter<List<Commitment>>(const []);

  void _publishCommitments() =>
      _commitmentsEmit.value = List.unmodifiable(_commitments);

  // ---- reads ----
  Stream<bool> get signedIn$ => _signedIn.stream;
  bool get signedIn => _signedIn.value;
  Stream<Profile?> get profile$ => _profile.stream;
  Profile? get profile => _profile.value;
  Stream<Wallet> get wallet$ => _wallet.stream;
  Wallet get wallet => _wallet.value;
  Stream<Commitment?> get activeCommitment$ => _activeCommitment.stream;
  Commitment? get activeCommitment => _activeCommitment.value;
  Stream<List<PrayerLog>> get logs$ => _logs.stream;
  List<PrayerLog> get logs => _logs.value;
  Stream<List<LedgerEntry>> get ledger$ => _ledger.stream;
  List<LedgerEntry> get ledger => _ledger.value;
  Stream<List<Settlement>> get settlements$ => _settlements.stream;
  List<Settlement> get settlements => _settlements.value;
  Stream<List<CharityDisbursement>> get charity$ => _charity.stream;
  List<CharityDisbursement> get charity => _charity.value;
  Stream<List<Commitment>> get commitments$ => _commitmentsEmit.stream;

  List<Commitment> commitmentHistory() =>
      List.unmodifiable(_commitments.reversed);

  int contributedPaise() =>
      _settlements.value.fold(0, (s, e) => s + e.deductedPaise);

  // ---- auth ----
  Future<void> signInMock({required String name}) async {
    _signedIn.value = true;
    _profile.value = Profile(
      id: _id('user'),
      displayName: name.trim().isEmpty ? 'Friend' : name.trim(),
      timezone: 'Asia/Kolkata',
    );
  }

  Future<void> signOut() async {
    _signedIn.value = false;
  }

  Future<void> updateProfile({String? displayName, String? timezone}) async {
    final p = _profile.value;
    if (p == null) return;
    _profile.value = p.copyWith(displayName: displayName, timezone: timezone);
  }

  // ---- prayer logging (lock enforced here) ----
  Future<void> logPrayer({
    required DateTime date,
    required Prayer prayer,
    required PrayerStatus status,
  }) async {
    final d = Day.only(date);
    if (GraceLock.isLocked(d, clock.now())) throw DayLockedException(d);
    final next = List<PrayerLog>.from(_logs.value)
      ..removeWhere((l) => Day.isSame(l.prayerDate, d) && l.prayer == prayer)
      ..add(PrayerLog(prayerDate: d, prayer: prayer, status: status));
    _logs.value = List.unmodifiable(next);
  }

  Future<void> clearPrayer({
    required DateTime date,
    required Prayer prayer,
  }) async {
    final d = Day.only(date);
    if (GraceLock.isLocked(d, clock.now())) throw DayLockedException(d);
    final next = List<PrayerLog>.from(_logs.value)
      ..removeWhere((l) => Day.isSame(l.prayerDate, d) && l.prayer == prayer);
    _logs.value = List.unmodifiable(next);
  }

  List<PrayerLog> dayLogs(DateTime date) =>
      _logs.value.where((l) => Day.isSame(l.prayerDate, date)).toList();

  List<PrayerLog> rangeLogs(DateTime start, DateTime end) {
    final s = Day.only(start);
    final e = Day.only(end);
    return _logs.value
        .where((l) =>
            !Day.only(l.prayerDate).isBefore(s) &&
            !Day.only(l.prayerDate).isAfter(e))
        .toList();
  }

  // ---- payments (simulated) ----
  Future<bool> startTopUp(int amountPaise) async {
    if (amountPaise <= 0) return false;
    _credit(LedgerType.load, amountPaise);
    return true;
  }

  Future<int> requestRefund() async {
    if (activeCommitment != null) {
      throw StateError('Withdrawal is paused while a commitment is active.');
    }
    final amount = _wallet.value.balancePaise;
    if (amount <= 0) return 0;
    _setBalance(0);
    _appendLedger(LedgerType.refund, amount);
    return amount;
  }

  // ---- commitments ----
  Future<Commitment> createCommitment({
    required DateTime startDate,
    required DateTime endDate,
    required int stakePerPrayerPaise,
  }) async {
    final c = Commitment(
      id: _id('cmt'),
      startDate: Day.only(startDate),
      endDate: Day.only(endDate),
      stakePerPrayerPaise: stakePerPrayerPaise,
      status: CommitmentStatus.active,
    );
    _commitments.add(c);
    _publishCommitments();
    _activeCommitment.value = c;
    return c;
  }

  Future<void> completeCommitment(String id, {required bool rollover}) async {
    final idx = _commitments.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _commitments[idx] =
          _commitments[idx].copyWith(status: CommitmentStatus.completed);
      _publishCommitments();
    }
    _activeCommitment.value = null;
    final remaining = _wallet.value.balancePaise;
    if (rollover) {
      // Balance carries forward into the next commitment, untouched. The entry
      // documents the decision (and marks the commitment resolved).
      _appendLedger(LedgerType.rollover, remaining, commitmentId: id);
    } else {
      if (remaining > 0) _setBalance(0);
      _appendLedger(LedgerType.refund, remaining, commitmentId: id);
    }
  }

  Future<void> cancelCommitment(String id) async {
    final idx = _commitments.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _commitments[idx] =
          _commitments[idx].copyWith(status: CommitmentStatus.cancelled);
      _publishCommitments();
    }
    if (_activeCommitment.value?.id == id) _activeCommitment.value = null;
  }

  // ---- internal money helpers ----
  void _setBalance(int paise) =>
      _wallet.value = Wallet(balancePaise: paise < 0 ? 0 : paise);

  void _credit(LedgerType type, int amountPaise) {
    _setBalance(_wallet.value.balancePaise + amountPaise);
    _appendLedger(type, amountPaise);
  }

  void _appendLedger(LedgerType type, int amountPaise,
      {String? commitmentId, DateTime? prayerDate, DateTime? at}) {
    final next = List<LedgerEntry>.from(_ledger.value)
      ..add(LedgerEntry(
        id: _id('led'),
        type: type,
        amountPaise: amountPaise,
        createdAt: at ?? clock.now(),
        commitmentId: commitmentId,
        prayerDate: prayerDate,
      ));
    _ledger.value = List.unmodifiable(next);
  }

  // ====================================================================
  // Seeding
  // ====================================================================

  void _seed(DevScenario scenario) {
    final now = clock.now();
    final today = Day.only(now);
    _commitments.clear();
    _publishCommitments();
    _activeCommitment.value = null;
    _logs.value = const [];
    _ledger.value = const [];
    _settlements.value = const [];
    _wallet.value = const Wallet(balancePaise: 0);
    _charity.value = _seedCharity(now);

    switch (scenario) {
      case DevScenario.freshUser:
        _signedIn.value = false;
        _profile.value = null;
      case DevScenario.active:
        _signInSeed('Bilal');
        _seedWorld(
          today: today,
          startOffset: 11, // started 11 days ago → today is day 12
          totalDays: 30,
          stakePaise: 2000, // ₹20 / prayer
          loads: const [(0, 30000), (7, 20000)], // ₹300 + ₹200
          missPlan: _activeMissPlan,
          todayPlan: const {
            Prayer.fajr: PrayerStatus.prayed,
            Prayer.dhuhr: PrayerStatus.prayed,
            Prayer.asr: PrayerStatus.late,
          },
          status: CommitmentStatus.active,
        );
      case DevScenario.depletedWallet:
        _signInSeed('Bilal');
        _seedWorld(
          today: today,
          startOffset: 11,
          totalDays: 30,
          stakePaise: 2000,
          loads: const [(0, 16000)], // only ₹160 loaded — runs dry
          missPlan: _depletedMissPlan,
          todayPlan: const {Prayer.fajr: PrayerStatus.prayed},
          status: CommitmentStatus.active,
        );
      case DevScenario.completedPendingRefund:
        _signInSeed('Bilal');
        _seedWorld(
          today: today,
          startOffset: 7, // a 7-day commitment that ended yesterday
          totalDays: 7,
          stakePaise: 3000, // ₹30 / prayer
          loads: const [(0, 50000)],
          missPlan: _completedMissPlan,
          todayPlan: const {},
          status: CommitmentStatus.completed,
        );
    }
  }

  void _signInSeed(String name) {
    _signedIn.value = true;
    _profile.value = Profile(
      id: _id('user'),
      displayName: name,
      timezone: 'Asia/Kolkata',
    );
  }

  /// Deterministic miss plans, keyed by day-offset from the start.
  static const Map<int, Map<Prayer, PrayerStatus>> _activeMissPlan = {
    2: {Prayer.isha: PrayerStatus.late},
    3: {Prayer.asr: PrayerStatus.missed},
    6: {Prayer.fajr: PrayerStatus.missed, Prayer.isha: PrayerStatus.missed},
    8: {Prayer.fajr: PrayerStatus.late},
    9: {Prayer.dhuhr: PrayerStatus.missed},
  };

  static const Map<int, Map<Prayer, PrayerStatus>> _depletedMissPlan = {
    1: {Prayer.fajr: PrayerStatus.missed},
    2: {Prayer.fajr: PrayerStatus.missed, Prayer.isha: PrayerStatus.missed},
    4: {Prayer.asr: PrayerStatus.missed, Prayer.maghrib: PrayerStatus.missed},
    5: {Prayer.fajr: PrayerStatus.missed},
    7: {Prayer.dhuhr: PrayerStatus.missed, Prayer.fajr: PrayerStatus.missed},
    9: {Prayer.isha: PrayerStatus.missed},
  };

  static const Map<int, Map<Prayer, PrayerStatus>> _completedMissPlan = {
    1: {Prayer.fajr: PrayerStatus.late},
    3: {Prayer.asr: PrayerStatus.missed},
    5: {Prayer.isha: PrayerStatus.missed},
  };

  void _seedWorld({
    required DateTime today,
    required int startOffset,
    required int totalDays,
    required int stakePaise,
    required List<(int, int)> loads, // (dayOffset, paise)
    required Map<int, Map<Prayer, PrayerStatus>> missPlan,
    required Map<Prayer, PrayerStatus> todayPlan,
    required CommitmentStatus status,
  }) {
    final start = today.subtract(Duration(days: startOffset));
    final end = start.add(Duration(days: totalDays - 1));
    final commitment = Commitment(
      id: _id('cmt'),
      startDate: start,
      endDate: end,
      stakePerPrayerPaise: stakePaise,
      status: status,
    );
    _commitments.add(commitment);
    _publishCommitments();
    if (status == CommitmentStatus.active) {
      _activeCommitment.value = commitment;
    }

    final logs = <PrayerLog>[];

    // Build a chronologically-ordered list of money events so the running
    // balance respects "deductions stop at zero".
    final events = <(_EvtKind, DateTime, int, DateTime?, int)>[]; // kind, at, paise, prayerDate, missed

    for (final (offset, paise) in loads) {
      final at = start.add(Duration(days: offset, hours: 9));
      events.add((_EvtKind.load, at, paise, null, 0));
    }

    for (int i = 0; i < totalDays; i++) {
      final date = start.add(Duration(days: i));
      if (date.isAfter(today)) break;
      final isToday = Day.isSame(date, today);
      final Map<Prayer, PrayerStatus> statuses;
      if (isToday && status == CommitmentStatus.active) {
        statuses = todayPlan;
      } else {
        statuses = {
          for (final p in Prayer.ordered)
            p: missPlan[i]?[p] ?? PrayerStatus.prayed,
        };
      }
      statuses.forEach((p, s) {
        logs.add(PrayerLog(prayerDate: date, prayer: p, status: s));
      });

      final isLocked = GraceLock.isLocked(date, today.add(const Duration(hours: 9)));
      if (isLocked) {
        final missed = statuses.values
            .where((s) => s == PrayerStatus.missed)
            .length;
        if (missed > 0) {
          final at = GraceLock.lockTimeFor(date);
          events.add((_EvtKind.deduct, at, missed * stakePaise, date, missed));
        }
      }
    }

    events.sort((a, b) => a.$2.compareTo(b.$2));

    int balance = 0;
    final ledger = <LedgerEntry>[];
    final settlements = <Settlement>[];
    for (final (kind, at, paise, prayerDate, missed) in events) {
      if (kind == _EvtKind.load) {
        balance += paise;
        ledger.add(LedgerEntry(
          id: _id('led'),
          type: LedgerType.load,
          amountPaise: paise,
          createdAt: at,
        ));
      } else {
        final actual = paise > balance ? balance : paise; // stop at zero
        balance -= actual;
        if (actual > 0) {
          ledger.add(LedgerEntry(
            id: _id('led'),
            type: LedgerType.deduct,
            amountPaise: actual,
            createdAt: at,
            commitmentId: commitment.id,
            prayerDate: prayerDate,
          ));
        }
        settlements.add(Settlement(
          commitmentId: commitment.id,
          prayerDate: prayerDate!,
          missedCount: missed,
          deductedPaise: actual,
        ));
      }
    }

    _logs.value = List.unmodifiable(logs);
    _ledger.value = List.unmodifiable(ledger);
    _settlements.value = List.unmodifiable(settlements);
    _setBalance(balance);
  }

  List<CharityDisbursement> _seedCharity(DateTime now) {
    return List.unmodifiable([
      CharityDisbursement(
        id: 'cd_0001',
        amountPaise: 2500000, // ₹25,000 pooled across many people
        recipientNote: 'Iftar meals for families in need · Hyderabad',
        proofUrl: 'https://sukoon.example/sadaqah/0001',
        disbursedAt: DateTime(now.year, now.month - 1, 14),
      ),
      CharityDisbursement(
        id: 'cd_0002',
        amountPaise: 1800000, // ₹18,000
        recipientNote: 'Warm blankets distributed, in sha Allah · Srinagar',
        proofUrl: 'https://sukoon.example/sadaqah/0002',
        disbursedAt: DateTime(now.year, now.month - 2, 3),
      ),
    ]);
  }

  Future<void> dispose() async {
    await Future.wait([
      _signedIn.dispose(),
      _profile.dispose(),
      _wallet.dispose(),
      _activeCommitment.dispose(),
      _logs.dispose(),
      _ledger.dispose(),
      _settlements.dispose(),
      _charity.dispose(),
      _commitmentsEmit.dispose(),
    ]);
  }
}

enum _EvtKind { load, deduct }

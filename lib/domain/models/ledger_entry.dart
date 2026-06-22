import '../enums/ledger_type.dart';

class LedgerEntry {
  final String id;
  final LedgerType type;

  /// Always a positive magnitude in paise; [LedgerType.isCredit] gives direction.
  final int amountPaise;
  final DateTime createdAt;
  final String? commitmentId;

  /// Date-only, when the entry relates to a specific day's settlement.
  final DateTime? prayerDate;

  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amountPaise,
    required this.createdAt,
    this.commitmentId,
    this.prayerDate,
  });
}

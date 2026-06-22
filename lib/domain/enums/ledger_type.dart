/// Append-only ledger entry kinds. Phrased user-side, not system-side:
/// the UI renders these as "Loaded / Set aside / Given as sadaqah / Refunded /
/// Rolled over" — never "deduct" or "webhook" (anti-slop §7).
enum LedgerType {
  load,
  deduct,
  refund,
  rollover,
  withdraw;

  /// Whether this entry increases the wallet balance.
  bool get isCredit => this == LedgerType.load || this == LedgerType.refund;
}

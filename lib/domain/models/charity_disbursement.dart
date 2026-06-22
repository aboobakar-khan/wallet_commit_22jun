class CharityDisbursement {
  final String id;
  final int amountPaise;

  /// Dignified description of where it went — "people in need, in sha Allah".
  final String recipientNote;
  final String? proofUrl;
  final DateTime disbursedAt;

  const CharityDisbursement({
    required this.id,
    required this.amountPaise,
    required this.recipientNote,
    required this.disbursedAt,
    this.proofUrl,
  });
}

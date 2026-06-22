class Wallet {
  /// Balance in integer paise. Never negative — deductions stop at zero.
  final int balancePaise;

  const Wallet({required this.balancePaise});

  bool get isEmpty => balancePaise <= 0;
}

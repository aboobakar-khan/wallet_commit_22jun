import 'package:intl/intl.dart';

/// Money is stored as integer **paise** everywhere (mirrors the eventual DB).
/// Formatting keeps it quiet and exact — no floats in storage, tabular on screen.
abstract final class Money {
  static final NumberFormat _grouped = NumberFormat.decimalPattern('en_IN');

  /// Whole rupees from paise (floor). Used for sliders/presets.
  static int toRupees(int paise) => paise ~/ 100;
  static int fromRupees(num rupees) => (rupees * 100).round();

  /// "₹1,250" or "₹12.50". Uses Indian digit grouping and a typographic minus.
  static String format(int paise, {bool symbol = true}) {
    final negative = paise < 0;
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final pp = abs % 100;
    final whole = _grouped.format(rupees);
    final body = pp == 0 ? whole : '$whole.${pp.toString().padLeft(2, '0')}';
    final sign = negative ? '−' : ''; // U+2212 minus, not a hyphen
    final sym = symbol ? '₹' : ''; // ₹
    return '$sign$sym$body';
  }
}

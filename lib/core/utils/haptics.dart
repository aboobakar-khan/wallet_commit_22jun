import 'package:flutter/services.dart';

/// Haptics are deliberate and few — on commit, on log, on completion (THESIS §9).
/// Never a buzz for navigation; the feel should be a quiet confirmation.
abstract final class Haptics {
  /// Logging a prayer — fires on the same frame the bloom begins.
  static void log() => HapticFeedback.lightImpact();

  /// Committing (setup) and other deliberate confirmations.
  static void commit() => HapticFeedback.mediumImpact();

  /// A commitment completed.
  static void completion() => HapticFeedback.mediumImpact();

  /// Light selection feedback for toggles.
  static void select() => HapticFeedback.selectionClick();
}

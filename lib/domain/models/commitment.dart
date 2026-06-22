import '../../core/utils/day.dart';
import '../enums/commitment_status.dart';

class Commitment {
  final String id;

  /// Date-only (local midnight), inclusive.
  final DateTime startDate;
  final DateTime endDate;
  final int stakePerPrayerPaise;
  final CommitmentStatus status;

  const Commitment({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.stakePerPrayerPaise,
    required this.status,
  });

  /// Total days in the commitment, inclusive of both ends.
  int get totalDays => Day.between(startDate, endDate) + 1;

  /// The honest ceiling shown at setup: if every prayer were missed.
  int get maxPossibleSadaqahPaise => totalDays * 5 * stakePerPrayerPaise;

  /// 1-based day index for [today] (clamped to the commitment span).
  int dayNumber(DateTime today) {
    final n = Day.between(startDate, today) + 1;
    if (n < 1) return 1;
    if (n > totalDays) return totalDays;
    return n;
  }

  Commitment copyWith({CommitmentStatus? status}) => Commitment(
        id: id,
        startDate: startDate,
        endDate: endDate,
        stakePerPrayerPaise: stakePerPrayerPaise,
        status: status ?? this.status,
      );
}

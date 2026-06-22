import '../enums/prayer.dart';
import '../enums/prayer_status.dart';

class PrayerLog {
  /// Date-only (local midnight).
  final DateTime prayerDate;
  final Prayer prayer;
  final PrayerStatus status;

  const PrayerLog({
    required this.prayerDate,
    required this.prayer,
    required this.status,
  });

  PrayerLog copyWith({PrayerStatus? status}) => PrayerLog(
        prayerDate: prayerDate,
        prayer: prayer,
        status: status ?? this.status,
      );
}

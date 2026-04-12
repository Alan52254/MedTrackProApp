import '../../../core/models/medication_event.dart';
import '../../../core/models/prescription.dart';

class CalendarEventViewModel {
  const CalendarEventViewModel({
    required this.event,
    required this.prescription,
  });

  final MedicationEvent event;
  final Prescription prescription;

  String get timeLabel {
    final int hour = event.scheduledStart.hour;
    final int minute = event.scheduledStart.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get drugName => prescription.drugName;

  String get dose => prescription.dose;

  String get instruction => prescription.administrationType;

  String get statusLabel {
    switch (event.status) {
      case 'done':
        return 'Done';
      case 'skipped':
        return 'Skipped';
      case 'delayed':
        return 'Delayed';
      default:
        return 'Pending';
    }
  }

  String? get originalTimeLabel {
    final DateTime? original = event.originalStart;
    if (original == null) {
      return null;
    }
    final int hour = original.hour;
    final int minute = original.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get detailLine =>
      prescription.note.isEmpty ? prescription.commonFrequency : prescription.note;
}

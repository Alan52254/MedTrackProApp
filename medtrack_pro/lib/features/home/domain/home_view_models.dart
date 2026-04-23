import '../../../core/models/medication_event.dart';
import '../../../core/models/prescription.dart';

class HomeMedicationViewModel {
  const HomeMedicationViewModel({
    required this.event,
    required this.prescription,
  });

  final MedicationEvent event;
  final Prescription prescription;

  bool get isActionable =>
      event.status == 'pending' || event.status == 'delayed';

  bool get isResolved =>
      event.status == 'done' ||
      event.status == 'skipped' ||
      event.status == 'requires_reschedule';

  String get doseLine => prescription.dose;

  String get instructionLine => prescription.administrationType;

  String get reminderText =>
      'It is time to take ${prescription.drugName} (${prescription.dose}).';

  String get detailLine => prescription.note.isEmpty
      ? prescription.commonFrequency
      : prescription.note;

  String get timelineStatusLabel {
    switch (event.status) {
      case 'done':
        return 'Done';
      case 'delayed':
        return 'Delayed';
      case 'skipped':
        return 'Skipped';
      case 'requires_reschedule':
        return 'Reschedule';
      default:
        return 'Pending';
    }
  }

  String get scheduledTimeLabel {
    final int normalizedHour = event.scheduledStart.hour % 12 == 0
        ? 12
        : event.scheduledStart.hour % 12;
    final String minute = event.scheduledStart.minute.toString().padLeft(
      2,
      '0',
    );
    final String meridiem = event.scheduledStart.hour >= 12 ? 'PM' : 'AM';
    return '$normalizedHour:$minute $meridiem';
  }
}

class HomeReminderViewModel {
  const HomeReminderViewModel({required this.entry, required this.isUrgent});

  final HomeMedicationViewModel entry;
  final bool isUrgent;
}

import '../../../core/models/medication_event.dart';
import '../../../core/models/patient_profile.dart';
import '../../../core/models/prescription.dart';
import '../domain/home_view_models.dart';

class HomeState {
  const HomeState({
    required this.referenceDate,
    required this.currentTime,
    required this.patientProfile,
    required this.prescriptions,
    required this.medicationEvents,
    required this.scheduleAdjustmentMessage,
  });

  final DateTime referenceDate;
  final DateTime currentTime;
  final PatientProfile patientProfile;
  final List<Prescription> prescriptions;
  final List<MedicationEvent> medicationEvents;
  final String scheduleAdjustmentMessage;

  List<HomeMedicationViewModel> get todayTimeline {
    final Map<String, Prescription> prescriptionById = <String, Prescription>{
      for (final Prescription prescription in prescriptions)
        prescription.id: prescription,
    };

    final List<HomeMedicationViewModel> items =
        medicationEvents
            .where(
              (MedicationEvent event) =>
                  _isSameDay(event.scheduledStart, referenceDate) &&
                  (prescriptionById[event.prescriptionId]?.active ?? false),
            )
            .map(
              (MedicationEvent event) => HomeMedicationViewModel(
                event: event,
                prescription: prescriptionById[event.prescriptionId]!,
              ),
            )
            .toList(growable: true)
          ..sort(_compareTimelineItems);

    return items;
  }

  HomeMedicationViewModel? get nextMedication {
    for (final HomeMedicationViewModel item in todayTimeline) {
      if (item.isActionable) {
        return item;
      }
    }
    return null;
  }

  HomeReminderViewModel? get activeReminder {
    for (final HomeMedicationViewModel item in todayTimeline) {
      if (!item.isActionable) {
        continue;
      }
      if (!currentTime.isBefore(item.event.scheduledStart)) {
        return HomeReminderViewModel(
          entry: item,
          isUrgent: item.event.delayMinutes > 0,
        );
      }
    }
    return null;
  }

  int get pendingCount => todayTimeline
      .where((HomeMedicationViewModel item) => item.isActionable)
      .length;

  int _compareTimelineItems(
    HomeMedicationViewModel first,
    HomeMedicationViewModel second,
  ) {
    if (first.isResolved != second.isResolved) {
      return first.isResolved ? 1 : -1;
    }
    return first.event.scheduledStart.compareTo(second.event.scheduledStart);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

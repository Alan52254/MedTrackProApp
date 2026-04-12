import '../../../core/models/decision_alert.dart';
import '../../../core/models/medication_event.dart';
import '../../../core/models/patient_profile.dart';
import '../../../core/models/prescription.dart';
import '../domain/home_view_models.dart';

class HomeState {
  const HomeState({
    required this.referenceDate,
    required this.patientProfile,
    required this.prescriptions,
    required this.medicationEvents,
    required this.alerts,
  });

  final DateTime referenceDate;
  final PatientProfile patientProfile;
  final List<Prescription> prescriptions;
  final List<MedicationEvent> medicationEvents;
  final List<DecisionAlert> alerts;

  HomeState copyWith({
    DateTime? referenceDate,
    PatientProfile? patientProfile,
    List<Prescription>? prescriptions,
    List<MedicationEvent>? medicationEvents,
    List<DecisionAlert>? alerts,
  }) {
    return HomeState(
      referenceDate: referenceDate ?? this.referenceDate,
      patientProfile: patientProfile ?? this.patientProfile,
      prescriptions: prescriptions ?? this.prescriptions,
      medicationEvents: medicationEvents ?? this.medicationEvents,
      alerts: alerts ?? this.alerts,
    );
  }

  List<DecisionAlert> get visibleAlerts => alerts
      .where((DecisionAlert alert) => !alert.dismissed)
      .toList(growable: false);

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
          ..sort(
            (HomeMedicationViewModel first, HomeMedicationViewModel second) =>
                first.event.scheduledStart.compareTo(
                  second.event.scheduledStart,
                ),
          );

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

  List<MedicationEvent> get _adherenceWindowEvents {
    final DateTime start = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).subtract(const Duration(days: 6));
    final DateTime end = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      23,
      59,
      59,
    );

    return medicationEvents
        .where(
          (MedicationEvent event) =>
              !event.scheduledStart.isBefore(start) &&
              !event.scheduledStart.isAfter(end),
        )
        .toList(growable: false);
  }

  int get completedDoseCount => _adherenceWindowEvents
      .where((MedicationEvent event) => event.status == 'done')
      .length;

  int get skippedDoseCount => _adherenceWindowEvents
      .where((MedicationEvent event) => event.status == 'skipped')
      .length;

  int get resolvedDoseCount => completedDoseCount + skippedDoseCount;

  int get adherencePercent {
    if (resolvedDoseCount == 0) {
      return 0;
    }
    return ((completedDoseCount / resolvedDoseCount) * 100).round();
  }

  double get adherenceProgress {
    if (resolvedDoseCount == 0) {
      return 0;
    }
    return completedDoseCount / resolvedDoseCount;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

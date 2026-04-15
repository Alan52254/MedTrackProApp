import 'package:flutter/foundation.dart';

import '../models/calendar_context_event.dart';
import '../models/decision_alert.dart';
import '../models/medication_event.dart';
import '../models/patient_profile.dart';
import '../models/prescription.dart';
import 'local_demo_seed.dart';

class LocalDemoStore extends ChangeNotifier {
  LocalDemoStore({LocalDemoSeedData? seedData})
    : this._(seedData ?? LocalDemoSeed.build());

  LocalDemoStore._(LocalDemoSeedData seedData)
    : _seedData = seedData,
      _patientProfile = seedData.patientProfile,
      _prescriptions = List<Prescription>.from(seedData.prescriptions),
      _medicationEvents = List<MedicationEvent>.from(seedData.medicationEvents),
      _calendarContextEvents = List<CalendarContextEvent>.from(
        seedData.calendarContextEvents,
      ),
      _alerts = List<DecisionAlert>.from(seedData.alerts);

  final LocalDemoSeedData _seedData;

  PatientProfile _patientProfile;
  List<Prescription> _prescriptions;
  List<MedicationEvent> _medicationEvents;
  List<CalendarContextEvent> _calendarContextEvents;
  List<DecisionAlert> _alerts;

  DateTime get referenceDate => _seedData.referenceDate;

  PatientProfile get patientProfile => _patientProfile;

  List<Prescription> get prescriptions =>
      List<Prescription>.unmodifiable(_prescriptions);

  List<MedicationEvent> get medicationEvents =>
      List<MedicationEvent>.unmodifiable(_medicationEvents);

  List<CalendarContextEvent> get calendarContextEvents =>
      List<CalendarContextEvent>.unmodifiable(_calendarContextEvents);

  List<DecisionAlert> get alerts => List<DecisionAlert>.unmodifiable(_alerts);

  void updatePrescription(Prescription updatedPrescription) {
    _prescriptions = _prescriptions
        .map(
          (Prescription prescription) =>
              prescription.id == updatedPrescription.id
              ? updatedPrescription
              : prescription,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void updatePatientProfile(PatientProfile updatedProfile) {
    _patientProfile = updatedProfile;
    notifyListeners();
  }

  void updateMedicationEvent(MedicationEvent updatedEvent) {
    _medicationEvents = _medicationEvents
        .map(
          (MedicationEvent event) =>
              event.id == updatedEvent.id ? updatedEvent : event,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void upsertCalendarContextEvent(CalendarContextEvent updatedEvent) {
    final bool exists = _calendarContextEvents.any(
      (CalendarContextEvent event) => event.id == updatedEvent.id,
    );

    if (exists) {
      _calendarContextEvents = _calendarContextEvents
          .map(
            (CalendarContextEvent event) =>
                event.id == updatedEvent.id ? updatedEvent : event,
          )
          .toList(growable: false);
    } else {
      _calendarContextEvents = <CalendarContextEvent>[
        ..._calendarContextEvents,
        updatedEvent,
      ];
    }
    notifyListeners();
  }

  void replaceAlerts(List<DecisionAlert> alerts) {
    _alerts = List<DecisionAlert>.from(alerts);
    notifyListeners();
  }
}

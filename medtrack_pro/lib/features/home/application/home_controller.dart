import 'package:flutter/foundation.dart';

import '../../../core/models/decision_alert.dart';
import '../../../core/models/medication_event.dart';
import '../../../core/services/local_demo_store.dart';
import 'home_state.dart';

class HomeController extends ChangeNotifier {
  HomeController({LocalDemoStore? store})
    : _store = store ?? LocalDemoStore(),
      _ownsStore = store == null {
    _store.addListener(_handleStoreChanged);
  }

  static const String scheduleImpactAlertId = 'schedule-impact';

  final LocalDemoStore _store;
  final bool _ownsStore;

  HomeState get state => HomeState(
    referenceDate: _store.referenceDate,
    patientProfile: _store.patientProfile,
    prescriptions: _store.prescriptions,
    medicationEvents: _store.medicationEvents,
    alerts: _store.alerts,
  );

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  void markDone(String eventId) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return;
    }

    final DateTime actionTime = DateTime.now();
    _store.updateMedicationEvent(
      event.copyWith(
        status: 'done',
        actualTakenAt: actionTime,
        updatedAt: actionTime,
      ),
    );
  }

  void delayEvent(String eventId, Duration delay) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return;
    }
    final DateTime targetTime = event.scheduledStart.add(delay);
    delayEventToTime(eventId, targetTime);
  }

  /// Delays [eventId] so its scheduledStart becomes [targetTime].
  ///
  /// Returns the normalised date of [targetTime] so the caller can navigate
  /// to the calendar for that day, or `null` if the event was not found.
  DateTime? delayEventToTime(String eventId, DateTime targetTime) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return null;
    }

    final Duration eventLength = event.scheduledEnd.difference(
      event.scheduledStart,
    );
    final DateTime updatedAt = DateTime.now();
    final int totalDelayMinutes = targetTime
        .difference(event.originalStart ?? event.scheduledStart)
        .inMinutes;

    final MedicationEvent delayedEvent = event.copyWith(
      scheduledStart: targetTime,
      scheduledEnd: targetTime.add(eventLength),
      originalStart: event.originalStart ?? event.scheduledStart,
      delayMinutes: totalDelayMinutes,
      status: 'delayed',
      updatedAt: updatedAt,
    );

    _store.updateMedicationEvent(delayedEvent);

    final String timeLabel =
        '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}';
    _store.replaceAlerts(
      _upsertScheduleImpactAlert(
        severity: 'info',
        explanation:
            '${_labelForPrescription(event.prescriptionId)} was delayed to '
            '$timeLabel. Only this dose changed in the local demo.',
        recommendation:
            'Keep the rest of today\'s plan unchanged for now and monitor the next dose.',
      ),
    );

    return DateTime(targetTime.year, targetTime.month, targetTime.day);
  }

  void skipEvent(String eventId) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return;
    }

    final MedicationEvent skippedEvent = event.copyWith(
      status: 'skipped',
      clearActualTakenAt: true,
      updatedAt: DateTime.now(),
    );

    _store.updateMedicationEvent(skippedEvent);
    _store.replaceAlerts(
      _upsertScheduleImpactAlert(
        severity: 'warning',
        explanation:
            '${_labelForPrescription(event.prescriptionId)} was skipped. '
            'This local demo flags a possible downstream impact without recalculating the full schedule.',
        recommendation:
            'Review the remaining doses today before bedtime and avoid stacking catch-up doses.',
      ),
    );
  }

  void dismissAlert(String alertId) {
    _store.replaceAlerts(
      state.alerts
          .map(
            (DecisionAlert alert) =>
                alert.id == alertId ? alert.copyWith(dismissed: true) : alert,
          )
          .toList(growable: false),
    );
  }

  void handleAlertAction(String alertId, String actionLabel) {
    if (actionLabel.isEmpty) {
      return;
    }
    dismissAlert(alertId);
  }

  MedicationEvent? _findEvent(String eventId) {
    for (final MedicationEvent event in _store.medicationEvents) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  List<DecisionAlert> _upsertScheduleImpactAlert({
    required String severity,
    required String explanation,
    required String recommendation,
  }) {
    final DecisionAlert updatedAlert = DecisionAlert(
      id: scheduleImpactAlertId,
      patientId: _store.patientProfile.id,
      type: 'schedule_impact',
      severity: severity,
      title: 'Schedule impact updated',
      explanation: explanation,
      recommendation: recommendation,
      actionButtons: const <String>['Keep current plan'],
      dismissed: false,
      createdAt: DateTime.now(),
    );

    final List<DecisionAlert> remainingAlerts = _store.alerts
        .where((DecisionAlert alert) => alert.id != scheduleImpactAlertId)
        .toList(growable: true);

    remainingAlerts.insert(0, updatedAlert);
    return remainingAlerts;
  }

  String _labelForPrescription(String prescriptionId) {
    return _store.prescriptions
        .firstWhere((prescription) => prescription.id == prescriptionId)
        .drugName;
  }

  void _handleStoreChanged() {
    notifyListeners();
  }
}

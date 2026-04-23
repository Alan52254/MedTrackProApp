import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/medication_event.dart';
import '../../../core/services/local_demo_seed.dart';
import '../../../core/services/local_demo_store.dart';
import 'home_state.dart';
import 'reminder_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController({LocalDemoStore? store})
    : _store = store ?? LocalDemoStore(),
      _ownsStore = store == null,
      _currentTime = DateTime.now() {
    _store.addListener(_handleStoreChanged);
    _evaluateReminderOnFirstLoad();
    _ticker = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _handleTimeTick(),
    );
  }

  static const int rescheduleDelayThresholdMultiplier = 3;

  final LocalDemoStore _store;
  final bool _ownsStore;
  ReminderController? _reminderController;
  Timer? _ticker;
  DateTime _currentTime;
  String _scheduleAdjustmentMessage = '';
  String? _lastActiveReminderEventId;

  set reminderController(ReminderController? controller) {
    _reminderController = controller;
  }

  int get reminderIntervalMinutes => _store.reminderIntervalMinutes > 0
      ? _store.reminderIntervalMinutes
      : LocalDemoSeed.defaultReminderIntervalMinutes;

  HomeState get state => HomeState(
    referenceDate: _store.referenceDate,
    currentTime: _currentTime,
    patientProfile: _store.patientProfile,
    prescriptions: _store.prescriptions,
    medicationEvents: _store.medicationEvents,
    scheduleAdjustmentMessage: _scheduleAdjustmentMessage,
  );

  @override
  void dispose() {
    _ticker?.cancel();
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
        clearLastReminderTime: true,
        updatedAt: actionTime,
      ),
    );
    _reminderController?.cancelReminderForEvent(eventId);
    _clearScheduleAdjustmentIfResolved();
  }

  void delayEvent(String eventId, Duration delay) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return;
    }
    final DateTime targetTime = event.scheduledStart.add(delay);
    delayEventToTime(eventId, targetTime);
  }

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
      clearLastReminderTime: true,
      updatedAt: updatedAt,
    );

    _store.updateMedicationEvent(delayedEvent);
    _reminderController?.cancelReminderForEvent(eventId);
    _setPlaceholderRescheduleMessageIfNeeded(delayedEvent, _currentTime);

    return DateTime(targetTime.year, targetTime.month, targetTime.day);
  }

  void snoozeReminder(String eventId) {
    delayEvent(eventId, Duration(minutes: reminderIntervalMinutes));
  }

  void skipEvent(String eventId) {
    final MedicationEvent? event = _findEvent(eventId);
    if (event == null) {
      return;
    }

    final MedicationEvent skippedEvent = event.copyWith(
      status: 'skipped',
      clearActualTakenAt: true,
      clearLastReminderTime: true,
      updatedAt: DateTime.now(),
    );

    _store.updateMedicationEvent(skippedEvent);
    _reminderController?.cancelReminderForEvent(eventId);
    _clearScheduleAdjustmentIfResolved();
  }

  MedicationEvent? _findEvent(String eventId) {
    for (final MedicationEvent event in _store.medicationEvents) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  void _setPlaceholderRescheduleMessageIfNeeded(
    MedicationEvent event,
    DateTime now,
  ) {
    final int threshold =
        reminderIntervalMinutes * rescheduleDelayThresholdMultiplier;
    final DateTime baseline = event.originalStart ?? event.scheduledStart;
    final int overdueMinutes = now.difference(baseline).inMinutes;
    final bool exceededDelayThreshold = event.delayMinutes >= threshold;
    final bool exceededOverdueThreshold = overdueMinutes >= threshold;

    if (exceededDelayThreshold || exceededOverdueThreshold) {
      _scheduleAdjustmentMessage =
          'This dose may need rescheduling. Smart re-order guidance will be added in a later phase.';
    } else {
      _scheduleAdjustmentMessage = '';
    }
  }

  void _clearScheduleAdjustmentIfResolved() {
    final bool hasActionableEvents = _store.medicationEvents.any(
      (MedicationEvent event) =>
          (event.status == 'pending' || event.status == 'delayed'),
    );
    if (!hasActionableEvents) {
      _scheduleAdjustmentMessage = '';
    }
  }

  void _refreshScheduleAdjustmentMessage(DateTime now) {
    final Map<String, bool> activePrescriptionById = <String, bool>{
      for (final prescription in _store.prescriptions)
        prescription.id: prescription.active,
    };
    for (final MedicationEvent event in _store.medicationEvents) {
      if (event.status != 'pending' && event.status != 'delayed') {
        continue;
      }
      if (!(activePrescriptionById[event.prescriptionId] ?? false)) {
        continue;
      }
      _setPlaceholderRescheduleMessageIfNeeded(event, now);
      if (_scheduleAdjustmentMessage.isNotEmpty) {
        return;
      }
    }
    _scheduleAdjustmentMessage = '';
  }

  void _handleStoreChanged() {
    _currentTime = DateTime.now();
    _lastActiveReminderEventId = _computeActiveReminderEventId(_currentTime);
    _refreshScheduleAdjustmentMessage(_currentTime);
    notifyListeners();
  }

  void _handleTimeTick() {
    final DateTime now = DateTime.now();
    final String? nextActiveReminderEventId = _computeActiveReminderEventId(
      now,
    );
    final String previousMessage = _scheduleAdjustmentMessage;
    _refreshScheduleAdjustmentMessage(now);
    _currentTime = now;

    final bool reminderChanged =
        nextActiveReminderEventId != _lastActiveReminderEventId;
    final bool messageChanged = previousMessage != _scheduleAdjustmentMessage;
    if (reminderChanged || messageChanged) {
      _lastActiveReminderEventId = nextActiveReminderEventId;
      notifyListeners();
    }
  }

  String? _computeActiveReminderEventId(DateTime referenceTime) {
    final Map<String, bool> activePrescriptionById = <String, bool>{
      for (final prescription in _store.prescriptions)
        prescription.id: prescription.active,
    };
    final List<MedicationEvent> todayEvents =
        _store.medicationEvents
            .where(
              (MedicationEvent event) =>
                  event.scheduledStart.year == _store.referenceDate.year &&
                  event.scheduledStart.month == _store.referenceDate.month &&
                  event.scheduledStart.day == _store.referenceDate.day &&
                  (activePrescriptionById[event.prescriptionId] ?? false) &&
                  (event.status == 'pending' || event.status == 'delayed'),
            )
            .toList(growable: true)
          ..sort(
            (MedicationEvent first, MedicationEvent second) =>
                first.scheduledStart.compareTo(second.scheduledStart),
          );

    for (final MedicationEvent event in todayEvents) {
      if (!referenceTime.isBefore(event.scheduledStart)) {
        return event.id;
      }
    }
    return null;
  }

  void _evaluateReminderOnFirstLoad() {
    _currentTime = DateTime.now();
    _lastActiveReminderEventId = _computeActiveReminderEventId(_currentTime);
    _refreshScheduleAdjustmentMessage(_currentTime);
  }
}

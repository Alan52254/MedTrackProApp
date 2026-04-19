import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/medication_event.dart';
import '../../../core/models/prescription.dart';
import '../../../core/services/local_demo_store.dart';
import '../../../core/services/reminder_service.dart';

/// Evaluates pending medication events and triggers persistent reminders
/// for events within their scheduled window while the app is alive.
class ReminderController extends ChangeNotifier {
  ReminderController({
    required LocalDemoStore store,
    ReminderService? reminderService,
  }) : _store = store,
       _reminderService = reminderService ?? ReminderService() {
    _store.addListener(_evaluateReminders);
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _evaluateReminders(),
    );
    _evaluateReminders();
  }

  final LocalDemoStore _store;
  final ReminderService _reminderService;
  Timer? _timer;

  Future<void> cancelReminderForEvent(String eventId) async {
    await _reminderService.cancelReminder(eventId);
  }

  void _evaluateReminders() {
    final DateTime now = DateTime.now();
    final int reminderIntervalMinutes = _store.reminderIntervalMinutes > 0
        ? _store.reminderIntervalMinutes
        : ReminderService.fallbackIntervalMinutes;

    final Map<String, Prescription> prescriptionById = <String, Prescription>{
      for (final Prescription prescription in _store.prescriptions)
        prescription.id: prescription,
    };

    for (final MedicationEvent event in _store.medicationEvents) {
      final Prescription? prescription = prescriptionById[event.prescriptionId];
      if (prescription == null || !prescription.active) {
        continue;
      }

      final bool inWindow =
          !now.isBefore(event.scheduledStart) &&
          !now.isAfter(event.scheduledEnd);
      final bool needsReminder =
          event.status != 'done' && event.status != 'skipped';

      if (inWindow && needsReminder) {
        final bool shouldFire =
            event.lastReminderTime == null ||
            now.difference(event.lastReminderTime!).inMinutes >=
                reminderIntervalMinutes;

        if (shouldFire) {
          _reminderService.showReminder(
            eventId: event.id,
            title: 'Time to take ${prescription.drugName}',
            body:
                '${prescription.dose} - ${prescription.administrationType}. '
                'Tap to open MedTrack Pro.',
          );

          _store.updateMedicationEvent(
            event.copyWith(lastReminderTime: now, updatedAt: now),
          );
        }
      } else {
        _reminderService.cancelReminder(event.id);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _store.removeListener(_evaluateReminders);
    _reminderService.cancelAll();
    super.dispose();
  }
}

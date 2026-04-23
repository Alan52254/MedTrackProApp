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
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _evaluateReminders(),
    );
    _evaluateReminders();
  }

  final LocalDemoStore _store;
  final ReminderService _reminderService;
  Timer? _timer;
  bool _isEvaluating = false;
  bool _disposed = false;

  Future<void> cancelReminderForEvent(String eventId) async {
    if (_disposed) {
      return;
    }
    await _reminderService.cancelReminder(eventId);
  }

  void _evaluateReminders() {
    if (_disposed || _isEvaluating) {
      return;
    }

    _isEvaluating = true;
    final List<MedicationEvent> bulkUpdates = <MedicationEvent>[];

    try {
      final DateTime now = DateTime.now();
      final int reminderIntervalMinutes = _store.reminderIntervalMinutes > 0
          ? _store.reminderIntervalMinutes
          : ReminderService.fallbackIntervalMinutes;

      final Map<String, Prescription> prescriptionById = <String, Prescription>{
        for (final Prescription prescription in _store.prescriptions)
          prescription.id: prescription,
      };

      for (final MedicationEvent event in _store.medicationEvents) {
        final Prescription? prescription =
            prescriptionById[event.prescriptionId];
        if (prescription == null || !prescription.active) {
          continue;
        }

        final bool needsReminder =
            event.status == 'pending' || event.status == 'delayed';
        final bool overdue = !now.isBefore(event.scheduledStart);

        if (needsReminder && overdue) {
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

            if (event.lastReminderTime != now) {
              bulkUpdates.add(
                event.copyWith(lastReminderTime: now, updatedAt: now),
              );
            }
          }
        } else {
          _reminderService.cancelReminder(event.id);
        }
      }
    } finally {
      _isEvaluating = false;
      if (bulkUpdates.isNotEmpty && !_disposed) {
        Future<void>.microtask(() {
          if (!_disposed) {
            _store.updateMedicationEvents(bulkUpdates);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _reminderService.cancelAll();
    super.dispose();
  }
}

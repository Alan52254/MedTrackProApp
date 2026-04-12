import 'package:flutter/foundation.dart';

import '../../../core/models/medication_event.dart';
import '../../../core/models/prescription.dart';
import '../../../core/services/local_demo_store.dart';
import '../domain/calendar_view_models.dart';
import 'calendar_state.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({LocalDemoStore? store})
    : _store = store ?? LocalDemoStore(),
      _ownsStore = store == null {
    _selectedDate = DateTime(
      _store.referenceDate.year,
      _store.referenceDate.month,
      _store.referenceDate.day,
    );
    _store.addListener(_handleStoreChanged);
  }

  final LocalDemoStore _store;
  final bool _ownsStore;
  late DateTime _selectedDate;

  CalendarState get state {
    final DateTime today = DateTime(
      _store.referenceDate.year,
      _store.referenceDate.month,
      _store.referenceDate.day,
    );

    return CalendarState(
      selectedDate: _selectedDate,
      referenceDate: today,
      filteredEvents: _buildFilteredEvents(),
      dateStrip: _buildDateStrip(_selectedDate),
    );
  }

  void selectDate(DateTime date) {
    final DateTime normalised = DateTime(date.year, date.month, date.day);
    if (normalised == _selectedDate) {
      return;
    }
    _selectedDate = normalised;
    notifyListeners();
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  List<CalendarEventViewModel> _buildFilteredEvents() {
    final Map<String, Prescription> prescriptionById = <String, Prescription>{
      for (final Prescription prescription in _store.prescriptions)
        prescription.id: prescription,
    };

    final List<CalendarEventViewModel> items = _store.medicationEvents
        .where((MedicationEvent event) {
          final bool matchesDate = _isSameDay(
            event.scheduledStart,
            _selectedDate,
          );
          final bool isActive =
              prescriptionById[event.prescriptionId]?.active ?? false;
          return matchesDate && isActive;
        })
        .map(
          (MedicationEvent event) => CalendarEventViewModel(
            event: event,
            prescription: prescriptionById[event.prescriptionId]!,
          ),
        )
        .toList(growable: true)
      ..sort(
        (CalendarEventViewModel first, CalendarEventViewModel second) =>
            first.event.scheduledStart.compareTo(second.event.scheduledStart),
      );

    return items;
  }

  List<DateTime> _buildDateStrip(DateTime today) {
    return List<DateTime>.generate(
      7,
      (int index) => today.subtract(Duration(days: 3 - index)),
      growable: false,
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  void _handleStoreChanged() {
    notifyListeners();
  }
}

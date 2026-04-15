import 'package:flutter/foundation.dart';

import '../../../core/models/calendar_context_event.dart';
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
    _contextForm = _buildContextForm(_selectedDate);
    _store.addListener(_handleStoreChanged);
  }

  final LocalDemoStore _store;
  final bool _ownsStore;
  late DateTime _selectedDate;
  late CalendarContextFormData _contextForm;
  String _contextSaveMessage = '';

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
      contextEvents: _buildContextEvents(),
      dateStrip: _buildDateStrip(_selectedDate),
      contextForm: _contextForm,
      contextSaveMessage: _contextSaveMessage,
    );
  }

  void selectDate(DateTime date) {
    final DateTime normalised = DateTime(date.year, date.month, date.day);
    if (normalised == _selectedDate) {
      return;
    }
    _selectedDate = normalised;
    _contextForm = _buildContextForm(normalised);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void updateContextDate(DateTime date) {
    final DateTime normalised = DateTime(date.year, date.month, date.day);
    _selectedDate = normalised;
    _contextForm = _contextForm.copyWith(date: normalised);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void updateContextStartTime(String value) {
    _contextForm = _contextForm.copyWith(startTime: value);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void updateContextEndTime(String value) {
    _contextForm = _contextForm.copyWith(endTime: value);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void updateContextActivity(String value) {
    _contextForm = _contextForm.copyWith(activity: value);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void resetContextForm() {
    _contextForm = _buildContextForm(_selectedDate);
    _contextSaveMessage = '';
    notifyListeners();
  }

  void saveContextEvent() {
    final CalendarContextEvent? existingEvent = _existingContextEventFor(
      _contextForm.date,
    );
    final CalendarContextEvent event = CalendarContextEvent(
      id: _contextForm.id,
      patientId: _store.patientProfile.id,
      date: _contextForm.date,
      startTime: _contextForm.startTime,
      endTime: _contextForm.endTime,
      activity: _contextForm.activity.trim(),
      location: '',
      weather: '',
      fatigueLevel: '',
      source: 'local_demo',
      createdAt: existingEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _store.upsertCalendarContextEvent(event);
    _selectedDate = DateTime(event.date.year, event.date.month, event.date.day);
    _contextForm = _buildContextForm(_selectedDate);
    _contextSaveMessage = 'Context event saved locally.';
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

    final List<CalendarEventViewModel> items =
        _store.medicationEvents
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
                first.event.scheduledStart.compareTo(
                  second.event.scheduledStart,
                ),
          );

    return items;
  }

  List<CalendarContextEventViewModel> _buildContextEvents() {
    final List<CalendarContextEventViewModel> items =
        _store.calendarContextEvents
            .where(
              (CalendarContextEvent event) =>
                  _isSameDay(event.date, _selectedDate),
            )
            .map(
              (CalendarContextEvent event) =>
                  CalendarContextEventViewModel(event: event),
            )
            .toList(growable: true)
          ..sort(
            (
              CalendarContextEventViewModel first,
              CalendarContextEventViewModel second,
            ) => first.event.startTime.compareTo(second.event.startTime),
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

  CalendarContextFormData _buildContextForm(DateTime date) {
    final DateTime normalised = DateTime(date.year, date.month, date.day);
    final CalendarContextEvent? existing = _existingContextEventFor(normalised);

    if (existing != null) {
      return CalendarContextFormData(
        id: existing.id,
        date: normalised,
        startTime: existing.startTime,
        endTime: existing.endTime,
        activity: existing.activity,
      );
    }

    return CalendarContextFormData(
      id: 'ctx-${normalised.year}${normalised.month.toString().padLeft(2, '0')}${normalised.day.toString().padLeft(2, '0')}',
      date: normalised,
      startTime: '08:00',
      endTime: '08:30',
      activity: '',
    );
  }

  CalendarContextEvent? _existingContextEventFor(DateTime date) {
    for (final CalendarContextEvent event in _store.calendarContextEvents) {
      if (_isSameDay(event.date, date)) {
        return event;
      }
    }
    return null;
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

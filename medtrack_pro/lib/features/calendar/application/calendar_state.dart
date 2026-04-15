import '../domain/calendar_view_models.dart';

class CalendarContextFormData {
  const CalendarContextFormData({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.activity,
  });

  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String activity;

  CalendarContextFormData copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? activity,
  }) {
    return CalendarContextFormData(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activity: activity ?? this.activity,
    );
  }
}

class CalendarState {
  const CalendarState({
    required this.selectedDate,
    required this.referenceDate,
    required this.filteredEvents,
    required this.contextEvents,
    required this.dateStrip,
    required this.contextForm,
    required this.contextSaveMessage,
  });

  final DateTime selectedDate;
  final DateTime referenceDate;
  final List<CalendarEventViewModel> filteredEvents;
  final List<CalendarContextEventViewModel> contextEvents;
  final List<DateTime> dateStrip;
  final CalendarContextFormData contextForm;
  final String contextSaveMessage;

  bool get isEmpty => filteredEvents.isEmpty;

  bool isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool isSelectedDate(DateTime date) => isSameDay(date, selectedDate);

  bool isToday(DateTime date) => isSameDay(date, referenceDate);
}

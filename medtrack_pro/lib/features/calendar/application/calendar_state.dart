import '../domain/calendar_view_models.dart';

class CalendarState {
  const CalendarState({
    required this.selectedDate,
    required this.referenceDate,
    required this.filteredEvents,
    required this.dateStrip,
  });

  final DateTime selectedDate;
  final DateTime referenceDate;
  final List<CalendarEventViewModel> filteredEvents;

  /// Seven dates centered around today for the horizontal date selector.
  final List<DateTime> dateStrip;

  bool get isEmpty => filteredEvents.isEmpty;

  bool isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool isSelectedDate(DateTime date) => isSameDay(date, selectedDate);

  bool isToday(DateTime date) => isSameDay(date, referenceDate);
}

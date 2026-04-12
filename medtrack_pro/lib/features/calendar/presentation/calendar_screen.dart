import 'package:flutter/material.dart';

import '../application/calendar_controller.dart';
import '../application/calendar_state.dart';
import '../domain/calendar_view_models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.controller});

  final CalendarController? controller;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? CalendarController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final CalendarState state = _controller.state;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DateStripSelector(
              dates: state.dateStrip,
              selectedDate: state.selectedDate,
              referenceDate: state.referenceDate,
              onDateSelected: _controller.selectDate,
            ),
            const Divider(height: 1),
            Expanded(
              child: state.isEmpty
                  ? const _EmptyState()
                  : _EventList(
                      key: const Key('calendar-event-list'),
                      events: state.filteredEvents,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _DateStripSelector extends StatelessWidget {
  const _DateStripSelector({
    required this.dates,
    required this.selectedDate,
    required this.referenceDate,
    required this.onDateSelected,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final DateTime referenceDate;
  final ValueChanged<DateTime> onDateSelected;

  static const List<String> _weekdayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: dates.map((DateTime date) {
          final bool isSelected = _isSameDay(date, selectedDate);
          final bool isToday = _isSameDay(date, referenceDate);

          return _DateChip(
            key: Key('calendar-date-${date.month}-${date.day}'),
            weekday: _weekdayLabels[date.weekday - 1],
            day: date.day.toString(),
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onDateSelected(date),
          );
        }).toList(growable: false),
      ),
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    super.key,
    required this.weekday,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final String weekday;
  final String day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = isSelected
        ? colorScheme.primary
        : isToday
            ? colorScheme.primaryContainer
            : Colors.transparent;
    final Color textColor = isSelected
        ? colorScheme.onPrimary
        : isToday
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: isToday && !isSelected
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              weekday,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('calendar-empty-state'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.event_busy_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No medications scheduled',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select another date to view scheduled medications.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({super.key, required this.events});

  final List<CalendarEventViewModel> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: events.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final CalendarEventViewModel item = events[index];
        return _EventCard(
          key: Key('calendar-event-${item.event.id}'),
          viewModel: item,
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({super.key, required this.viewModel});

  final CalendarEventViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TimeColumn(
              timeLabel: viewModel.timeLabel,
              originalTimeLabel: viewModel.originalTimeLabel,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    viewModel.drugName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.dose}  •  ${viewModel.instruction}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (viewModel.detailLine.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      viewModel.detailLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: viewModel.event.status),
          ],
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.timeLabel,
    required this.originalTimeLabel,
  });

  final String timeLabel;
  final String? originalTimeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          timeLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (originalTimeLabel != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            'was $originalTimeLabel',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground, String label}) style =
        _resolveStyle(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        style.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: style.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  ({Color background, Color foreground, String label}) _resolveStyle(
    BuildContext context,
  ) {
    switch (status) {
      case 'done':
        return (
          background: const Color(0xFFD7F5DD),
          foreground: const Color(0xFF1B7A2E),
          label: 'Done',
        );
      case 'skipped':
        return (
          background: const Color(0xFFFDD9D7),
          foreground: const Color(0xFFB3261E),
          label: 'Skipped',
        );
      case 'delayed':
        return (
          background: const Color(0xFFFFF0D6),
          foreground: const Color(0xFFB06D00),
          label: 'Delayed',
        );
      default:
        return (
          background: const Color(0xFFE8E8E8),
          foreground: const Color(0xFF606060),
          label: 'Pending',
        );
    }
  }
}

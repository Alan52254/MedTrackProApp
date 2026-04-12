import 'package:flutter/material.dart';

import '../../../core/models/decision_alert.dart';
import '../application/home_controller.dart';
import '../application/home_state.dart';
import '../domain/home_view_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.controller, this.onDelayNavigateToCalendar});

  final HomeController? controller;

  /// Called after a delay action completes. Receives the target date so that
  /// the app shell can switch to the Calendar tab and auto-select the date.
  final ValueChanged<DateTime>? onDelayNavigateToCalendar;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? HomeController();
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
        final HomeState state = _controller.state;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _TodayHeader(state: state),
            const SizedBox(height: 20),
            _AdherenceSummaryCard(state: state),
            const SizedBox(height: 20),
            _AlertSection(
              alerts: state.visibleAlerts,
              onDismiss: _controller.dismissAlert,
              onAction: _controller.handleAlertAction,
            ),
            const SizedBox(height: 20),
            _NextMedicationCard(
              entry: state.nextMedication,
              onDone: (String eventId) => _controller.markDone(eventId),
              onDelay: _showDelayTimePicker,
              onSkip: _confirmSkip,
            ),
            const SizedBox(height: 20),
            _TimelineSection(entries: state.todayTimeline),
          ],
        );
      },
    );
  }

  Future<void> _showDelayTimePicker(HomeMedicationViewModel entry) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(
      entry.event.scheduledStart.add(const Duration(minutes: 30)),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Delay ${entry.prescription.drugName} to…',
    );

    if (picked == null || !mounted) {
      return;
    }

    // Build the target DateTime. If the picked time is earlier than the
    // current scheduledStart, assume the user means tomorrow.
    DateTime targetTime = DateTime(
      entry.event.scheduledStart.year,
      entry.event.scheduledStart.month,
      entry.event.scheduledStart.day,
      picked.hour,
      picked.minute,
    );
    if (!targetTime.isAfter(entry.event.scheduledStart)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final DateTime? targetDate = _controller.delayEventToTime(
      entry.event.id,
      targetTime,
    );

    if (targetDate != null) {
      widget.onDelayNavigateToCalendar?.call(targetDate);
    }
  }

  Future<void> _confirmSkip(HomeMedicationViewModel entry) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skip this dose?'),
          content: Text(
            'Mark ${entry.prescription.drugName} as skipped for today. '
            'This local demo will update the card state and raise a schedule impact alert.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Skip dose'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      _controller.skipEvent(entry.event.id);
    }
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final String firstName = state.patientProfile.fullName.split(' ').first;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Today',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Today\'s Medications',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '${_formatLongDate(state.referenceDate)} - $firstName\'s local demo flow',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _HeaderBadge(
              icon: Icons.badge_rounded,
              label: state.patientProfile.patientCode,
            ),
            _HeaderBadge(
              icon: Icons.notifications_active_rounded,
              label: '${state.visibleAlerts.length} active alerts',
            ),
            _HeaderBadge(
              icon: Icons.today_rounded,
              label: '${state.todayTimeline.length} doses scheduled today',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AdherenceSummaryCard extends StatelessWidget {
  const _AdherenceSummaryCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '7-Day Adherence Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${state.adherencePercent}%',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${state.completedDoseCount} completed - ${state.skippedDoseCount} skipped',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: state.adherenceProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This sample summary updates as today\'s dose statuses move between done and skipped.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  const _AlertSection({
    required this.alerts,
    required this.onDismiss,
    required this.onAction,
  });

  final List<DecisionAlert> alerts;
  final ValueChanged<String> onDismiss;
  final void Function(String alertId, String actionLabel) onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Alerts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No active alerts right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...alerts.map(
            (DecisionAlert alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertCard(
                alert: alert,
                onDismiss: onDismiss,
                onAction: onAction,
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onDismiss,
    required this.onAction,
  });

  final DecisionAlert alert;
  final ValueChanged<String> onDismiss;
  final void Function(String alertId, String actionLabel) onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _SeverityStyle severityStyle = _severityFor(
      alert.severity,
      colorScheme,
    );

    return Card(
      key: Key('alert-${alert.id}'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: severityStyle.foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  key: Key('dismiss-alert-${alert.id}'),
                  onPressed: () => onDismiss(alert.id),
                  tooltip: 'Dismiss alert',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              alert.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              alert.recommendation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (alert.actionButtons.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alert.actionButtons
                    .map(
                      (String actionLabel) => TextButton(
                        onPressed: () => onAction(alert.id, actionLabel),
                        child: Text(actionLabel),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NextMedicationCard extends StatelessWidget {
  const _NextMedicationCard({
    required this.entry,
    required this.onDone,
    required this.onDelay,
    required this.onSkip,
  });

  final HomeMedicationViewModel? entry;
  final ValueChanged<String> onDone;
  final ValueChanged<HomeMedicationViewModel> onDelay;
  final ValueChanged<HomeMedicationViewModel> onSkip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: entry == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Next Medication',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All caught up for today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No more actionable doses remain in the local sample timeline.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Next Medication',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              key: const Key('next-medication-drug'),
                              entry!.prescription.drugName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatTime(entry!.event.scheduledStart)} - ${entry!.doseLine}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry!.instructionLine,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry!.detailLine,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (entry!.event.originalStart != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                'Original time: ${_formatTime(entry!.event.originalStart!)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusChip(
                        key: const Key('next-medication-status'),
                        status: entry!.event.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      FilledButton(
                        key: const Key('home-action-done'),
                        onPressed: () => onDone(entry!.event.id),
                        child: const Text('Done'),
                      ),
                      FilledButton.tonal(
                        key: const Key('home-action-delay'),
                        onPressed: () => onDelay(entry!),
                        child: const Text('Delay'),
                      ),
                      OutlinedButton(
                        key: const Key('home-action-skip'),
                        onPressed: () => onSkip(entry!),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.entries});

  final List<HomeMedicationViewModel> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Today Timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...entries.map(
          (HomeMedicationViewModel entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TimelineCard(entry: entry),
          ),
        ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entry});

  final HomeMedicationViewModel entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.prescription.drugName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatTime(entry.event.scheduledStart)} - ${entry.doseLine}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.instructionLine,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (entry.event.originalStart != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          'Original: ${_formatTime(entry.event.originalStart!)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  key: Key('timeline-status-${entry.event.id}'),
                  status: entry.event.status,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final _SeverityStyle style = _statusStyle(
      status,
      Theme.of(context).colorScheme,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: style.foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}



class _SeverityStyle {
  const _SeverityStyle({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}



String _formatLongDate(DateTime value) {
  const List<String> weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[value.weekday - 1]}, ${months[value.month - 1]} ${value.day}';
}

String _formatTime(DateTime value) {
  final int normalizedHour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String meridiem = value.hour >= 12 ? 'PM' : 'AM';
  return '$normalizedHour:$minute $meridiem';
}

String _statusLabel(String status) {
  switch (status) {
    case 'done':
      return 'Done';
    case 'delayed':
      return 'Delayed';
    case 'skipped':
      return 'Skipped';
    default:
      return 'Pending';
  }
}

_SeverityStyle _severityFor(String severity, ColorScheme colorScheme) {
  switch (severity) {
    case 'critical':
      return _SeverityStyle(
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      );
    case 'warning':
      return _SeverityStyle(
        backgroundColor: const Color(0xFFFFE8B2),
        foregroundColor: const Color(0xFF7A4B00),
      );
    default:
      return _SeverityStyle(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      );
  }
}

_SeverityStyle _statusStyle(String status, ColorScheme colorScheme) {
  switch (status) {
    case 'done':
      return _SeverityStyle(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      );
    case 'delayed':
      return const _SeverityStyle(
        backgroundColor: Color(0xFFFFE8B2),
        foregroundColor: Color(0xFF7A4B00),
      );
    case 'skipped':
      return _SeverityStyle(
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      );
    default:
      return _SeverityStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
      );
  }
}

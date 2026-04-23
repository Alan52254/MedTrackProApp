import 'package:flutter/material.dart';

import '../application/home_controller.dart';
import '../application/home_state.dart';
import '../domain/home_view_models.dart';
import 'widgets/home_reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.controller,
    this.onDelayNavigateToCalendar,
  });

  final HomeController? controller;
  final ValueChanged<DateTime>? onDelayNavigateToCalendar;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final bool _ownsController;
  bool _isDelaySheetOpen = false;

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
        final HomeReminderViewModel? activeReminder = state.activeReminder;
        final bool shouldShowReminder =
            activeReminder != null && !_isDelaySheetOpen;
        final HomeReminderViewModel? reminder = shouldShowReminder
            ? activeReminder
            : null;

        return Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                shouldShowReminder ? 260 : 24,
              ),
              children: <Widget>[
                _TodayHeader(state: state),
                const SizedBox(height: 20),
                _NextMedicationCard(
                  entry: state.nextMedication,
                  onDone: (String eventId) => _controller.markDone(eventId),
                  onDelay: _showDelayOptions,
                  onSkip: (HomeMedicationViewModel entry) =>
                      _controller.skipEvent(entry.event.id),
                ),
                if (state.scheduleAdjustmentMessage.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    state.scheduleAdjustmentMessage,
                    key: const Key('schedule-adjusted-banner'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _TimelineSection(entries: state.todayTimeline),
              ],
            ),
            if (reminder != null)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HomeReminderCard(
                    reminder: reminder,
                    reminderIntervalMinutes:
                        _controller.reminderIntervalMinutes,
                    onDone: () => _controller.markDone(reminder.entry.event.id),
                    onRemindLater: () =>
                        _controller.snoozeReminder(reminder.entry.event.id),
                    onSkip: () =>
                        _controller.skipEvent(reminder.entry.event.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showDelayOptions(HomeMedicationViewModel entry) async {
    if (_isDelaySheetOpen) {
      return;
    }

    setState(() {
      _isDelaySheetOpen = true;
    });

    try {
      final Duration? selectedDelay = await showModalBottomSheet<Duration>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  key: const Key('home-delay-option-15'),
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Delay +15 minutes'),
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(minutes: 15)),
                ),
                ListTile(
                  key: const Key('home-delay-option-30'),
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Delay +30 minutes'),
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(minutes: 30)),
                ),
                ListTile(
                  key: const Key('home-delay-option-60'),
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Delay +1 hour'),
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(hours: 1)),
                ),
              ],
            ),
          );
        },
      );

      if (!mounted || selectedDelay == null) {
        return;
      }
      _controller.delayEvent(entry.event.id, selectedDelay);
    } finally {
      if (mounted) {
        setState(() {
          _isDelaySheetOpen = false;
        });
      } else {
        _isDelaySheetOpen = false;
      }
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
        const SizedBox(height: 10),
        Text(
          '${_formatLongDate(state.referenceDate)} - $firstName',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _HeaderBadge(
              icon: Icons.badge_rounded,
              label: state.patientProfile.patientCode,
            ),
            _HeaderBadge(
              icon: Icons.medication_liquid_rounded,
              label: '${state.pendingCount} pending today',
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                    'No more medications need attention right now.',
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          key: const Key('next-medication-drug'),
                          entry!.prescription.drugName,
                          style: Theme.of(context).textTheme.headlineSmall,
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
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
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
        Text(
          'Today\'s Medications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
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
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusChip(statusLabel: entry.timelineStatusLabel),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statusLabel});

  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor = colorScheme.surfaceContainerHighest;
    Color foregroundColor = colorScheme.onSurfaceVariant;

    switch (statusLabel) {
      case 'Done':
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case 'Delayed':
        backgroundColor = const Color(0xFFFFE8B2);
        foregroundColor = const Color(0xFF7A4B00);
        break;
      case 'Skipped':
      case 'Reschedule':
        backgroundColor = colorScheme.errorContainer;
        foregroundColor = colorScheme.onErrorContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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

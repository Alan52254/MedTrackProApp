import 'package:flutter/material.dart';

import '../../../core/models/google_calendar_activity.dart';
import '../application/google_calendar_controller.dart';
import '../application/google_calendar_state.dart';

class GoogleCalendarScreen extends StatefulWidget {
  const GoogleCalendarScreen({super.key, required this.controller});

  final GoogleCalendarController controller;

  @override
  State<GoogleCalendarScreen> createState() => _GoogleCalendarScreenState();
}

class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.controller.state.formTitle,
    );
    widget.controller.addListener(_syncTitleController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTitleController);
    _titleController.dispose();
    super.dispose();
  }

  void _syncTitleController() {
    final String value = widget.controller.state.formTitle;
    if (_titleController.text != value) {
      _titleController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final GoogleCalendarState state = widget.controller.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Google Calendar')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _ConnectionCard(
                state: state,
                onConnect: widget.controller.connectGoogle,
                onDisconnect: widget.controller.disconnectGoogle,
              ),
              const SizedBox(height: 20),
              _CreateActivityCard(
                state: state,
                titleController: _titleController,
                onTitleChanged: widget.controller.updateFormTitle,
                onStartTimeTap: () => _pickDateTime(
                  state.formStartTime,
                  widget.controller.updateFormStartTime,
                ),
                onEndTimeTap: () => _pickDateTime(
                  state.formEndTime,
                  widget.controller.updateFormEndTime,
                ),
                onReset: widget.controller.resetForm,
                onCreate: widget.controller.createActivity,
              ),
              const SizedBox(height: 20),
              _ActivityListSection(activities: state.activities),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDateTime(
    DateTime currentValue,
    ValueChanged<DateTime> onSelected,
  ) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: currentValue,
      firstDate: DateTime(currentValue.year - 1),
      lastDate: DateTime(currentValue.year + 2),
    );

    if (date == null || !mounted) {
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
    );

    if (time == null || !mounted) {
      return;
    }

    onSelected(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
  });

  final GoogleCalendarState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ({
      String title,
      String description,
      IconData icon,
      Color bg,
      Color fg,
    })
    statusStyle = _statusStyle(state, colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(statusStyle.icon, color: statusStyle.fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusStyle.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusStyle.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                statusStyle.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: statusStyle.fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (state.isConnected) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Connected as ${state.userEmail}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('gcal-disconnect-button'),
                onPressed: onDisconnect,
                child: const Text('Disconnect'),
              ),
            ] else ...<Widget>[
              if (state.connectionError.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  state.connectionError,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('gcal-connect-button'),
                onPressed:
                    state.connectionState ==
                        GoogleCalendarConnectionState.connecting
                    ? null
                    : onConnect,
                icon: Icon(
                  state.connectionState ==
                          GoogleCalendarConnectionState.configurationRequired
                      ? Icons.build_circle_outlined
                      : Icons.login_rounded,
                ),
                label: Text(
                  state.connectionState ==
                          GoogleCalendarConnectionState.configurationRequired
                      ? 'Try Connect Again'
                      : state.connectionState ==
                            GoogleCalendarConnectionState.connecting
                      ? 'Connecting...'
                      : 'Connect Google',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ({String title, String description, IconData icon, Color bg, Color fg})
  _statusStyle(GoogleCalendarState state, ColorScheme colorScheme) {
    switch (state.connectionState) {
      case GoogleCalendarConnectionState.connected:
        return (
          title: 'Connected to Google Calendar',
          description:
              'Events created here will be written to your Google Calendar.',
          icon: Icons.cloud_done_rounded,
          bg: const Color(0xFFD7F5DD),
          fg: const Color(0xFF1B7A2E),
        );
      case GoogleCalendarConnectionState.connecting:
        return (
          title: 'Connecting to Google Calendar',
          description:
              'Sign-in is in progress. If it cannot complete, the app will remain in demo mode.',
          icon: Icons.sync_rounded,
          bg: colorScheme.primaryContainer,
          fg: colorScheme.onPrimaryContainer,
        );
      case GoogleCalendarConnectionState.configurationRequired:
        return (
          title: 'Google Calendar setup required',
          description:
              'OAuth credentials are missing or invalid for this build. Activities can still be created locally in demo mode.',
          icon: Icons.build_circle_outlined,
          bg: const Color(0xFFFFF0D6),
          fg: const Color(0xFFB06D00),
        );
      case GoogleCalendarConnectionState.connectionFailed:
        return (
          title: 'Connection unavailable',
          description:
              'Google Calendar could not be connected right now. You can continue in demo mode.',
          icon: Icons.cloud_off_rounded,
          bg: const Color(0xFFFDD9D7),
          fg: const Color(0xFFB3261E),
        );
      case GoogleCalendarConnectionState.demoMode:
        return (
          title: 'Demo mode',
          description:
              'Google Calendar is optional. You can still create activities locally for the demo.',
          icon: Icons.event_note_rounded,
          bg: colorScheme.surfaceContainerHighest,
          fg: colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _CreateActivityCard extends StatelessWidget {
  const _CreateActivityCard({
    required this.state,
    required this.titleController,
    required this.onTitleChanged,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onReset,
    required this.onCreate,
  });

  final GoogleCalendarState state;
  final TextEditingController titleController;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final VoidCallback onReset;
  final VoidCallback onCreate;

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
              'Create Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('gcal-activity-title-field'),
              controller: titleController,
              onChanged: onTitleChanged,
              decoration: const InputDecoration(
                labelText: 'Activity title',
                hintText: 'Enter activity title',
              ),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Start time',
              value: _formatDateTime(state.formStartTime),
              fieldKey: const Key('gcal-start-time-field'),
              onTap: onStartTimeTap,
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'End time',
              value: _formatDateTime(state.formEndTime),
              fieldKey: const Key('gcal-end-time-field'),
              onTap: onEndTimeTap,
            ),
            const SizedBox(height: 12),
            Text(
              state.isConnected
                  ? 'Connected mode: create an activity and write it to Google Calendar.'
                  : state.configurationNeeded
                  ? 'Configuration is still needed for sync, but this form will save locally for the demo.'
                  : 'Demo mode: activities will be saved locally until Google Calendar is connected.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (state.syncMessage.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.syncState == GoogleCalendarSyncState.syncFailed
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.syncMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: state.syncState == GoogleCalendarSyncState.syncFailed
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const Key('gcal-reset-button'),
                    onPressed: onReset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('gcal-create-button'),
                    onPressed: state.isSyncing ? null : onCreate,
                    child: state.isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            state.isConnected
                                ? 'Create & Sync'
                                : 'Save Locally',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.fieldKey,
    required this.onTap,
  });

  final String label;
  final String value;
  final Key fieldKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: fieldKey,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.edit_calendar_rounded),
        ),
        child: Text(value),
      ),
    );
  }
}

class _ActivityListSection extends StatelessWidget {
  const _ActivityListSection({required this.activities});

  final List<GoogleCalendarActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Activities', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No activities created yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...activities.reversed.map(
            (GoogleCalendarActivity activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityCard(activity: activity),
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final GoogleCalendarActivity activity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ({Color bg, Color fg, String label}) syncStyle = _syncStyle(
      activity.syncStatus,
      colorScheme,
    );

    return Card(
      key: Key('gcal-activity-${activity.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDateTime(activity.startTime)} - ${_formatDateTime(activity.endTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: syncStyle.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                syncStyle.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: syncStyle.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color bg, Color fg, String label}) _syncStyle(
    String status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'synced':
        return (
          bg: const Color(0xFFD7F5DD),
          fg: const Color(0xFF1B7A2E),
          label: 'Synced',
        );
      case 'error':
        return (
          bg: const Color(0xFFFDD9D7),
          fg: const Color(0xFFB3261E),
          label: 'Sync failed',
        );
      default:
        return (
          bg: const Color(0xFFE8E8E8),
          fg: const Color(0xFF606060),
          label: 'Local only',
        );
    }
  }
}

String _formatDateTime(DateTime dt) {
  final String date =
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  final int h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final String m = dt.minute.toString().padLeft(2, '0');
  final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$date $h:$m $ampm';
}

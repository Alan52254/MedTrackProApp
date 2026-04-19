import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.onGoogleCalendarTap});

  final VoidCallback? onGoogleCalendarTap;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text('Calendar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Calendar now focuses on Google Calendar activities. Medication event timing stays on the Home tab.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Google Calendar integration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Create activities, keep local demo records, and optionally sync them to Google Calendar when credentials are configured.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('calendar-gcal-button'),
                  onPressed: widget.onGoogleCalendarTap,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Google Calendar'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Medication timeline moved',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Use Home for today\'s medication schedule, Done / Delay / Skip actions, and adherence tracking.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

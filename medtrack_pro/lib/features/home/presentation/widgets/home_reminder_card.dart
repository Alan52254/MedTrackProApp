import 'package:flutter/material.dart';

import '../../domain/home_view_models.dart';

class HomeReminderCard extends StatefulWidget {
  const HomeReminderCard({
    super.key,
    required this.reminder,
    required this.reminderIntervalMinutes,
    required this.onDone,
    required this.onRemindLater,
    required this.onSkip,
  });

  final HomeReminderViewModel reminder;
  final int reminderIntervalMinutes;
  final VoidCallback onDone;
  final VoidCallback onRemindLater;
  final VoidCallback onSkip;

  @override
  State<HomeReminderCard> createState() => _HomeReminderCardState();
}

class _HomeReminderCardState extends State<HomeReminderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final HomeMedicationViewModel entry = widget.reminder.entry;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Material(
          elevation: 18,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            key: const Key('home-reminder-card'),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF1E9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1B37A), width: 1.2),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFD7C2),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFB54800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Medication Reminder',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.reminderText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _InfoChip(
                      icon: Icons.medication_rounded,
                      label: entry.prescription.drugName,
                    ),
                    _InfoChip(
                      icon: Icons.opacity_rounded,
                      label: entry.doseLine,
                    ),
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: entry.scheduledTimeLabel,
                    ),
                  ],
                ),
                if (widget.reminder.isUrgent) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'Reminder repeated. Consider confirming this dose soon.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB54800),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        key: const Key('reminder-sheet-done'),
                        onPressed: widget.onDone,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD65A31),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonal(
                        key: const Key('reminder-sheet-snooze'),
                        onPressed: widget.onRemindLater,
                        child: const Text('Remind me later'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        key: const Key('reminder-sheet-skip'),
                        onPressed: widget.onSkip,
                        child: const Text('Skip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFFB54800)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

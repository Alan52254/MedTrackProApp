import 'package:flutter/material.dart';

import '../core/services/reminder_service.dart';
import 'shell/app_shell.dart';
import 'theme/app_theme.dart';

class MedTrackProApp extends StatelessWidget {
  const MedTrackProApp({super.key, this.reminderService});

  final ReminderService? reminderService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(reminderService: reminderService),
    );
  }
}

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification plugin for persistent reminders.
  final ReminderService reminderService = ReminderService();
  await reminderService.init();

  runApp(MedTrackProApp(reminderService: reminderService));
}

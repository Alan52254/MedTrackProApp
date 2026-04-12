import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medtrack_pro/app/app.dart';
import 'package:medtrack_pro/core/services/local_demo_store.dart';
import 'package:medtrack_pro/features/calendar/application/calendar_controller.dart';
import 'package:medtrack_pro/features/calendar/presentation/calendar_screen.dart';
import 'package:medtrack_pro/features/home/application/home_controller.dart';
import 'package:medtrack_pro/features/profile/application/profile_controller.dart';
import 'package:medtrack_pro/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('app shell switches between primary tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MedTrackProApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Today\'s Medications'), findsOneWidget);

    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsWidgets);

    await tester.tap(find.text('Meds').last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('prescription-card-rx-metformin')),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Basic Information'), findsOneWidget);
  });

  testWidgets(
    'calendar shows events for today and updates on date selection',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final CalendarController calendarController = CalendarController(
        store: store,
      );
      final HomeController homeController = HomeController(store: store);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(controller: calendarController),
          ),
        ),
      );

      // Today's events should be visible (seed data has events for today).
      expect(
        find.byKey(const Key('calendar-event-list')),
        findsOneWidget,
      );
      // Omeprazole is scheduled today and active.
      expect(find.text('Omeprazole'), findsOneWidget);

      // The date strip should be present with today highlighted.
      final DateTime today = DateTime.now();
      final Finder todayChip = find.byKey(
        Key('calendar-date-${today.month}-${today.day}'),
      );
      expect(todayChip, findsOneWidget);

      // Tap a date 3 days ago — should have one event (Atorvastatin).
      final DateTime threeDaysAgo = today.subtract(const Duration(days: 3));
      final Finder pastChip = find.byKey(
        Key('calendar-date-${threeDaysAgo.month}-${threeDaysAgo.day}'),
      );
      await tester.tap(pastChip);
      await tester.pumpAndSettle();
      expect(find.text('Atorvastatin'), findsOneWidget);

      // Navigate back to today first (today is still visible in the strip
      // centered on threeDaysAgo, since the strip shows [-3..+3]).
      await tester.tap(todayChip);
      await tester.pumpAndSettle();

      // Now the strip is re-centred on today. Tap a future date.
      final DateTime futureDate = today.add(const Duration(days: 3));
      final Finder futureChip = find.byKey(
        Key('calendar-date-${futureDate.month}-${futureDate.day}'),
      );
      await tester.tap(futureChip);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('calendar-empty-state')),
        findsOneWidget,
      );
      expect(find.text('No medications scheduled'), findsOneWidget);

      // Mark an event done via Home controller and verify calendar updates.
      calendarController.selectDate(today);
      await tester.pumpAndSettle();
      homeController.markDone('evt-008');
      await tester.pumpAndSettle();
      // The event card should now show 'Done' status.
      expect(find.text('Done'), findsWidgets);

      calendarController.dispose();
      homeController.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'delayEventToTime updates event and Calendar centers on delayed date',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final HomeController homeController = HomeController(store: store);
      final CalendarController calendarController = CalendarController(
        store: store,
      );

      // Delay event evt-008 (Metformin at 12:30 today) to tomorrow 14:00.
      final DateTime today = DateTime.now();
      final DateTime tomorrow = DateTime(
        today.year,
        today.month,
        today.day + 1,
        14,
        0,
      );

      final DateTime? targetDate = homeController.delayEventToTime(
        'evt-008',
        tomorrow,
      );

      // Should return the normalised date for tomorrow.
      expect(targetDate, isNotNull);
      expect(targetDate!.year, tomorrow.year);
      expect(targetDate.month, tomorrow.month);
      expect(targetDate.day, tomorrow.day);

      // The event should now be delayed with originalStart preserved.
      final event = store.medicationEvents.firstWhere(
        (e) => e.id == 'evt-008',
      );
      expect(event.status, 'delayed');
      expect(event.scheduledStart.hour, 14);
      expect(event.scheduledStart.minute, 0);
      expect(event.originalStart, isNotNull);

      // A schedule impact alert should be present.
      expect(store.alerts.any((a) => a.id == 'schedule-impact'), isTrue);

      // Select the target date in calendar and verify it shows the event.
      calendarController.selectDate(targetDate);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(controller: calendarController),
          ),
        ),
      );

      // The date strip should now be centred on tomorrow, not today.
      final Finder tomorrowChip = find.byKey(
        Key('calendar-date-${tomorrow.month}-${tomorrow.day}'),
      );
      expect(tomorrowChip, findsOneWidget);

      // The delayed Metformin event at 14:00 should appear.
      expect(find.text('Metformin XR'), findsOneWidget);
      expect(find.text('Delayed'), findsOneWidget);

      calendarController.dispose();
      homeController.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'home local sample flow updates actions and schedule impact alert',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MedTrackProApp());

      final Finder nextMedicationDrug = find.byKey(
        const Key('next-medication-drug'),
      );
      final Finder nextMedicationStatus = find.byKey(
        const Key('next-medication-status'),
      );
      final Finder primaryScrollable = find.byType(Scrollable).first;

      expect(find.text('7-Day Adherence Summary'), findsOneWidget);

      await tester.dragUntilVisible(
        find.byKey(const Key('home-action-delay')),
        primaryScrollable,
        const Offset(0, -300),
      );

      expect(tester.widget<Text>(nextMedicationDrug).data, 'Metformin XR');
      expect(
        find.descendant(
          of: nextMedicationStatus,
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );

      await tester.dragUntilVisible(
        find.text('Today Timeline'),
        primaryScrollable,
        const Offset(0, -300),
      );
      expect(find.text('Today Timeline'), findsOneWidget);
      await tester.dragUntilVisible(
        find.byKey(const Key('home-action-delay')),
        primaryScrollable,
        const Offset(0, 300),
      );

      // Tap Delay — the time picker dialog should appear.
      await tester.tap(find.byKey(const Key('home-action-delay')));
      await tester.pumpAndSettle();
      // The time picker shows an "OK" and "Cancel" button.
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Dismiss the picker — we verify the delay logic via Done/Skip below.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Status should still be Pending since we cancelled.
      expect(
        find.descendant(
          of: nextMedicationStatus,
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('home-action-done')));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(nextMedicationDrug).data, 'Atorvastatin');

      await tester.tap(find.byKey(const Key('home-action-skip')));
      await tester.pumpAndSettle();
      expect(find.text('Skip this dose?'), findsOneWidget);

      await tester.tap(find.text('Skip dose'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('alert-schedule-impact')), findsOneWidget);
      expect(find.text('All caught up for today'), findsOneWidget);
    },
  );

  testWidgets(
    'meds active toggle hides inactive prescriptions from Home timeline',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MedTrackProApp());

      final Finder nextMedicationDrug = find.byKey(
        const Key('next-medication-drug'),
      );

      await tester.dragUntilVisible(
        find.byKey(const Key('home-action-delay')),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      expect(tester.widget<Text>(nextMedicationDrug).data, 'Metformin XR');

      await tester.tap(find.text('Meds').last);
      await tester.pumpAndSettle();

      final Finder medsScrollable = find.byType(Scrollable).first;

      await tester.dragUntilVisible(
        find.byKey(const Key('prescription-card-rx-vitamin-d')),
        medsScrollable,
        const Offset(0, -300),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('prescription-card-rx-vitamin-d')),
          matching: find.text('Inactive'),
        ),
        findsOneWidget,
      );

      await tester.dragUntilVisible(
        find.byKey(const Key('prescription-toggle-rx-metformin')),
        medsScrollable,
        const Offset(0, 300),
      );
      await tester.ensureVisible(
        find.byKey(const Key('prescription-toggle-rx-metformin')),
      );
      await tester.pumpAndSettle();

      final Finder metforminToggle = find.byKey(
        const Key('prescription-toggle-rx-metformin'),
      );

      await tester.tap(metforminToggle, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(metforminToggle).value, isFalse);
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('prescription-status-rx-metformin')),
            )
            .data,
        'Hidden from Home today',
      );

      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('home-action-delay')),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );

      expect(tester.widget<Text>(nextMedicationDrug).data, 'Atorvastatin');
      expect(find.text('Metformin XR'), findsNothing);
    },
  );

  testWidgets(
    'profile saves to shared local store and reset restores saved values',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final ProfileController profileController = ProfileController(
        store: store,
      );
      final HomeController homeController = HomeController(store: store);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProfileScreen(controller: profileController)),
        ),
      );

      final Finder fullNameField = find.byKey(
        const Key('profile-full-name-field'),
      );
      final Finder patientCodeField = find.byKey(
        const Key('profile-patient-code-field'),
      );
      final Finder profileScrollable = find.byType(Scrollable).first;

      expect(find.text('Basic Information'), findsOneWidget);

      await tester.enterText(fullNameField, 'Jamie Lin');
      await tester.enterText(patientCodeField, 'MTP-99999');
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-has-caregiver-switch')),
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('profile-has-caregiver-switch')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('profile-caregiver-name-field')),
        'Chris Lin',
      );

      profileController.updateWakeTime('07:15');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-wake-time-note')), findsOneWidget);
      expect(find.text('07:15'), findsWidgets);

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-reset-button')),
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('profile-reset-button')));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        fullNameField,
        profileScrollable,
        const Offset(0, 300),
      );
      expect(
        tester.widget<TextField>(fullNameField).controller?.text,
        'Alex Chen',
      );
      expect(
        tester.widget<TextField>(patientCodeField).controller?.text,
        'MTP-24018',
      );
      expect(find.text('06:30'), findsWidgets);
      expect(find.byKey(const Key('profile-wake-time-note')), findsNothing);

      await tester.enterText(fullNameField, 'Jamie Lin');
      await tester.enterText(patientCodeField, 'MTP-99999');
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-save-button')),
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('profile-save-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-save-message')), findsOneWidget);
      expect(find.text('Profile saved locally.'), findsOneWidget);
      expect(store.patientProfile.fullName, 'Jamie Lin');
      expect(store.patientProfile.patientCode, 'MTP-99999');
      expect(homeController.state.patientProfile.fullName, 'Jamie Lin');
      expect(profileController.state.form.fullName, 'Jamie Lin');
      expect(profileController.state.form.patientCode, 'MTP-99999');

      profileController.dispose();
      homeController.dispose();
      store.dispose();
    },
  );
}

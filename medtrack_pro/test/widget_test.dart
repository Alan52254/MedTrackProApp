import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medtrack_pro/app/app.dart';
import 'package:medtrack_pro/core/models/calendar_context_event.dart';
import 'package:medtrack_pro/core/models/decision_alert.dart';
import 'package:medtrack_pro/core/models/medication_event.dart';
import 'package:medtrack_pro/core/models/patient_profile.dart';
import 'package:medtrack_pro/core/models/prescription.dart';
import 'package:medtrack_pro/core/services/google_calendar_service.dart';
import 'package:medtrack_pro/core/services/local_demo_seed.dart';
import 'package:medtrack_pro/core/services/local_demo_store.dart';
import 'package:medtrack_pro/core/services/reminder_service.dart';
import 'package:medtrack_pro/features/calendar/presentation/calendar_screen.dart';
import 'package:medtrack_pro/features/google_calendar_sync/application/google_calendar_controller.dart';
import 'package:medtrack_pro/features/google_calendar_sync/presentation/google_calendar_screen.dart';
import 'package:medtrack_pro/features/home/application/home_controller.dart';
import 'package:medtrack_pro/features/home/application/reminder_controller.dart';
import 'package:medtrack_pro/features/meds/application/meds_controller.dart';
import 'package:medtrack_pro/features/meds/presentation/meds_screen.dart';
import 'package:medtrack_pro/features/profile/application/profile_controller.dart';
import 'package:medtrack_pro/features/profile/presentation/profile_screen.dart';

class _FakeGoogleCalendarService extends GoogleCalendarService {
  _FakeGoogleCalendarService({
    this.signInResult = const GoogleCalendarSignInResult(
      status: GoogleCalendarSignInStatus.configurationRequired,
      message:
          'Google Calendar setup required. OAuth credentials are missing or invalid for this build.',
    ),
    this.createEventResult = const GoogleCalendarCreateEventResult(
      status: GoogleCalendarCreateEventStatus.success,
      message: 'Activity created and synced to Google Calendar.',
      eventId: 'fake-event-id',
    ),
  });

  GoogleCalendarSignInResult signInResult;
  GoogleCalendarCreateEventResult createEventResult;
  bool signedIn = false;
  String fakeEmail = 'demo@example.com';

  @override
  bool get isSignedIn => signedIn;

  @override
  String get userEmail => signedIn ? fakeEmail : '';

  @override
  Future<GoogleCalendarSignInResult> signIn() async {
    signedIn = signInResult.status == GoogleCalendarSignInStatus.success;
    return signedIn
        ? GoogleCalendarSignInResult(
            status: signInResult.status,
            message: signInResult.message,
            userEmail: fakeEmail,
          )
        : signInResult;
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
  }

  @override
  Future<GoogleCalendarCreateEventResult> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
  }) async {
    return createEventResult;
  }
}

class _FakeReminderService extends ReminderService {
  final List<String> shownEventIds = <String>[];
  final List<String> cancelledEventIds = <String>[];
  bool cancelledAll = false;

  @override
  Future<void> showReminder({
    required String eventId,
    required String title,
    required String body,
  }) async {
    shownEventIds.add(eventId);
  }

  @override
  Future<void> cancelReminder(String eventId) async {
    cancelledEventIds.add(eventId);
  }

  @override
  Future<void> cancelAll() async {
    cancelledAll = true;
  }
}

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
    expect(find.byKey(const Key('calendar-gcal-button')), findsOneWidget);

    await tester.tap(find.text('Meds').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Local prescription list for the demo'),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Basic Information'), findsOneWidget);
  });

  testWidgets('calendar screen focuses on Google Calendar entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CalendarScreen(onGoogleCalendarTap: () {})),
      ),
    );

    expect(find.byKey(const Key('calendar-gcal-button')), findsOneWidget);
    expect(find.text('Medication timeline moved'), findsOneWidget);
    expect(find.textContaining('Medication Events'), findsNothing);
  });

  testWidgets(
    'Google Calendar graceful fallback saves activity locally when setup is missing',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final _FakeGoogleCalendarService service = _FakeGoogleCalendarService(
        signInResult: const GoogleCalendarSignInResult(
          status: GoogleCalendarSignInStatus.configurationRequired,
          message:
              'Google Calendar setup required. OAuth credentials are missing or invalid for this build.',
        ),
      );
      final GoogleCalendarController controller = GoogleCalendarController(
        store: store,
        service: service,
      );

      await tester.pumpWidget(
        MaterialApp(home: GoogleCalendarScreen(controller: controller)),
      );

      await tester.tap(find.byKey(const Key('gcal-connect-button')));
      await tester.pumpAndSettle();

      expect(find.text('Google Calendar setup required'), findsOneWidget);
      expect(find.textContaining('Demo mode is active'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('gcal-activity-title-field')),
        'Clinic follow-up',
      );
      await controller.createActivity();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Activity saved locally. Google Calendar setup is still required for sync.',
        ),
        findsOneWidget,
      );
      expect(store.activities, hasLength(1));
      expect(store.activities.single.syncStatus, 'local');

      controller.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'Google Calendar connected path keeps real sync route available',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final _FakeGoogleCalendarService service = _FakeGoogleCalendarService(
        signInResult: const GoogleCalendarSignInResult(
          status: GoogleCalendarSignInStatus.success,
          message: 'Connected to Google Calendar.',
        ),
        createEventResult: const GoogleCalendarCreateEventResult(
          status: GoogleCalendarCreateEventStatus.success,
          message: 'Activity created and synced to Google Calendar.',
          eventId: 'gcal-123',
        ),
      );
      final GoogleCalendarController controller = GoogleCalendarController(
        store: store,
        service: service,
      );

      await tester.pumpWidget(
        MaterialApp(home: GoogleCalendarScreen(controller: controller)),
      );

      await tester.tap(find.byKey(const Key('gcal-connect-button')));
      await tester.pumpAndSettle();

      expect(find.text('Connected to Google Calendar'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('gcal-activity-title-field')),
        'Lab reminder',
      );
      await controller.createActivity();
      await tester.pumpAndSettle();

      expect(
        find.text('Activity created and synced to Google Calendar.'),
        findsOneWidget,
      );
      expect(store.activities.single.googleCalendarEventId, 'gcal-123');
      expect(store.activities.single.syncStatus, 'synced');

      controller.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'reminder controller uses configurable interval from shared local store',
    (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      final PatientProfile profile = PatientProfile(
        id: 'patient-1',
        authUserId: 'local-demo-user',
        fullName: 'Alex Chen',
        gender: 'Male',
        dateOfBirth: DateTime(1989, 6, 18),
        age: 36,
        patientCode: 'MTP-24018',
        occupation: 'Designer',
        comorbidityCount: 0,
        hasComorbidity: false,
        diseaseList: const <String>[],
        hasCaregiver: false,
        allergies: const <String>[],
        diagnoses: const <String>[],
        wakeTime: '06:30',
        breakfastTime: '07:30',
        lunchTime: '12:30',
        dinnerTime: '18:30',
        sleepTime: '22:30',
        caregiverName: '',
        caregiverPhone: '',
        createdAt: now,
        updatedAt: now,
      );
      final Prescription prescription = Prescription(
        id: 'rx-1',
        patientId: profile.id,
        drugName: 'Metformin XR',
        commonFrequency: 'Once daily',
        dose: '500 mg',
        durationDays: 30,
        indication: 'Glucose control',
        drugInteractions: const <String>[],
        note: '',
        administrationType: 'With lunch',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: true,
        source: 'manual',
        imageId: '',
        createdAt: now,
        updatedAt: now,
      );
      final MedicationEvent pendingEvent = MedicationEvent(
        id: 'evt-1',
        patientId: profile.id,
        prescriptionId: prescription.id,
        scheduledStart: now.subtract(const Duration(minutes: 10)),
        scheduledEnd: now.add(const Duration(minutes: 20)),
        actualTakenAt: null,
        status: 'pending',
        originalStart: null,
        delayMinutes: 0,
        googleCalendarEventId: '',
        syncedToGoogleCalendar: false,
        lastReminderTime: now.subtract(const Duration(minutes: 10)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );

      final LocalDemoStore defaultIntervalStore = LocalDemoStore(
        seedData: LocalDemoSeedData(
          referenceDate: now,
          reminderIntervalMinutes: 30,
          patientProfile: profile,
          prescriptions: <Prescription>[prescription],
          medicationEvents: <MedicationEvent>[pendingEvent],
          calendarContextEvents: const <CalendarContextEvent>[],
          alerts: const <DecisionAlert>[],
        ),
      );
      final _FakeReminderService defaultReminderService =
          _FakeReminderService();
      final ReminderController defaultController = ReminderController(
        store: defaultIntervalStore,
        reminderService: defaultReminderService,
      );

      expect(defaultReminderService.shownEventIds, isEmpty);

      defaultController.dispose();
      defaultIntervalStore.dispose();

      final LocalDemoStore shortIntervalStore = LocalDemoStore(
        seedData: LocalDemoSeedData(
          referenceDate: now,
          reminderIntervalMinutes: 5,
          patientProfile: profile,
          prescriptions: <Prescription>[prescription],
          medicationEvents: <MedicationEvent>[pendingEvent],
          calendarContextEvents: const <CalendarContextEvent>[],
          alerts: const <DecisionAlert>[],
        ),
      );
      final _FakeReminderService shortReminderService = _FakeReminderService();
      final ReminderController shortController = ReminderController(
        store: shortIntervalStore,
        reminderService: shortReminderService,
      );

      expect(shortReminderService.shownEventIds, contains('evt-1'));

      shortController.dispose();
      shortIntervalStore.dispose();
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

      await tester.tap(find.byKey(const Key('home-action-delay')));
      await tester.pumpAndSettle();
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

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
        find.text('Glucose control'),
        medsScrollable,
        const Offset(0, -300),
      );
      expect(find.text('Indication'), findsWidgets);
      expect(find.text('Glucose control'), findsOneWidget);
      expect(find.text('Drug interactions'), findsWidgets);
      expect(find.textContaining('Take with food'), findsOneWidget);
      expect(find.text('Note'), findsWidgets);
      expect(find.text('Take with lunch.'), findsOneWidget);

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
    'add medication flow saves to local store and updates Meds list',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final MedsController medsController = MedsController(store: store);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MedsScreen(controller: medsController)),
        ),
      );

      final int initialCount = store.prescriptions.length;

      await tester.tap(find.byKey(const Key('meds-add-medication-fab')));
      await tester.pumpAndSettle();

      expect(find.text('Add Medication'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('add-med-drug-name-field')),
        'Amoxicillin',
      );
      await tester.enterText(
        find.byKey(const Key('add-med-dose-field')),
        '250 mg',
      );
      await tester.enterText(
        find.byKey(const Key('add-med-duration-field')),
        '10',
      );
      await tester.enterText(
        find.byKey(const Key('add-med-indication-field')),
        'Infection support',
      );
      await tester.enterText(
        find.byKey(const Key('add-med-interactions-field')),
        'Take after meals',
      );
      await tester.enterText(
        find.byKey(const Key('add-med-note-field')),
        'Finish the full course.',
      );

      await tester.dragUntilVisible(
        find.byKey(const Key('add-med-save-button')),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('add-med-save-button')));
      await tester.pumpAndSettle();

      expect(store.prescriptions.length, initialCount + 1);
      expect(
        store.prescriptions.any(
          (prescription) =>
              prescription.drugName == 'Amoxicillin' &&
              prescription.dose == '250 mg',
        ),
        isTrue,
      );
      expect(find.text('Amoxicillin'), findsWidgets);

      medsController.dispose();
      store.dispose();
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
      final Finder ageField = find.byKey(const Key('profile-age-field'));
      final Finder genderField = find.byKey(const Key('profile-gender-field'));
      final Finder comorbidityCountField = find.byKey(
        const Key('profile-comorbidity-count-field'),
      );
      final Finder profileScrollable = find.byType(Scrollable).first;

      expect(find.text('Basic Information'), findsOneWidget);
      expect(genderField, findsOneWidget);
      expect(ageField, findsOneWidget);

      await tester.enterText(fullNameField, 'Jamie Lin');
      await tester.enterText(patientCodeField, 'MTP-99999');
      await tester.enterText(ageField, '41');
      profileController.updateGender('Other');
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        comorbidityCountField,
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.enterText(comorbidityCountField, '3');
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-has-caregiver-switch')),
        profileScrollable,
        const Offset(0, -300),
      );
      profileController.updateHasCaregiver(true);
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-caregiver-name-field')),
        profileScrollable,
        const Offset(0, -300),
      );
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
      await tester.enterText(ageField, '41');
      profileController.updateGender('Other');
      await tester.dragUntilVisible(
        comorbidityCountField,
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.enterText(comorbidityCountField, '3');
      profileController.updateHasCaregiver(true);
      await tester.pumpAndSettle();
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
      expect(store.patientProfile.gender, 'Other');
      expect(store.patientProfile.age, 41);
      expect(store.patientProfile.comorbidityCount, 3);
      expect(store.patientProfile.hasCaregiver, isTrue);
      expect(homeController.state.patientProfile.fullName, 'Jamie Lin');
      expect(profileController.state.form.fullName, 'Jamie Lin');
      expect(profileController.state.form.patientCode, 'MTP-99999');

      profileController.dispose();
      homeController.dispose();
      store.dispose();
    },
  );
}

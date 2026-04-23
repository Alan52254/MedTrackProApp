import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medtrack_pro/app/app.dart';
import 'package:medtrack_pro/core/models/calendar_context_event.dart';
import 'package:medtrack_pro/core/models/decision_alert.dart';
import 'package:medtrack_pro/core/models/google_calendar_activity.dart';
import 'package:medtrack_pro/core/models/medication_event.dart';
import 'package:medtrack_pro/core/models/patient_profile.dart';
import 'package:medtrack_pro/core/models/prescription_ocr_result.dart';
import 'package:medtrack_pro/core/models/prescription.dart';
import 'package:medtrack_pro/core/services/google_calendar_service.dart';
import 'package:medtrack_pro/core/services/local_demo_seed.dart';
import 'package:medtrack_pro/core/services/local_demo_store.dart';
import 'package:medtrack_pro/core/services/prescription_ocr_service.dart';
import 'package:medtrack_pro/core/services/reminder_service.dart';
import 'package:medtrack_pro/features/calendar/presentation/calendar_screen.dart';
import 'package:medtrack_pro/features/google_calendar_sync/application/google_calendar_controller.dart';
import 'package:medtrack_pro/features/google_calendar_sync/presentation/google_calendar_screen.dart';
import 'package:medtrack_pro/features/home/application/home_controller.dart';
import 'package:medtrack_pro/features/home/application/reminder_controller.dart';
import 'package:medtrack_pro/features/home/presentation/home_screen.dart';
import 'package:medtrack_pro/features/meds/application/add_medication_controller.dart';
import 'package:medtrack_pro/features/meds/application/add_medication_state.dart';
import 'package:medtrack_pro/features/meds/application/meds_controller.dart';
import 'package:medtrack_pro/features/meds/presentation/add_medication_screen.dart';
import 'package:medtrack_pro/features/meds/presentation/meds_screen.dart';
import 'package:medtrack_pro/features/profile/application/profile_controller.dart';
import 'package:medtrack_pro/features/profile/presentation/profile_screen.dart';

class _FakeGoogleCalendarService extends GoogleCalendarService {
  _FakeGoogleCalendarService();

  GoogleCalendarSignInResult signInResult = const GoogleCalendarSignInResult(
    status: GoogleCalendarSignInStatus.configurationRequired,
    message:
        'Google Calendar setup required. OAuth credentials are missing or invalid for this build.',
  );
  GoogleCalendarCreateEventResult createEventResult =
      const GoogleCalendarCreateEventResult(
        status: GoogleCalendarCreateEventStatus.success,
        message: 'Activity created and synced to Google Calendar.',
        eventId: 'fake-event-id',
      );
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

class _FakePrescriptionOcrService extends PrescriptionOcrService {
  const _FakePrescriptionOcrService();

  @override
  Future<PrescriptionOcrResult> extractFromImage(String imagePath) async {
    return const PrescriptionOcrResult(
      drugName: 'Lipitor',
      dose: '1 TAB',
      frequency: 'Once daily',
      duration: '30',
      indication: 'Cholesterol management',
      note: 'Do not miss the evening dose.',
      interactionField: 'Avoid large amounts of grapefruit.',
    );
  }
}

class _EmptyPrescriptionOcrService extends PrescriptionOcrService {
  const _EmptyPrescriptionOcrService();

  @override
  Future<PrescriptionOcrResult> extractFromImage(String imagePath) async {
    return const PrescriptionOcrResult();
  }
}

void main() {
  testWidgets('app shell switches between primary tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MedTrackProApp());

    expect(find.text('Today\'s Medications'), findsOneWidget);

    await tester.tap(find.text('Calendar').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('calendar-gcal-button')), findsOneWidget);

    await tester.tap(find.text('Meds').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.textContaining('Local prescription list for the demo'),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile').last);
    await tester.pump(const Duration(milliseconds: 300));
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
      final _FakeGoogleCalendarService service = _FakeGoogleCalendarService();
      final GoogleCalendarController controller = GoogleCalendarController(
        store: store,
        service: service,
      );

      await tester.pumpWidget(
        MaterialApp(home: GoogleCalendarScreen(controller: controller)),
      );

      await tester.tap(find.byKey(const Key('gcal-connect-button')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Google Calendar setup required'), findsOneWidget);
      expect(find.textContaining('Demo mode is active'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('gcal-activity-title-field')),
        'Clinic follow-up',
      );
      await controller.createActivity();
      await tester.pump(const Duration(milliseconds: 300));

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
    'Google Calendar connected state persists when reopening screen with same controller',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final _FakeGoogleCalendarService service = _FakeGoogleCalendarService()
        ..signInResult = const GoogleCalendarSignInResult(
          status: GoogleCalendarSignInStatus.success,
          message: 'Connected to Google Calendar.',
          userEmail: 'demo@example.com',
        );
      final GoogleCalendarController controller = GoogleCalendarController(
        store: store,
        service: service,
      );

      await tester.pumpWidget(
        MaterialApp(home: GoogleCalendarScreen(controller: controller)),
      );
      await tester.tap(find.byKey(const Key('gcal-connect-button')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Connected to Google Calendar'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(home: GoogleCalendarScreen(controller: controller)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Connected to Google Calendar'), findsOneWidget);
      expect(find.textContaining('Connected as'), findsOneWidget);

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
    'home reminder quick postpone uses default interval and keeps advanced delay',
    (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      final PatientProfile profile = PatientProfile(
        id: 'patient-home',
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
        id: 'rx-home',
        patientId: profile.id,
        drugName: 'Lipitor',
        commonFrequency: 'Once daily',
        dose: '1 TAB',
        durationDays: 30,
        indication: 'Cholesterol management',
        drugInteractions: const <String>[],
        note: '',
        administrationType: 'Take in the evening',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: true,
        source: 'manual',
        imageId: '',
        createdAt: now,
        updatedAt: now,
      );
      final MedicationEvent event = MedicationEvent(
        id: 'evt-home',
        patientId: profile.id,
        prescriptionId: prescription.id,
        scheduledStart: now.subtract(const Duration(minutes: 5)),
        scheduledEnd: now.add(const Duration(minutes: 30)),
        actualTakenAt: null,
        status: 'pending',
        originalStart: null,
        delayMinutes: 0,
        googleCalendarEventId: '',
        syncedToGoogleCalendar: false,
        lastReminderTime: null,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );
      final LocalDemoStore store = LocalDemoStore(
        seedData: LocalDemoSeedData(
          referenceDate: now,
          reminderIntervalMinutes: 30,
          patientProfile: profile,
          prescriptions: <Prescription>[prescription],
          medicationEvents: <MedicationEvent>[event],
          calendarContextEvents: const <CalendarContextEvent>[],
          alerts: const <DecisionAlert>[],
        ),
      );
      final HomeController controller = HomeController(store: store);
      final DateTime originalScheduledStart = event.scheduledStart;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeScreen(controller: controller)),
        ),
      );

      expect(find.byKey(const Key('home-reminder-card')), findsOneWidget);
      expect(find.text('7-Day Adherence Summary'), findsNothing);
      expect(find.text('Alerts'), findsNothing);
      expect(find.byKey(const Key('home-action-done')), findsOneWidget);
      expect(find.byKey(const Key('home-action-delay')), findsOneWidget);
      expect(find.byKey(const Key('home-action-skip')), findsOneWidget);
      expect(find.byKey(const Key('reminder-sheet-snooze')), findsOneWidget);
      expect(find.text('Remind me later'), findsOneWidget);

      await tester.tap(find.byKey(const Key('reminder-sheet-snooze')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('home-delay-option-15')), findsNothing);
      expect(find.byKey(const Key('home-delay-option-30')), findsNothing);
      expect(find.byKey(const Key('home-delay-option-60')), findsNothing);
      expect(find.byKey(const Key('home-reminder-card')), findsNothing);
      expect(store.medicationEvents.single.status, 'delayed');
      expect(store.medicationEvents.single.delayMinutes, 30);
      expect(
        store.medicationEvents.single.originalStart,
        originalScheduledStart,
      );
      expect(
        store.medicationEvents.single.scheduledStart,
        originalScheduledStart.add(const Duration(minutes: 30)),
      );

      await tester.tap(find.byKey(const Key('home-action-delay')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-reminder-card')), findsNothing);
      expect(find.byKey(const Key('home-delay-option-15')), findsOneWidget);
      expect(find.byKey(const Key('home-delay-option-30')), findsOneWidget);
      expect(find.byKey(const Key('home-delay-option-60')), findsOneWidget);

      await tester.tap(find.byKey(const Key('home-delay-option-30')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-reminder-card')), findsNothing);
      expect(store.medicationEvents.single.status, 'delayed');
      expect(store.medicationEvents.single.delayMinutes, 60);
      expect(
        store.medicationEvents.single.scheduledStart,
        originalScheduledStart.add(const Duration(minutes: 60)),
      );

      await tester.tap(find.byKey(const Key('home-action-done')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(store.medicationEvents.single.status, 'done');

      controller.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'meds active toggle hides inactive prescriptions from Home timeline',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final HomeController homeController = HomeController(store: store);
      final MedsController medsController = MedsController(store: store);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MedsScreen(controller: medsController)),
        ),
      );
      final Finder medsScrollable = find.byType(Scrollable).first;
      await tester.dragUntilVisible(
        find.byKey(const Key('prescription-toggle-rx-metformin')),
        medsScrollable,
        const Offset(0, -300),
      );

      medsController.setPrescriptionActive('rx-metformin', false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        homeController.state.nextMedication?.prescription.drugName,
        'Atorvastatin',
      );

      medsController.dispose();
      homeController.dispose();
      store.dispose();
    },
  );

  test('manual add medication save works without image or OCR', () {
    final LocalDemoStore store = LocalDemoStore();
    final AddMedicationController controller = AddMedicationController(
      store: store,
    );

    controller.updateDrugName('Amoxicillin');
    controller.updateDose('500 mg');
    controller.updateDurationDays('10');
    controller.save();

    expect(controller.state.isSaved, isTrue);
    expect(
      store.prescriptions.any(
        (Prescription prescription) =>
            prescription.drugName == 'Amoxicillin' &&
            prescription.dose == '500 mg' &&
            prescription.source == 'manual',
      ),
      isTrue,
    );

    controller.dispose();
    store.dispose();
  });

  test('OCR extraction autofills add medication form before save', () async {
    final LocalDemoStore store = LocalDemoStore();
    final AddMedicationController controller = AddMedicationController(
      store: store,
      ocrService: const _FakePrescriptionOcrService(),
    );

    controller.setImage('fake/path.png', 'gallery');
    await controller.extractFromSelectedImage();

    expect(controller.state.form.drugName, 'Lipitor');
    expect(controller.state.flowStatus, AddMedicationFlowStatus.ocrSuccess);
    controller.save();

    expect(
      store.prescriptions.any(
        (Prescription prescription) =>
            prescription.drugName == 'Lipitor' &&
            prescription.source == 'gallery',
      ),
      isTrue,
    );

    controller.dispose();
    store.dispose();
  });

  test('OCR failure stays non-blocking and preserves manual entry', () async {
    final LocalDemoStore store = LocalDemoStore();
    final AddMedicationController controller = AddMedicationController(
      store: store,
      ocrService: const _EmptyPrescriptionOcrService(),
    );

    controller.updateDrugName('Manual fallback');
    controller.updateDose('20 mg');
    controller.setImage('fake/path.png', 'gallery');
    await controller.extractFromSelectedImage();

    expect(controller.state.flowStatus, AddMedicationFlowStatus.ocrFailure);
    expect(controller.state.errorMessage, isNotEmpty);
    controller.save();

    expect(
      store.prescriptions.any(
        (Prescription prescription) =>
            prescription.drugName == 'Manual fallback' &&
            prescription.dose == '20 mg' &&
            prescription.source == 'gallery',
      ),
      isTrue,
    );

    controller.dispose();
    store.dispose();
  });

  testWidgets(
    'Add Medication shows OCR button only after an image is attached',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final AddMedicationController controller = AddMedicationController(
        store: store,
      );

      await tester.pumpWidget(
        MaterialApp(home: AddMedicationScreen(controller: controller)),
      );

      expect(find.byKey(const Key('add-med-run-ocr')), findsNothing);

      controller.setImage('fake/path.png', 'gallery');
      await tester.pump();

      expect(find.byKey(const Key('add-med-run-ocr')), findsOneWidget);
      expect(find.text('Run OCR'), findsOneWidget);

      controller.dispose();
      store.dispose();
    },
  );

  testWidgets(
    'profile reset restores initial seed state and clears local history',
    (WidgetTester tester) async {
      final LocalDemoStore store = LocalDemoStore();
      final ProfileController profileController = ProfileController(
        store: store,
      );
      final int initialPrescriptionCount = store.prescriptions.length;
      final int initialCalendarContextCount =
          store.calendarContextEvents.length;
      final int initialMedicationEventCount = store.medicationEvents.length;
      final int initialReminderInterval = store.reminderIntervalMinutes;

      store.updateReminderIntervalMinutes(15);
      store.updateMedicationEvent(
        store.medicationEvents.first.copyWith(
          status: 'done',
          actualTakenAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      store.upsertCalendarContextEvent(
        CalendarContextEvent(
          id: 'ctx-local-new',
          patientId: store.patientProfile.id,
          date: DateTime.now(),
          startTime: '09:00',
          endTime: '10:00',
          activity: 'Temporary event',
          location: 'Home',
          weather: '',
          fatigueLevel: '',
          source: 'local',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      store.addActivity(
        GoogleCalendarActivity(
          id: 'activity-local-1',
          title: 'Local Activity',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          googleCalendarEventId: '',
          syncStatus: 'local',
          createdAt: DateTime.now(),
        ),
      );

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
      final Finder profileScrollable = find.byType(Scrollable).first;

      await tester.enterText(fullNameField, 'Jamie Lin');
      await tester.enterText(patientCodeField, 'MTP-99999');
      await tester.enterText(ageField, '41');
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-reset-button')),
        profileScrollable,
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('profile-reset-button')));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.dragUntilVisible(
        fullNameField,
        profileScrollable,
        const Offset(0, 300),
      );
      expect(
        tester.widget<TextField>(fullNameField).controller?.text,
        'Alex Chen',
      );
      expect(store.reminderIntervalMinutes, initialReminderInterval);
      expect(store.activities, isEmpty);
      expect(store.prescriptions.length, initialPrescriptionCount);
      expect(store.medicationEvents.length, initialMedicationEventCount);
      expect(store.calendarContextEvents.length, initialCalendarContextCount);

      profileController.dispose();
      store.dispose();
    },
  );
}

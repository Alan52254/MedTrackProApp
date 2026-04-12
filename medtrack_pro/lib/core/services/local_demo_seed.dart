import '../models/decision_alert.dart';
import '../models/medication_event.dart';
import '../models/patient_profile.dart';
import '../models/prescription.dart';

class LocalDemoSeedData {
  const LocalDemoSeedData({
    required this.referenceDate,
    required this.patientProfile,
    required this.prescriptions,
    required this.medicationEvents,
    required this.alerts,
  });

  final DateTime referenceDate;
  final PatientProfile patientProfile;
  final List<Prescription> prescriptions;
  final List<MedicationEvent> medicationEvents;
  final List<DecisionAlert> alerts;
}

class LocalDemoSeed {
  const LocalDemoSeed._();

  static LocalDemoSeedData build() {
    final DateTime referenceDate = DateTime.now();
    final DateTime startOfToday = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final PatientProfile patientProfile = PatientProfile(
      id: 'patient-001',
      authUserId: 'local-demo-user',
      fullName: 'Alex Chen',
      gender: 'Male',
      dateOfBirth: DateTime(1989, 6, 18),
      age: 36,
      patientCode: 'MTP-24018',
      occupation: 'Product Designer',
      comorbidityCount: 1,
      hasComorbidity: true,
      diseaseList: const <String>['Type 2 Diabetes'],
      hasCaregiver: false,
      allergies: const <String>['Penicillin'],
      diagnoses: const <String>['Type 2 Diabetes'],
      wakeTime: '06:30',
      breakfastTime: '07:30',
      lunchTime: '12:30',
      dinnerTime: '18:30',
      sleepTime: '22:30',
      caregiverName: '',
      caregiverPhone: '',
      createdAt: startOfToday.subtract(const Duration(days: 90)),
      updatedAt: startOfToday.subtract(const Duration(days: 2)),
    );

    final List<Prescription> prescriptions = <Prescription>[
      Prescription(
        id: 'rx-omeprazole',
        patientId: patientProfile.id,
        drugName: 'Omeprazole',
        commonFrequency: 'Once daily',
        dose: '20 mg',
        durationDays: 30,
        indication: 'Gastroprotection',
        drugInteractions: const <String>[
          'Separate from magnesium supplements when possible.',
        ],
        note: 'Take with water before breakfast.',
        administrationType: 'Before breakfast',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: true,
        source: 'manual',
        imageId: '',
        createdAt: startOfToday.subtract(const Duration(days: 30)),
        updatedAt: startOfToday.subtract(const Duration(days: 2)),
      ),
      Prescription(
        id: 'rx-metformin',
        patientId: patientProfile.id,
        drugName: 'Metformin XR',
        commonFrequency: 'Once daily',
        dose: '500 mg',
        durationDays: 30,
        indication: 'Glucose control',
        drugInteractions: const <String>[
          'Take with food to reduce stomach upset.',
        ],
        note: 'Take with lunch.',
        administrationType: 'With lunch',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: true,
        source: 'manual',
        imageId: '',
        createdAt: startOfToday.subtract(const Duration(days: 30)),
        updatedAt: startOfToday.subtract(const Duration(days: 2)),
      ),
      Prescription(
        id: 'rx-atorvastatin',
        patientId: patientProfile.id,
        drugName: 'Atorvastatin',
        commonFrequency: 'Once nightly',
        dose: '10 mg',
        durationDays: 30,
        indication: 'Cholesterol management',
        drugInteractions: const <String>['Avoid grapefruit in large amounts.'],
        note: 'Take in the evening.',
        administrationType: 'Bedtime',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: true,
        source: 'manual',
        imageId: '',
        createdAt: startOfToday.subtract(const Duration(days: 30)),
        updatedAt: startOfToday.subtract(const Duration(days: 2)),
      ),
      Prescription(
        id: 'rx-vitamin-d',
        patientId: patientProfile.id,
        drugName: 'Vitamin D3',
        commonFrequency: 'Once daily',
        dose: '1000 IU',
        durationDays: 30,
        indication: 'Supplement support',
        drugInteractions: const <String>[],
        note: 'Currently paused in the local demo.',
        administrationType: 'With breakfast',
        frequencyType: 'daily',
        frequencyValue: '1',
        active: false,
        source: 'manual',
        imageId: '',
        createdAt: startOfToday.subtract(const Duration(days: 30)),
        updatedAt: startOfToday.subtract(const Duration(days: 2)),
      ),
    ];

    final List<MedicationEvent> medicationEvents = <MedicationEvent>[
      _buildEvent(
        id: 'evt-001',
        patientId: patientProfile.id,
        prescriptionId: 'rx-omeprazole',
        dayOffset: -6,
        hour: 7,
        minute: 0,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-002',
        patientId: patientProfile.id,
        prescriptionId: 'rx-metformin',
        dayOffset: -5,
        hour: 12,
        minute: 30,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-003',
        patientId: patientProfile.id,
        prescriptionId: 'rx-omeprazole',
        dayOffset: -4,
        hour: 7,
        minute: 0,
        status: 'skipped',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-004',
        patientId: patientProfile.id,
        prescriptionId: 'rx-atorvastatin',
        dayOffset: -3,
        hour: 21,
        minute: 30,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-005',
        patientId: patientProfile.id,
        prescriptionId: 'rx-metformin',
        dayOffset: -2,
        hour: 12,
        minute: 30,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-006',
        patientId: patientProfile.id,
        prescriptionId: 'rx-omeprazole',
        dayOffset: -1,
        hour: 7,
        minute: 0,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-007',
        patientId: patientProfile.id,
        prescriptionId: 'rx-omeprazole',
        dayOffset: 0,
        hour: 7,
        minute: 0,
        status: 'done',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-008',
        patientId: patientProfile.id,
        prescriptionId: 'rx-metformin',
        dayOffset: 0,
        hour: 12,
        minute: 30,
        status: 'pending',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-009',
        patientId: patientProfile.id,
        prescriptionId: 'rx-atorvastatin',
        dayOffset: 0,
        hour: 21,
        minute: 30,
        status: 'pending',
        referenceDate: startOfToday,
      ),
      _buildEvent(
        id: 'evt-010',
        patientId: patientProfile.id,
        prescriptionId: 'rx-vitamin-d',
        dayOffset: 0,
        hour: 8,
        minute: 0,
        status: 'pending',
        referenceDate: startOfToday,
      ),
    ];

    final List<DecisionAlert> alerts = <DecisionAlert>[
      DecisionAlert(
        id: 'adherence-watch',
        patientId: patientProfile.id,
        type: 'adherence',
        severity: 'warning',
        title: 'One recent dose was skipped',
        explanation:
            'Your recent 7-day trend dipped after a missed dose earlier this week.',
        recommendation:
            'Keep the next scheduled dose on track to steady the adherence trend.',
        actionButtons: const <String>['Acknowledge'],
        dismissed: false,
        createdAt: startOfToday.add(const Duration(hours: 8)),
      ),
    ];

    return LocalDemoSeedData(
      referenceDate: referenceDate,
      patientProfile: patientProfile,
      prescriptions: prescriptions,
      medicationEvents: medicationEvents,
      alerts: alerts,
    );
  }

  static MedicationEvent _buildEvent({
    required String id,
    required String patientId,
    required String prescriptionId,
    required int dayOffset,
    required int hour,
    required int minute,
    required String status,
    required DateTime referenceDate,
  }) {
    final DateTime scheduledStart = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day + dayOffset,
      hour,
      minute,
    );

    return MedicationEvent(
      id: id,
      patientId: patientId,
      prescriptionId: prescriptionId,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledStart.add(const Duration(minutes: 30)),
      actualTakenAt: status == 'done'
          ? scheduledStart.add(const Duration(minutes: 5))
          : null,
      status: status,
      originalStart: null,
      delayMinutes: 0,
      googleCalendarEventId: '',
      syncedToGoogleCalendar: false,
      createdAt: scheduledStart.subtract(const Duration(days: 1)),
      updatedAt: scheduledStart,
    );
  }
}

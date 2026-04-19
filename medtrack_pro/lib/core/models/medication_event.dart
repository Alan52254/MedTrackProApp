class MedicationEvent {
  const MedicationEvent({
    required this.id,
    required this.patientId,
    required this.prescriptionId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.actualTakenAt,
    required this.status,
    required this.originalStart,
    required this.delayMinutes,
    required this.googleCalendarEventId,
    required this.syncedToGoogleCalendar,
    required this.lastReminderTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String prescriptionId;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualTakenAt;
  final String status;
  final DateTime? originalStart;
  final int delayMinutes;
  final String googleCalendarEventId;
  final bool syncedToGoogleCalendar;
  final DateTime? lastReminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationEvent copyWith({
    String? id,
    String? patientId,
    String? prescriptionId,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualTakenAt,
    bool clearActualTakenAt = false,
    String? status,
    DateTime? originalStart,
    bool clearOriginalStart = false,
    int? delayMinutes,
    String? googleCalendarEventId,
    bool? syncedToGoogleCalendar,
    DateTime? lastReminderTime,
    bool clearLastReminderTime = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationEvent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualTakenAt: clearActualTakenAt
          ? null
          : actualTakenAt ?? this.actualTakenAt,
      status: status ?? this.status,
      originalStart: clearOriginalStart
          ? null
          : originalStart ?? this.originalStart,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      googleCalendarEventId:
          googleCalendarEventId ?? this.googleCalendarEventId,
      syncedToGoogleCalendar:
          syncedToGoogleCalendar ?? this.syncedToGoogleCalendar,
      lastReminderTime: clearLastReminderTime
          ? null
          : lastReminderTime ?? this.lastReminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MedicationEvent.fromJson(Map<String, dynamic> json) {
    return MedicationEvent(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      prescriptionId: json['prescriptionId'] as String? ?? '',
      scheduledStart: DateTime.parse(json['scheduledStart'] as String),
      scheduledEnd: DateTime.parse(json['scheduledEnd'] as String),
      actualTakenAt: json['actualTakenAt'] == null
          ? null
          : DateTime.parse(json['actualTakenAt'] as String),
      status: json['status'] as String? ?? 'pending',
      originalStart: json['originalStart'] == null
          ? null
          : DateTime.parse(json['originalStart'] as String),
      delayMinutes: json['delayMinutes'] as int? ?? 0,
      googleCalendarEventId: json['googleCalendarEventId'] as String? ?? '',
      syncedToGoogleCalendar: json['syncedToGoogleCalendar'] as bool? ?? false,
      lastReminderTime: json['lastReminderTime'] == null
          ? null
          : DateTime.parse(json['lastReminderTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'prescriptionId': prescriptionId,
      'scheduledStart': scheduledStart.toIso8601String(),
      'scheduledEnd': scheduledEnd.toIso8601String(),
      'actualTakenAt': actualTakenAt?.toIso8601String(),
      'status': status,
      'originalStart': originalStart?.toIso8601String(),
      'delayMinutes': delayMinutes,
      'googleCalendarEventId': googleCalendarEventId,
      'syncedToGoogleCalendar': syncedToGoogleCalendar,
      'lastReminderTime': lastReminderTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

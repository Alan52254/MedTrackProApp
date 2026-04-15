class CalendarContextEvent {
  const CalendarContextEvent({
    required this.id,
    required this.patientId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.activity,
    required this.location,
    required this.weather,
    required this.fatigueLevel,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String activity;
  final String location;
  final String weather;
  final String fatigueLevel;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarContextEvent copyWith({
    String? id,
    String? patientId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? activity,
    String? location,
    String? weather,
    String? fatigueLevel,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarContextEvent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activity: activity ?? this.activity,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CalendarContextEvent.fromJson(Map<String, dynamic> json) {
    return CalendarContextEvent(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      activity: json['activity'] as String? ?? '',
      location: json['location'] as String? ?? '',
      weather: json['weather'] as String? ?? '',
      fatigueLevel: json['fatigueLevel'] as String? ?? '',
      source: json['source'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'activity': activity,
      'location': location,
      'weather': weather,
      'fatigueLevel': fatigueLevel,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

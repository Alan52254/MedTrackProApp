class GoogleCalendarActivity {
  const GoogleCalendarActivity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.googleCalendarEventId,
    required this.syncStatus,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  /// Populated after a successful write to Google Calendar.
  final String googleCalendarEventId;

  /// One of: 'pending', 'synced', 'error'.
  final String syncStatus;

  final DateTime createdAt;

  GoogleCalendarActivity copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? googleCalendarEventId,
    String? syncStatus,
    DateTime? createdAt,
  }) {
    return GoogleCalendarActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      googleCalendarEventId:
          googleCalendarEventId ?? this.googleCalendarEventId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'googleCalendarEventId': googleCalendarEventId,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoogleCalendarActivity.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarActivity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      googleCalendarEventId: json['googleCalendarEventId'] as String? ?? '',
      syncStatus: json['syncStatus'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

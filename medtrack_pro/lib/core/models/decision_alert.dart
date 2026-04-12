class DecisionAlert {
  const DecisionAlert({
    required this.id,
    required this.patientId,
    required this.type,
    required this.severity,
    required this.title,
    required this.explanation,
    required this.recommendation,
    required this.actionButtons,
    required this.dismissed,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final String type;
  final String severity;
  final String title;
  final String explanation;
  final String recommendation;
  final List<String> actionButtons;
  final bool dismissed;
  final DateTime createdAt;

  DecisionAlert copyWith({
    String? id,
    String? patientId,
    String? type,
    String? severity,
    String? title,
    String? explanation,
    String? recommendation,
    List<String>? actionButtons,
    bool? dismissed,
    DateTime? createdAt,
  }) {
    return DecisionAlert(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      recommendation: recommendation ?? this.recommendation,
      actionButtons: actionButtons ?? this.actionButtons,
      dismissed: dismissed ?? this.dismissed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory DecisionAlert.fromJson(Map<String, dynamic> json) {
    return DecisionAlert(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      actionButtons: (json['actionButtons'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      dismissed: json['dismissed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'type': type,
      'severity': severity,
      'title': title,
      'explanation': explanation,
      'recommendation': recommendation,
      'actionButtons': actionButtons,
      'dismissed': dismissed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

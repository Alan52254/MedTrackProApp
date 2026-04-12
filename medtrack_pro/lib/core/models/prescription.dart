class Prescription {
  const Prescription({
    required this.id,
    required this.patientId,
    required this.drugName,
    required this.commonFrequency,
    required this.dose,
    required this.durationDays,
    required this.indication,
    required this.drugInteractions,
    required this.note,
    required this.administrationType,
    required this.frequencyType,
    required this.frequencyValue,
    required this.active,
    required this.source,
    required this.imageId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String drugName;
  final String commonFrequency;
  final String dose;
  final int durationDays;
  final String indication;
  final List<String> drugInteractions;
  final String note;
  final String administrationType;
  final String frequencyType;
  final String frequencyValue;
  final bool active;
  final String source;
  final String imageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription copyWith({
    String? id,
    String? patientId,
    String? drugName,
    String? commonFrequency,
    String? dose,
    int? durationDays,
    String? indication,
    List<String>? drugInteractions,
    String? note,
    String? administrationType,
    String? frequencyType,
    String? frequencyValue,
    bool? active,
    String? source,
    String? imageId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      drugName: drugName ?? this.drugName,
      commonFrequency: commonFrequency ?? this.commonFrequency,
      dose: dose ?? this.dose,
      durationDays: durationDays ?? this.durationDays,
      indication: indication ?? this.indication,
      drugInteractions: drugInteractions ?? this.drugInteractions,
      note: note ?? this.note,
      administrationType: administrationType ?? this.administrationType,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      active: active ?? this.active,
      source: source ?? this.source,
      imageId: imageId ?? this.imageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      drugName: json['drugName'] as String? ?? '',
      commonFrequency: json['commonFrequency'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      durationDays: json['durationDays'] as int? ?? 0,
      indication: json['indication'] as String? ?? '',
      drugInteractions:
          (json['drugInteractions'] as List<dynamic>? ?? <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      note: json['note'] as String? ?? '',
      administrationType: json['administrationType'] as String? ?? '',
      frequencyType: json['frequencyType'] as String? ?? '',
      frequencyValue: json['frequencyValue'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      source: json['source'] as String? ?? '',
      imageId: json['imageId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'drugName': drugName,
      'commonFrequency': commonFrequency,
      'dose': dose,
      'durationDays': durationDays,
      'indication': indication,
      'drugInteractions': drugInteractions,
      'note': note,
      'administrationType': administrationType,
      'frequencyType': frequencyType,
      'frequencyValue': frequencyValue,
      'active': active,
      'source': source,
      'imageId': imageId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

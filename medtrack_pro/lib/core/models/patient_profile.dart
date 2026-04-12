class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.authUserId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.patientCode,
    required this.occupation,
    required this.comorbidityCount,
    required this.hasComorbidity,
    required this.diseaseList,
    required this.hasCaregiver,
    required this.allergies,
    required this.diagnoses,
    required this.wakeTime,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.sleepTime,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String authUserId;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final int age;
  final String patientCode;
  final String occupation;
  final int comorbidityCount;
  final bool hasComorbidity;
  final List<String> diseaseList;
  final bool hasCaregiver;
  final List<String> allergies;
  final List<String> diagnoses;
  final String wakeTime;
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;
  final String sleepTime;
  final String caregiverName;
  final String caregiverPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientProfile copyWith({
    String? id,
    String? authUserId,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    String? patientCode,
    String? occupation,
    int? comorbidityCount,
    bool? hasComorbidity,
    List<String>? diseaseList,
    bool? hasCaregiver,
    List<String>? allergies,
    List<String>? diagnoses,
    String? wakeTime,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    String? sleepTime,
    String? caregiverName,
    String? caregiverPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      patientCode: patientCode ?? this.patientCode,
      occupation: occupation ?? this.occupation,
      comorbidityCount: comorbidityCount ?? this.comorbidityCount,
      hasComorbidity: hasComorbidity ?? this.hasComorbidity,
      diseaseList: diseaseList ?? this.diseaseList,
      hasCaregiver: hasCaregiver ?? this.hasCaregiver,
      allergies: allergies ?? this.allergies,
      diagnoses: diagnoses ?? this.diagnoses,
      wakeTime: wakeTime ?? this.wakeTime,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      sleepTime: sleepTime ?? this.sleepTime,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? '',
      authUserId: json['authUserId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      age: json['age'] as int? ?? 0,
      patientCode: json['patientCode'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      comorbidityCount: json['comorbidityCount'] as int? ?? 0,
      hasComorbidity: json['hasComorbidity'] as bool? ?? false,
      diseaseList: (json['diseaseList'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      hasCaregiver: json['hasCaregiver'] as bool? ?? false,
      allergies: (json['allergies'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      diagnoses: (json['diagnoses'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      wakeTime: json['wakeTime'] as String? ?? '',
      breakfastTime: json['breakfastTime'] as String? ?? '',
      lunchTime: json['lunchTime'] as String? ?? '',
      dinnerTime: json['dinnerTime'] as String? ?? '',
      sleepTime: json['sleepTime'] as String? ?? '',
      caregiverName: json['caregiverName'] as String? ?? '',
      caregiverPhone: json['caregiverPhone'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'authUserId': authUserId,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'patientCode': patientCode,
      'occupation': occupation,
      'comorbidityCount': comorbidityCount,
      'hasComorbidity': hasComorbidity,
      'diseaseList': diseaseList,
      'hasCaregiver': hasCaregiver,
      'allergies': allergies,
      'diagnoses': diagnoses,
      'wakeTime': wakeTime,
      'breakfastTime': breakfastTime,
      'lunchTime': lunchTime,
      'dinnerTime': dinnerTime,
      'sleepTime': sleepTime,
      'caregiverName': caregiverName,
      'caregiverPhone': caregiverPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

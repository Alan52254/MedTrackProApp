import '../../../core/models/patient_profile.dart';

class ProfileFormData {
  const ProfileFormData({
    required this.fullName,
    required this.patientCode,
    required this.gender,
    required this.age,
    required this.occupation,
    required this.comorbidityCount,
    required this.hasComorbidity,
    required this.diseaseList,
    required this.hasCaregiver,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.wakeTime,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.sleepTime,
  });

  final String fullName;
  final String patientCode;
  final String gender;
  final String age;
  final String occupation;
  final String comorbidityCount;
  final bool hasComorbidity;
  final String diseaseList;
  final bool hasCaregiver;
  final String caregiverName;
  final String caregiverPhone;
  final String wakeTime;
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;
  final String sleepTime;

  factory ProfileFormData.fromProfile(PatientProfile profile) {
    return ProfileFormData(
      fullName: profile.fullName,
      patientCode: profile.patientCode,
      gender: profile.gender,
      age: profile.age.toString(),
      occupation: profile.occupation,
      comorbidityCount: profile.comorbidityCount.toString(),
      hasComorbidity: profile.hasComorbidity,
      diseaseList: profile.diseaseList.join(', '),
      hasCaregiver: profile.hasCaregiver,
      caregiverName: profile.caregiverName,
      caregiverPhone: profile.caregiverPhone,
      wakeTime: profile.wakeTime,
      breakfastTime: profile.breakfastTime,
      lunchTime: profile.lunchTime,
      dinnerTime: profile.dinnerTime,
      sleepTime: profile.sleepTime,
    );
  }

  ProfileFormData copyWith({
    String? fullName,
    String? patientCode,
    String? gender,
    String? age,
    String? occupation,
    String? comorbidityCount,
    bool? hasComorbidity,
    String? diseaseList,
    bool? hasCaregiver,
    String? caregiverName,
    String? caregiverPhone,
    String? wakeTime,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    String? sleepTime,
  }) {
    return ProfileFormData(
      fullName: fullName ?? this.fullName,
      patientCode: patientCode ?? this.patientCode,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      comorbidityCount: comorbidityCount ?? this.comorbidityCount,
      hasComorbidity: hasComorbidity ?? this.hasComorbidity,
      diseaseList: diseaseList ?? this.diseaseList,
      hasCaregiver: hasCaregiver ?? this.hasCaregiver,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      wakeTime: wakeTime ?? this.wakeTime,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }
}

class ProfileState {
  const ProfileState({
    required this.savedProfile,
    required this.form,
    required this.showWakeTimeNote,
    required this.saveMessage,
  });

  final PatientProfile savedProfile;
  final ProfileFormData form;
  final bool showWakeTimeNote;
  final String saveMessage;

  ProfileState copyWith({
    PatientProfile? savedProfile,
    ProfileFormData? form,
    bool? showWakeTimeNote,
    String? saveMessage,
  }) {
    return ProfileState(
      savedProfile: savedProfile ?? this.savedProfile,
      form: form ?? this.form,
      showWakeTimeNote: showWakeTimeNote ?? this.showWakeTimeNote,
      saveMessage: saveMessage ?? this.saveMessage,
    );
  }
}

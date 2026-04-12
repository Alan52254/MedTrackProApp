import '../../../core/models/patient_profile.dart';

class ProfileFormData {
  const ProfileFormData({
    required this.fullName,
    required this.patientCode,
    required this.occupation,
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
  final String occupation;
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
      occupation: profile.occupation,
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
    String? occupation,
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
      occupation: occupation ?? this.occupation,
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

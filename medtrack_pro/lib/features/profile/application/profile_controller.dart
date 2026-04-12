import 'package:flutter/foundation.dart';

import '../../../core/models/patient_profile.dart';
import '../../../core/services/local_demo_store.dart';
import 'profile_state.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({LocalDemoStore? store})
    : this._(store ?? LocalDemoStore(), store == null);

  ProfileController._(this._store, this._ownsStore)
    : _state = _buildState(_store.patientProfile) {
    _store.addListener(_handleStoreChanged);
  }

  final LocalDemoStore _store;
  final bool _ownsStore;
  ProfileState _state;

  ProfileState get state => _state;

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  void updateFullName(String value) {
    _updateForm(_state.form.copyWith(fullName: value), clearSaveMessage: true);
  }

  void updatePatientCode(String value) {
    _updateForm(
      _state.form.copyWith(patientCode: value),
      clearSaveMessage: true,
    );
  }

  void updateOccupation(String value) {
    _updateForm(
      _state.form.copyWith(occupation: value),
      clearSaveMessage: true,
    );
  }

  void updateHasComorbidity(bool value) {
    _updateForm(
      _state.form.copyWith(
        hasComorbidity: value,
        diseaseList: value ? _state.form.diseaseList : '',
      ),
      clearSaveMessage: true,
    );
  }

  void updateDiseaseList(String value) {
    _updateForm(
      _state.form.copyWith(diseaseList: value),
      clearSaveMessage: true,
    );
  }

  void updateHasCaregiver(bool value) {
    _updateForm(
      _state.form.copyWith(
        hasCaregiver: value,
        caregiverName: value ? _state.form.caregiverName : '',
        caregiverPhone: value ? _state.form.caregiverPhone : '',
      ),
      clearSaveMessage: true,
    );
  }

  void updateCaregiverName(String value) {
    _updateForm(
      _state.form.copyWith(caregiverName: value),
      clearSaveMessage: true,
    );
  }

  void updateCaregiverPhone(String value) {
    _updateForm(
      _state.form.copyWith(caregiverPhone: value),
      clearSaveMessage: true,
    );
  }

  void updateWakeTime(String value) {
    final bool showWakeTimeNote = value != _state.savedProfile.wakeTime;
    _updateForm(
      _state.form.copyWith(wakeTime: value),
      clearSaveMessage: true,
      showWakeTimeNote: showWakeTimeNote,
    );
  }

  void updateBreakfastTime(String value) {
    _updateForm(
      _state.form.copyWith(breakfastTime: value),
      clearSaveMessage: true,
    );
  }

  void updateLunchTime(String value) {
    _updateForm(_state.form.copyWith(lunchTime: value), clearSaveMessage: true);
  }

  void updateDinnerTime(String value) {
    _updateForm(
      _state.form.copyWith(dinnerTime: value),
      clearSaveMessage: true,
    );
  }

  void updateSleepTime(String value) {
    _updateForm(_state.form.copyWith(sleepTime: value), clearSaveMessage: true);
  }

  void resetForm() {
    _state = _buildState(_store.patientProfile);
    notifyListeners();
  }

  void save() {
    final PatientProfile updatedProfile = _state.savedProfile.copyWith(
      fullName: _state.form.fullName.trim(),
      patientCode: _state.form.patientCode.trim(),
      occupation: _state.form.occupation.trim(),
      hasComorbidity: _state.form.hasComorbidity,
      diseaseList: _state.form.hasComorbidity
          ? _parseDiseaseList(_state.form.diseaseList)
          : const <String>[],
      comorbidityCount: _state.form.hasComorbidity
          ? _parseDiseaseList(_state.form.diseaseList).length
          : 0,
      hasCaregiver: _state.form.hasCaregiver,
      caregiverName: _state.form.hasCaregiver
          ? _state.form.caregiverName.trim()
          : '',
      caregiverPhone: _state.form.hasCaregiver
          ? _state.form.caregiverPhone.trim()
          : '',
      wakeTime: _state.form.wakeTime,
      breakfastTime: _state.form.breakfastTime,
      lunchTime: _state.form.lunchTime,
      dinnerTime: _state.form.dinnerTime,
      sleepTime: _state.form.sleepTime,
      updatedAt: DateTime.now(),
    );

    _store.updatePatientProfile(updatedProfile);
    _state = _buildState(
      updatedProfile,
    ).copyWith(saveMessage: 'Profile saved locally.');
    notifyListeners();
  }

  static ProfileState _buildState(PatientProfile profile) {
    return ProfileState(
      savedProfile: profile,
      form: ProfileFormData.fromProfile(profile),
      showWakeTimeNote: false,
      saveMessage: '',
    );
  }

  void _updateForm(
    ProfileFormData form, {
    bool clearSaveMessage = false,
    bool? showWakeTimeNote,
  }) {
    _state = _state.copyWith(
      form: form,
      showWakeTimeNote: showWakeTimeNote ?? _state.showWakeTimeNote,
      saveMessage: clearSaveMessage ? '' : _state.saveMessage,
    );
    notifyListeners();
  }

  List<String> _parseDiseaseList(String rawValue) {
    return rawValue
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  void _handleStoreChanged() {
    final PatientProfile profile = _store.patientProfile;
    if (profile.updatedAt == _state.savedProfile.updatedAt &&
        profile.fullName == _state.savedProfile.fullName &&
        profile.patientCode == _state.savedProfile.patientCode &&
        profile.occupation == _state.savedProfile.occupation &&
        profile.wakeTime == _state.savedProfile.wakeTime) {
      return;
    }

    _state = _buildState(profile);
    notifyListeners();
  }
}

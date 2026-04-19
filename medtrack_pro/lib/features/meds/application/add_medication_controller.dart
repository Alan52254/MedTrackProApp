import 'package:flutter/foundation.dart';

import '../../../core/models/prescription.dart';
import '../../../core/services/local_demo_store.dart';
import 'add_medication_state.dart';

/// Controller managing the Add Medication form lifecycle.
class AddMedicationController extends ChangeNotifier {
  AddMedicationController({required LocalDemoStore store}) : _store = store;

  final LocalDemoStore _store;

  AddMedicationState _state = const AddMedicationState(
    form: AddMedicationFormData(),
    saveMessage: '',
    isSaved: false,
  );

  AddMedicationState get state => _state;

  void updateDrugName(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(drugName: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateCommonFrequency(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(commonFrequency: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateDose(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(dose: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateDurationDays(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(durationDays: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateIndication(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(indication: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateDrugInteractions(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(drugInteractions: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void updateNote(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(note: value),
      saveMessage: '',
    );
    notifyListeners();
  }

  void setImage(String path, String source) {
    _state = _state.copyWith(
      form: _state.form.copyWith(imagePath: path, imageSource: source),
      saveMessage: '',
    );
    notifyListeners();
  }

  void clearImage() {
    _state = _state.copyWith(
      form: _state.form.copyWith(imagePath: '', imageSource: ''),
      saveMessage: '',
    );
    notifyListeners();
  }

  /// Validate and save the prescription to the local store.
  void save() {
    final AddMedicationFormData form = _state.form;

    if (form.drugName.trim().isEmpty) {
      _state = _state.copyWith(saveMessage: 'Drug name is required.');
      notifyListeners();
      return;
    }

    if (form.dose.trim().isEmpty) {
      _state = _state.copyWith(saveMessage: 'Dose is required.');
      notifyListeners();
      return;
    }

    final int durationDays = int.tryParse(form.durationDays.trim()) ?? 30;

    final List<String> interactions = form.drugInteractions
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);

    final String source = form.imagePath.isNotEmpty
        ? form.imageSource
        : 'manual';

    final Prescription prescription = Prescription(
      id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
      patientId: _store.patientProfile.id,
      drugName: form.drugName.trim(),
      commonFrequency: form.commonFrequency,
      dose: form.dose.trim(),
      durationDays: durationDays,
      indication: form.indication.trim(),
      drugInteractions: interactions,
      note: form.note.trim(),
      administrationType: _resolveAdministrationType(form.commonFrequency),
      frequencyType: 'daily',
      frequencyValue: '1',
      active: true,
      source: source,
      imageId: form.imagePath.isNotEmpty ? form.imagePath : '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _store.addPrescription(prescription);

    _state = AddMedicationState(
      form: const AddMedicationFormData(),
      saveMessage: '${prescription.drugName} added successfully.',
      isSaved: true,
    );
    notifyListeners();
  }

  void resetForm() {
    _state = const AddMedicationState(
      form: AddMedicationFormData(),
      saveMessage: '',
      isSaved: false,
    );
    notifyListeners();
  }

  String _resolveAdministrationType(String frequency) {
    switch (frequency) {
      case 'Once daily':
        return 'With breakfast';
      case 'Twice daily':
        return 'With breakfast and dinner';
      case 'Three times daily':
        return 'With meals';
      case 'As needed':
        return 'As needed';
      default:
        return 'With breakfast';
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../core/models/prescription_ocr_result.dart';
import '../../../core/models/prescription.dart';
import '../../../core/services/local_demo_store.dart';
import '../../../core/services/prescription_ocr_service.dart';
import 'add_medication_state.dart';

class AddMedicationController extends ChangeNotifier {
  AddMedicationController({
    required LocalDemoStore store,
    PrescriptionOcrService? ocrService,
  }) : _store = store,
       _ocrService = ocrService ?? const PrescriptionOcrService();

  final LocalDemoStore _store;
  final PrescriptionOcrService _ocrService;
  bool _disposed = false;

  AddMedicationState _state = const AddMedicationState(
    form: AddMedicationFormData(),
    saveMessage: '',
    isSaved: false,
    flowStatus: AddMedicationFlowStatus.idle,
    statusMessage: '',
    errorMessage: '',
  );

  AddMedicationState get state => _state;

  void updateDrugName(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(drugName: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateCommonFrequency(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(commonFrequency: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateDose(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(dose: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateDurationDays(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(durationDays: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateIndication(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(indication: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateDrugInteractions(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(drugInteractions: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void updateNote(String value) {
    _state = _state.copyWith(
      form: _state.form.copyWith(note: value),
      saveMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void beginImagePicking(String sourceLabel) {
    _state = _state.copyWith(
      saveMessage: '',
      flowStatus: AddMedicationFlowStatus.pickingImage,
      statusMessage: 'Opening $sourceLabel...',
      errorMessage: '',
    );
    notifyListeners();
  }

  void setImage(String path, String source) {
    _state = _state.copyWith(
      form: _state.form.copyWith(imagePath: path, imageSource: source),
      saveMessage: '',
      flowStatus: AddMedicationFlowStatus.imageAttached,
      statusMessage: 'Image attached. You can review it or run OCR.',
      errorMessage: '',
    );
    notifyListeners();
  }

  void cancelImagePicking() {
    _state = _state.copyWith(
      flowStatus: _state.form.imagePath.isEmpty
          ? AddMedicationFlowStatus.idle
          : AddMedicationFlowStatus.imageAttached,
      statusMessage: _state.form.imagePath.isEmpty
          ? ''
          : 'Image attached. You can review it or run OCR.',
      errorMessage: '',
    );
    notifyListeners();
  }

  void failImagePicking(String message) {
    _state = _state.copyWith(
      flowStatus: _state.form.imagePath.isEmpty
          ? AddMedicationFlowStatus.idle
          : AddMedicationFlowStatus.imageAttached,
      statusMessage: _state.form.imagePath.isEmpty
          ? ''
          : 'Image attached. You can review it or run OCR.',
      errorMessage: message,
    );
    notifyListeners();
  }

  void clearImage() {
    _state = _state.copyWith(
      form: _state.form.copyWith(imagePath: '', imageSource: ''),
      saveMessage: '',
      flowStatus: AddMedicationFlowStatus.idle,
      statusMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  Future<void> extractFromSelectedImage() async {
    if (_disposed || _state.isRunningOcr) {
      return;
    }

    final String imagePath = _state.form.imagePath;
    if (imagePath.isEmpty) {
      _state = _state.copyWith(
        flowStatus: AddMedicationFlowStatus.ocrFailure,
        statusMessage: '',
        errorMessage: 'Select a prescription image before running OCR.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      flowStatus: AddMedicationFlowStatus.runningOcr,
      statusMessage: 'Processing selected image...',
      errorMessage: '',
      saveMessage: '',
    );
    notifyListeners();

    try {
      final PrescriptionOcrResult result = await _ocrService.extractFromImage(
        imagePath,
      );
      if (_disposed) {
        return;
      }

      if (result.isEmpty) {
        _state = _state.copyWith(
          flowStatus: AddMedicationFlowStatus.ocrFailure,
          statusMessage: '',
          errorMessage:
              'OCR could not detect medication details. You can keep entering the form manually.',
        );
      } else {
        _applyOcrAutofill(result);
        _state = _state.copyWith(
          flowStatus: AddMedicationFlowStatus.ocrSuccess,
          statusMessage: 'OCR filled some fields. Please review before saving.',
          errorMessage: '',
        );
      }
    } catch (_) {
      if (_disposed) {
        return;
      }
      _state = _state.copyWith(
        flowStatus: AddMedicationFlowStatus.ocrFailure,
        statusMessage: '',
        errorMessage:
            'We could not read this prescription clearly. You can still complete the form manually.',
      );
    }

    notifyListeners();
  }

  void _applyOcrAutofill(PrescriptionOcrResult result) {
    if (result.drugName.isNotEmpty) {
      updateDrugName(result.drugName);
    }
    if (result.dose.isNotEmpty) {
      updateDose(result.dose);
    }

    final String normalizedFrequency = _normalizeFrequency(
      result.frequency,
      _state.form.commonFrequency,
    );
    if (normalizedFrequency != _state.form.commonFrequency) {
      updateCommonFrequency(normalizedFrequency);
    }
    if (result.duration.isNotEmpty) {
      updateDurationDays(result.duration);
    }
    if (result.indication.isNotEmpty) {
      updateIndication(result.indication);
    }
    if (result.interactionField.isNotEmpty) {
      updateDrugInteractions(result.interactionField);
    }
    if (result.note.isNotEmpty) {
      updateNote(result.note);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void save() {
    final AddMedicationFormData form = _state.form;

    if (form.drugName.trim().isEmpty) {
      _state = _state.copyWith(
        saveMessage: 'Drug name is required.',
        flowStatus: AddMedicationFlowStatus.saveFailure,
        errorMessage: '',
      );
      notifyListeners();
      return;
    }

    if (form.dose.trim().isEmpty) {
      _state = _state.copyWith(
        saveMessage: 'Dose is required.',
        flowStatus: AddMedicationFlowStatus.saveFailure,
        errorMessage: '',
      );
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
      flowStatus: AddMedicationFlowStatus.saveSuccess,
      statusMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  void resetForm() {
    _state = const AddMedicationState(
      form: AddMedicationFormData(),
      saveMessage: '',
      isSaved: false,
      flowStatus: AddMedicationFlowStatus.idle,
      statusMessage: '',
      errorMessage: '',
    );
    notifyListeners();
  }

  String _normalizeFrequency(String value, String fallback) {
    switch (value) {
      case 'Once daily':
      case 'Twice daily':
      case 'Three times daily':
      case 'As needed':
        return value;
      default:
        return fallback;
    }
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

enum AddMedicationFlowStatus {
  idle,
  pickingImage,
  imageAttached,
  runningOcr,
  ocrSuccess,
  ocrFailure,
  saveSuccess,
  saveFailure,
}

class AddMedicationFormData {
  const AddMedicationFormData({
    this.drugName = '',
    this.commonFrequency = 'Once daily',
    this.dose = '',
    this.durationDays = '30',
    this.indication = '',
    this.drugInteractions = '',
    this.note = '',
    this.imagePath = '',
    this.imageSource = '',
  });

  final String drugName;
  final String commonFrequency;
  final String dose;
  final String durationDays;
  final String indication;
  final String drugInteractions;
  final String note;
  final String imagePath;
  final String imageSource;

  AddMedicationFormData copyWith({
    String? drugName,
    String? commonFrequency,
    String? dose,
    String? durationDays,
    String? indication,
    String? drugInteractions,
    String? note,
    String? imagePath,
    String? imageSource,
  }) {
    return AddMedicationFormData(
      drugName: drugName ?? this.drugName,
      commonFrequency: commonFrequency ?? this.commonFrequency,
      dose: dose ?? this.dose,
      durationDays: durationDays ?? this.durationDays,
      indication: indication ?? this.indication,
      drugInteractions: drugInteractions ?? this.drugInteractions,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      imageSource: imageSource ?? this.imageSource,
    );
  }
}

class AddMedicationState {
  const AddMedicationState({
    required this.form,
    required this.saveMessage,
    required this.isSaved,
    required this.flowStatus,
    required this.statusMessage,
    required this.errorMessage,
  });

  final AddMedicationFormData form;
  final String saveMessage;
  final bool isSaved;
  final AddMedicationFlowStatus flowStatus;
  final String statusMessage;
  final String errorMessage;

  bool get isPickingImage => flowStatus == AddMedicationFlowStatus.pickingImage;
  bool get isRunningOcr => flowStatus == AddMedicationFlowStatus.runningOcr;
  bool get hasAttachedImage => form.imagePath.isNotEmpty;

  AddMedicationState copyWith({
    AddMedicationFormData? form,
    String? saveMessage,
    bool? isSaved,
    AddMedicationFlowStatus? flowStatus,
    String? statusMessage,
    String? errorMessage,
  }) {
    return AddMedicationState(
      form: form ?? this.form,
      saveMessage: saveMessage ?? this.saveMessage,
      isSaved: isSaved ?? this.isSaved,
      flowStatus: flowStatus ?? this.flowStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

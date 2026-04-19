/// Form state for the Add Medication screen.
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

  /// Local file path of the captured/picked image (empty if none).
  final String imagePath;

  /// 'camera', 'gallery', or '' if none.
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
  });

  final AddMedicationFormData form;
  final String saveMessage;
  final bool isSaved;

  AddMedicationState copyWith({
    AddMedicationFormData? form,
    String? saveMessage,
    bool? isSaved,
  }) {
    return AddMedicationState(
      form: form ?? this.form,
      saveMessage: saveMessage ?? this.saveMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

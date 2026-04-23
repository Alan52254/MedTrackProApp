class PrescriptionOcrResult {
  const PrescriptionOcrResult({
    this.drugName = '',
    this.dose = '',
    this.frequency = '',
    this.duration = '',
    this.indication = '',
    this.note = '',
    this.interactionField = '',
  });

  final String drugName;
  final String dose;
  final String frequency;
  final String duration;
  final String indication;
  final String note;
  final String interactionField;

  bool get isEmpty =>
      drugName.isEmpty &&
      dose.isEmpty &&
      frequency.isEmpty &&
      duration.isEmpty &&
      indication.isEmpty &&
      note.isEmpty &&
      interactionField.isEmpty;
}

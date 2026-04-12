import '../../../core/models/medication_event.dart';
import '../../../core/models/prescription.dart';

class HomeMedicationViewModel {
  const HomeMedicationViewModel({
    required this.event,
    required this.prescription,
  });

  final MedicationEvent event;
  final Prescription prescription;

  bool get isActionable =>
      event.status == 'pending' || event.status == 'delayed';

  String get doseLine => prescription.dose;

  String get instructionLine => prescription.administrationType;

  String get detailLine => prescription.note.isEmpty
      ? prescription.commonFrequency
      : prescription.note;
}

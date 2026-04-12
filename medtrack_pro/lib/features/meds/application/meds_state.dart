import '../../../core/models/prescription.dart';

class MedsState {
  const MedsState({required this.prescriptions});

  final List<Prescription> prescriptions;

  List<Prescription> get sortedPrescriptions {
    final List<Prescription> items = List<Prescription>.from(prescriptions)
      ..sort((Prescription first, Prescription second) {
        if (first.active == second.active) {
          return first.drugName.compareTo(second.drugName);
        }
        return first.active ? -1 : 1;
      });

    return items;
  }

  int get activeCount => prescriptions
      .where((Prescription prescription) => prescription.active)
      .length;

  int get inactiveCount => prescriptions.length - activeCount;
}

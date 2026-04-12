import 'package:flutter/foundation.dart';

import '../../../core/models/prescription.dart';
import '../../../core/services/local_demo_store.dart';
import 'meds_state.dart';

class MedsController extends ChangeNotifier {
  MedsController({LocalDemoStore? store})
    : _store = store ?? LocalDemoStore(),
      _ownsStore = store == null {
    _store.addListener(_handleStoreChanged);
  }

  final LocalDemoStore _store;
  final bool _ownsStore;

  MedsState get state => MedsState(prescriptions: _store.prescriptions);

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  void setPrescriptionActive(String prescriptionId, bool isActive) {
    final Prescription prescription = _store.prescriptions.firstWhere(
      (Prescription item) => item.id == prescriptionId,
    );

    _store.updatePrescription(
      prescription.copyWith(active: isActive, updatedAt: DateTime.now()),
    );
  }

  void _handleStoreChanged() {
    notifyListeners();
  }
}

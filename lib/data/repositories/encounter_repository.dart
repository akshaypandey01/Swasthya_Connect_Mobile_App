import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/services/connectivity_service.dart';
import '../models/encounter_model.dart';

final encounterRepositoryProvider =
    Provider<EncounterRepository>((ref) => EncounterRepository(ref));

class EncounterRepository {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  EncounterRepository(this._ref);

  Box<EncounterModel> get _box =>
      Hive.box<EncounterModel>(HiveConstants.encounterBox);

  Future<EncounterModel> createEncounter({
    required String patientId,
    required String workerId,
    required Map<String, dynamic> vitals,
    Map<String, dynamic>? symptomInput,
    String? locationLat,
    String? locationLng,
    String? triageSeverity,
    String? notes,
  }) async {
    final isOnline = _ref.read(isOnlineProvider);
    final id = const Uuid().v4();

    final encounter = EncounterModel(
      encounterId: id,
      patientId: patientId,
      workerId: workerId,
      timestamp: DateTime.now().toIso8601String(),
      vitals: vitals,
      symptomInput: symptomInput ?? {},
      locationLat: locationLat,
      locationLng: locationLng,
      triageSeverity: triageSeverity,
      notes: notes,
      syncStatus: isOnline ? 'synced' : 'pending',
    );

    await _box.put(id, encounter);

    if (isOnline) {
      try {
        await _db
            .collection('encounters')
            .doc(id)
            .set(encounter.toFirestore());
      } catch (_) {
        encounter.syncStatus = 'pending';
        await encounter.save();
      }
    }

    return encounter;
  }

  List<EncounterModel> getForPatient(String patientId) => _box.values
      .where((e) => e.patientId == patientId)
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Stream of encounters for a patient from Firestore.
  Stream<QuerySnapshot> streamForPatient(String patientId) => _db
      .collection('encounters')
      .where('patient_id', isEqualTo: patientId)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

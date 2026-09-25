import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/services/connectivity_service.dart';
import '../models/patient_model.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository(ref);
});

class PatientRepository {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  PatientRepository(this._ref);

  Box<PatientModel> get _box => Hive.box<PatientModel>(HiveConstants.patientBox);

  /// Save a new patient locally and to Firestore if online.
  Future<PatientModel> createPatient({
    required String name,
    required String dob,
    required String gender,
    required String phone,
    String? abhaId,
    String? address,
    String languagePref = 'en',
  }) async {
    final isOnline = _ref.read(isOnlineProvider);
    final id = const Uuid().v4();
    final tempId = abhaId == null
        ? 'TMP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'
        : null;

    final patient = PatientModel(
      patientId: id,
      name: name,
      dob: dob,
      gender: gender,
      phone: phone,
      abhaId: abhaId,
      tempId: tempId,
      isAbhaRegistered: abhaId != null,
      languagePref: languagePref,
      address: address,
      syncStatus: isOnline ? 'synced' : 'pending',
    );

    await _box.put(id, patient);

    if (isOnline) {
      try {
        await _db
            .collection('patients')
            .doc(id)
            .set(patient.toFirestore());
      } catch (_) {
        patient.syncStatus = 'pending';
        await patient.save();
      }
    }

    return patient;
  }

  /// Fetch patient by ID — tries local first, falls back to Firestore.
  Future<PatientModel?> getById(String patientId) async {
    // Try local Hive first
    final local = _box.get(patientId);
    if (local != null) return local;

    // Try Firestore
    try {
      final doc =
          await _db.collection('patients').doc(patientId).get();
      if (doc.exists) {
        final patient =
            PatientModel.fromFirestore(doc.data()!);
        await _box.put(patientId, patient); // cache locally
        return patient;
      }
    } catch (_) {}
    return null;
  }

  /// Search patients by name prefix (Firestore).
  Future<List<PatientModel>> searchByName(String query) async {
    if (query.trim().isEmpty) return [];

    // Local search
    final local = _box.values
        .where(
            (p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Remote search
    try {
      final snap = await _db
          .collection('patients')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();
      final remoteIds = local.map((p) => p.patientId).toSet();
      for (final doc in snap.docs) {
        final p = PatientModel.fromFirestore(doc.data());
        if (!remoteIds.contains(p.patientId)) {
          local.add(p);
          await _box.put(p.patientId, p);
        }
      }
    } catch (_) {}

    return local;
  }

  /// All locally stored patients.
  List<PatientModel> getAllLocal() => _box.values.toList();

  /// Count of pending-sync patients.
  int get pendingCount =>
      _box.values.where((p) => p.syncStatus == 'pending').length;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/services/connectivity_service.dart';
import '../models/tracker_entry_model.dart';

final trackerRepositoryProvider =
    Provider<TrackerRepository>((ref) => TrackerRepository(ref));

class TrackerRepository {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  TrackerRepository(this._ref);

  Box<TrackerEntryModel> get _box =>
      Hive.box<TrackerEntryModel>(HiveConstants.trackerBox);

  Future<TrackerEntryModel> addEntry({
    required String patientId,
    required String type,
    required Map<String, dynamic> data,
    String? nextDueDate,
  }) async {
    final isOnline = _ref.read(isOnlineProvider);
    final id = const Uuid().v4();
    final entry = TrackerEntryModel(
      entryId: id,
      patientId: patientId,
      type: type,
      entryDate: DateTime.now().toIso8601String().substring(0, 10),
      data: data,
      nextDueDate: nextDueDate,
      syncStatus: isOnline ? 'synced' : 'pending',
    );

    await _box.put(id, entry);

    if (isOnline) {
      try {
        await _db
            .collection('tracker_entries')
            .doc(id)
            .set(entry.toFirestore());
      } catch (_) {
        entry.syncStatus = 'pending';
        await entry.save();
      }
    }

    return entry;
  }

  List<TrackerEntryModel> getForPatient(String patientId, String type) =>
      _box.values
          .where((e) => e.patientId == patientId && e.type == type)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  Stream<QuerySnapshot> streamForPatient(String patientId, String type) =>
      _db
          .collection('tracker_entries')
          .where('patient_id', isEqualTo: patientId)
          .where('type', isEqualTo: type)
          .orderBy('entry_date', descending: true)
          .snapshots();
}

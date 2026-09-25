import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/encounter_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/models/tracker_entry_model.dart';
import '../constants/hive_constants.dart';
import 'connectivity_service.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  // Auto-sync whenever connectivity is restored
  ref.listen<bool>(isOnlineProvider, (prev, isOnline) {
    if (isOnline && prev == false) {
      service.syncAll();
    }
  });
  return service;
});

final pendingSyncCountProvider = Provider<int>((ref) {
  final box = Hive.box(HiveConstants.pendingSyncBox);
  return box.length;
});

final lastSyncedProvider = Provider<DateTime?>((ref) {
  final box = Hive.box(HiveConstants.settingsBox);
  final ts = box.get(HiveConstants.lastSyncedKey) as String?;
  return ts != null ? DateTime.tryParse(ts) : null;
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

// ─── Service ─────────────────────────────────────────────────────────────────

class SyncService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  SyncService(this._ref);

  Future<void> syncAll() async {
    final isOnline = _ref.read(isOnlineProvider);
    if (!isOnline) return;

    _ref.read(isSyncingProvider.notifier).state = true;

    try {
      await _syncPatients();
      await _syncEncounters();
      await _syncTrackers();

      // Record last synced time
      final box = Hive.box(HiveConstants.settingsBox);
      await box.put(
          HiveConstants.lastSyncedKey, DateTime.now().toIso8601String());
    } finally {
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  Future<void> _syncPatients() async {
    final box = Hive.box<PatientModel>(HiveConstants.patientBox);
    final pending = box.values
        .where((p) => p.syncStatus == 'pending')
        .toList();

    for (final patient in pending) {
      try {
        await _db
            .collection('patients')
            .doc(patient.patientId)
            .set(patient.toFirestore(), SetOptions(merge: true));
        patient.syncStatus = 'synced';
        await patient.save();
      } catch (_) {
        // Leave as pending; will retry on next sync
      }
    }
  }

  Future<void> _syncEncounters() async {
    final box = Hive.box<EncounterModel>(HiveConstants.encounterBox);
    final pending = box.values
        .where((e) => e.syncStatus == 'pending')
        .toList();

    for (final encounter in pending) {
      try {
        await _db
            .collection('encounters')
            .doc(encounter.encounterId)
            .set(encounter.toFirestore(), SetOptions(merge: true));
        encounter.syncStatus = 'synced';
        await encounter.save();
      } catch (_) {}
    }
  }

  Future<void> _syncTrackers() async {
    final box = Hive.box<TrackerEntryModel>(HiveConstants.trackerBox);
    final pending = box.values
        .where((t) => t.syncStatus == 'pending')
        .toList();

    for (final entry in pending) {
      try {
        await _db
            .collection('tracker_entries')
            .doc(entry.entryId)
            .set(entry.toFirestore(), SetOptions(merge: true));
        entry.syncStatus = 'synced';
        await entry.save();
      } catch (_) {}
    }
  }

  /// Returns count of all pending-sync items across all boxes
  int get pendingCount {
    final patients = Hive.box<PatientModel>(HiveConstants.patientBox)
        .values
        .where((p) => p.syncStatus == 'pending')
        .length;
    final encounters = Hive.box<EncounterModel>(HiveConstants.encounterBox)
        .values
        .where((e) => e.syncStatus == 'pending')
        .length;
    final trackers = Hive.box<TrackerEntryModel>(HiveConstants.trackerBox)
        .values
        .where((t) => t.syncStatus == 'pending')
        .length;
    return patients + encounters + trackers;
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/encounter_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/models/tracker_entry_model.dart';

class HiveConstants {
  HiveConstants._();

  // Box names
  static const String encounterBox = 'encounters';
  static const String patientBox = 'patients';
  static const String trackerBox = 'tracker_entries';
  static const String settingsBox = 'settings';
  static const String pendingSyncBox = 'pending_sync';

  // Settings keys
  static const String languageKey = 'language_code';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String lastSyncedKey = 'last_synced';

  // Type IDs for Hive adapters
  static const int encounterTypeId = 0;
  static const int patientLocalTypeId = 1;
  static const int trackerEntryTypeId = 2;
  static const int vitalsTypeId = 3;
  static const int symptomInputTypeId = 4;
  static const int pendingSyncItemTypeId = 5;

  static Future<void> openBoxes() async {
    // Open typed boxes to prevent "already open as Box<dynamic>" errors
    await Hive.openBox(settingsBox); // Box<dynamic> for settings
    await Hive.openBox(pendingSyncBox); // Box<dynamic> for sync queue
    await Hive.openBox<EncounterModel>(encounterBox); // Typed box
    await Hive.openBox<PatientModel>(patientBox); // Typed box
    await Hive.openBox<TrackerEntryModel>(trackerBox); // Typed box
  }
}

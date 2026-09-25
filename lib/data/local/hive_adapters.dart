import 'package:hive/hive.dart';
import '../models/patient_model.dart';
import '../models/encounter_model.dart';
import '../models/tracker_entry_model.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(EncounterModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PatientModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TrackerEntryModelAdapter());
  }
}

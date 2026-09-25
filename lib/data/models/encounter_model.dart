import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'encounter_model.g.dart';

@HiveType(typeId: HiveConstants.encounterTypeId)
class EncounterModel extends HiveObject {
  @HiveField(0)
  String encounterId;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  String workerId;

  @HiveField(3)
  String timestamp; // ISO 8601

  @HiveField(4)
  Map<String, dynamic> vitals;

  @HiveField(5)
  Map<String, dynamic> symptomInput;

  @HiveField(6)
  String? locationLat;

  @HiveField(7)
  String? locationLng;

  @HiveField(8)
  String syncStatus; // pending | synced

  @HiveField(9)
  String? triageSeverity; // green | yellow | red | critical

  @HiveField(10)
  String? notes;

  EncounterModel({
    required this.encounterId,
    required this.patientId,
    required this.workerId,
    required this.timestamp,
    this.vitals = const {},
    this.symptomInput = const {},
    this.locationLat,
    this.locationLng,
    this.syncStatus = 'pending',
    this.triageSeverity,
    this.notes,
  });

  Map<String, dynamic> toFirestore() => {
        'encounter_id': encounterId,
        'patient_id': patientId,
        'worker_id': workerId,
        'timestamp': timestamp,
        'vitals': vitals,
        'symptom_input': symptomInput,
        'location': {
          'lat': locationLat,
          'lng': locationLng,
        },
        'sync_status': 'synced',
        'triage_severity': triageSeverity,
        'notes': notes,
      };

  factory EncounterModel.fromFirestore(Map<String, dynamic> doc) =>
      EncounterModel(
        encounterId: doc['encounter_id'] ?? '',
        patientId: doc['patient_id'] ?? '',
        workerId: doc['worker_id'] ?? '',
        timestamp: doc['timestamp'] ?? '',
        vitals: Map<String, dynamic>.from(doc['vitals'] ?? {}),
        symptomInput: Map<String, dynamic>.from(doc['symptom_input'] ?? {}),
        locationLat: doc['location']?['lat'],
        locationLng: doc['location']?['lng'],
        syncStatus: 'synced',
        triageSeverity: doc['triage_severity'],
        notes: doc['notes'],
      );
}

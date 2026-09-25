import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'tracker_entry_model.g.dart';

enum TrackerType {
  menstrual,
  pregnancy,
  childVaccination,
  vaccination,
}

@HiveType(typeId: HiveConstants.trackerEntryTypeId)
class TrackerEntryModel extends HiveObject {
  @HiveField(0)
  String entryId;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  String type; // menstrual | pregnancy | child_vaccination | vaccination

  @HiveField(3)
  String entryDate;

  @HiveField(4)
  Map<String, dynamic> data;

  @HiveField(5)
  String? nextDueDate;

  @HiveField(6)
  String syncStatus;

  TrackerEntryModel({
    required this.entryId,
    required this.patientId,
    required this.type,
    required this.entryDate,
    this.data = const {},
    this.nextDueDate,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toFirestore() => {
        'entry_id': entryId,
        'patient_id': patientId,
        'type': type,
        'entry_date': entryDate,
        'data': data,
        'next_due_date': nextDueDate,
        'sync_status': 'synced',
      };

  factory TrackerEntryModel.fromFirestore(Map<String, dynamic> doc) =>
      TrackerEntryModel(
        entryId: doc['entry_id'] ?? '',
        patientId: doc['patient_id'] ?? '',
        type: doc['type'] ?? '',
        entryDate: doc['entry_date'] ?? '',
        data: Map<String, dynamic>.from(doc['data'] ?? {}),
        nextDueDate: doc['next_due_date'],
        syncStatus: 'synced',
      );
}

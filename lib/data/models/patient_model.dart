import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'patient_model.g.dart';

@HiveType(typeId: HiveConstants.patientLocalTypeId)
class PatientModel extends HiveObject {
  @HiveField(0)
  String patientId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dob; // ISO date string yyyy-MM-dd

  @HiveField(3)
  String gender; // male | female | other

  @HiveField(4)
  String phone;

  @HiveField(5)
  String languagePref;

  @HiveField(6)
  Map<String, bool> consentFlags;

  @HiveField(7)
  bool isAbhaRegistered;

  @HiveField(8)
  String? abhaId;

  @HiveField(9)
  String? tempId; // generated offline

  @HiveField(10)
  String syncStatus; // pending | synced

  @HiveField(11)
  String? address;

  PatientModel({
    required this.patientId,
    required this.name,
    required this.dob,
    required this.gender,
    required this.phone,
    this.languagePref = 'en',
    this.consentFlags = const {},
    this.isAbhaRegistered = false,
    this.abhaId,
    this.tempId,
    this.syncStatus = 'pending',
    this.address,
  });

  Map<String, dynamic> toFirestore() => {
        'patient_id': patientId,
        'name': name,
        'dob': dob,
        'gender': gender,
        'phone': phone,
        'language_pref': languagePref,
        'consent_flags': consentFlags,
        'is_abha_registered': isAbhaRegistered,
        'abha_id': abhaId,
        'temp_id': tempId,
        'sync_status': 'synced',
        'address': address,
      };

  factory PatientModel.fromFirestore(Map<String, dynamic> doc) => PatientModel(
        patientId: doc['patient_id'] ?? '',
        name: doc['name'] ?? '',
        dob: doc['dob'] ?? '',
        gender: doc['gender'] ?? '',
        phone: doc['phone'] ?? '',
        languagePref: doc['language_pref'] ?? 'en',
        consentFlags: Map<String, bool>.from(doc['consent_flags'] ?? {}),
        isAbhaRegistered: doc['is_abha_registered'] ?? false,
        abhaId: doc['abha_id'],
        tempId: doc['temp_id'],
        syncStatus: 'synced',
        address: doc['address'],
      );

  String get displayId => abhaId ?? tempId ?? patientId;
}

class PrescriptionModel {
  final String prescriptionId;
  final String encounterId;
  final String doctorId;
  final List<Map<String, dynamic>> medicines;
  final String dosageInstructions;
  final String issuedDate;

  const PrescriptionModel({
    required this.prescriptionId,
    required this.encounterId,
    required this.doctorId,
    required this.medicines,
    required this.dosageInstructions,
    required this.issuedDate,
  });

  factory PrescriptionModel.fromFirestore(Map<String, dynamic> doc) =>
      PrescriptionModel(
        prescriptionId: doc['prescription_id'] ?? '',
        encounterId: doc['encounter_id'] ?? '',
        doctorId: doc['doctor_id'] ?? '',
        medicines: List<Map<String, dynamic>>.from(doc['medicines'] ?? []),
        dosageInstructions: doc['dosage_instructions'] ?? '',
        issuedDate: doc['issued_date'] ?? '',
      );

  Map<String, dynamic> toFirestore() => {
        'prescription_id': prescriptionId,
        'encounter_id': encounterId,
        'doctor_id': doctorId,
        'medicines': medicines,
        'dosage_instructions': dosageInstructions,
        'issued_date': issuedDate,
      };
}

/// Single medicine entry within a prescription
class MedicineEntry {
  final String name;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String? notes;

  const MedicineEntry({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration_days': durationDays,
        'notes': notes,
      };

  factory MedicineEntry.fromMap(Map<String, dynamic> m) => MedicineEntry(
        name: m['name'] ?? '',
        dosage: m['dosage'] ?? '',
        frequency: m['frequency'] ?? '',
        durationDays: (m['duration_days'] as num?)?.toInt() ?? 0,
        notes: m['notes'],
      );
}

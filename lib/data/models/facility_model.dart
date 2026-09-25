class FacilityModel {
  final String facilityId;
  final String name;
  final String type; // PHC | CHC | District Hospital | Sub-Centre
  final Map<String, double> location; // {lat, lng}
  final List<String> services;
  final Map<String, int> medicineStock; // medicine name -> quantity
  final List<String> diagnosticCapability;

  const FacilityModel({
    required this.facilityId,
    required this.name,
    required this.type,
    required this.location,
    required this.services,
    required this.medicineStock,
    required this.diagnosticCapability,
  });

  factory FacilityModel.fromFirestore(Map<String, dynamic> doc) =>
      FacilityModel(
        facilityId: doc['facility_id'] ?? '',
        name: doc['name'] ?? '',
        type: doc['type'] ?? '',
        location: Map<String, double>.from(doc['location'] ?? {}),
        services: List<String>.from(doc['services'] ?? []),
        medicineStock: Map<String, int>.from(doc['medicine_stock'] ?? {}),
        diagnosticCapability:
            List<String>.from(doc['diagnostic_capability'] ?? []),
      );

  Map<String, dynamic> toFirestore() => {
        'facility_id': facilityId,
        'name': name,
        'type': type,
        'location': location,
        'services': services,
        'medicine_stock': medicineStock,
        'diagnostic_capability': diagnosticCapability,
      };
}

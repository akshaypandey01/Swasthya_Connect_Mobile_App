class FrontlineWorkerModel {
  final String workerId;
  final String name;
  final String role; // asha | anm | health_supervisor
  final String assignedFacilityId;
  final String? phone;
  final String? visitType; // field_visit | center_visit

  const FrontlineWorkerModel({
    required this.workerId,
    required this.name,
    required this.role,
    required this.assignedFacilityId,
    this.phone,
    this.visitType,
  });

  factory FrontlineWorkerModel.fromFirestore(Map<String, dynamic> doc) =>
      FrontlineWorkerModel(
        workerId: doc['worker_id'] ?? '',
        name: doc['name'] ?? '',
        role: doc['role'] ?? '',
        assignedFacilityId: doc['assigned_facility_id'] ?? '',
        phone: doc['phone'],
        visitType: doc['visit_type'],
      );

  Map<String, dynamic> toFirestore() => {
        'worker_id': workerId,
        'name': name,
        'role': role,
        'assigned_facility_id': assignedFacilityId,
        'phone': phone,
        'visit_type': visitType,
      };
}

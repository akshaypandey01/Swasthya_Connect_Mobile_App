class EmergencyAlertModel {
  final String alertId;
  final String encounterId;
  final Map<String, double> location;
  final String status; // triggered | dispatched | resolved
  final String triggeredAt;
  final String? resolvedAt;

  const EmergencyAlertModel({
    required this.alertId,
    required this.encounterId,
    required this.location,
    required this.status,
    required this.triggeredAt,
    this.resolvedAt,
  });

  factory EmergencyAlertModel.fromFirestore(Map<String, dynamic> doc) =>
      EmergencyAlertModel(
        alertId: doc['alert_id'] ?? '',
        encounterId: doc['encounter_id'] ?? '',
        location: Map<String, double>.from(doc['location'] ?? {}),
        status: doc['status'] ?? 'triggered',
        triggeredAt: doc['triggered_at'] ?? '',
        resolvedAt: doc['resolved_at'],
      );

  Map<String, dynamic> toFirestore() => {
        'alert_id': alertId,
        'encounter_id': encounterId,
        'location': location,
        'status': status,
        'triggered_at': triggeredAt,
        'resolved_at': resolvedAt,
      };
}

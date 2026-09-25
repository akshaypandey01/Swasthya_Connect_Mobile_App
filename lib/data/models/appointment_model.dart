class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String facilityId;
  final String doctorId;
  final String datetime;
  final int queueToken;
  final String status; // booked | checked_in | completed | cancelled

  const AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    required this.facilityId,
    required this.doctorId,
    required this.datetime,
    required this.queueToken,
    required this.status,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> doc) =>
      AppointmentModel(
        appointmentId: doc['appointment_id'] ?? '',
        patientId: doc['patient_id'] ?? '',
        facilityId: doc['facility_id'] ?? '',
        doctorId: doc['doctor_id'] ?? '',
        datetime: doc['datetime'] ?? '',
        queueToken: (doc['queue_token'] as num?)?.toInt() ?? 0,
        status: doc['status'] ?? 'booked',
      );

  Map<String, dynamic> toFirestore() => {
        'appointment_id': appointmentId,
        'patient_id': patientId,
        'facility_id': facilityId,
        'doctor_id': doctorId,
        'datetime': datetime,
        'queue_token': queueToken,
        'status': status,
      };
}

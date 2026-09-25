import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final appointmentRepositoryProvider =
    Provider<AppointmentRepository>((ref) => AppointmentRepository());

class AppointmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> bookAppointment({
    required String patientId,
    required String facilityId,
    required String doctorId,
    required String datetime,
  }) async {
    final id = const Uuid().v4();
    final tokenNumber = DateTime.now().millisecondsSinceEpoch % 100 + 1;
    final data = {
      'appointment_id': id,
      'patient_id': patientId,
      'facility_id': facilityId,
      'doctor_id': doctorId,
      'datetime': datetime,
      'queue_token': tokenNumber,
      'status': 'booked',
    };
    await _db.collection('appointments').doc(id).set(data);
    return id;
  }

  Stream<DocumentSnapshot> streamAppointment(String appointmentId) =>
      _db.collection('appointments').doc(appointmentId).snapshots();

  Stream<QuerySnapshot> streamPatientAppointments(String patientId) =>
      _db
          .collection('appointments')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('datetime', descending: true)
          .snapshots();
}

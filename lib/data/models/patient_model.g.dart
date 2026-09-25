// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build
// ignore_for_file: type=lint

part of 'patient_model.dart';

class PatientModelAdapter extends TypeAdapter<PatientModel> {
  @override
  final int typeId = 1;

  @override
  PatientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientModel(
      patientId: fields[0] as String,
      name: fields[1] as String,
      dob: fields[2] as String,
      gender: fields[3] as String,
      phone: fields[4] as String,
      languagePref: fields[5] as String,
      consentFlags: (fields[6] as Map).cast<String, bool>(),
      isAbhaRegistered: fields[7] as bool,
      abhaId: fields[8] as String?,
      tempId: fields[9] as String?,
      syncStatus: fields[10] as String,
      address: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PatientModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.patientId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dob)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.languagePref)
      ..writeByte(6)
      ..write(obj.consentFlags)
      ..writeByte(7)
      ..write(obj.isAbhaRegistered)
      ..writeByte(8)
      ..write(obj.abhaId)
      ..writeByte(9)
      ..write(obj.tempId)
      ..writeByte(10)
      ..write(obj.syncStatus)
      ..writeByte(11)
      ..write(obj.address);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

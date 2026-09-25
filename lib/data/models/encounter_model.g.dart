// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'encounter_model.dart';

class EncounterModelAdapter extends TypeAdapter<EncounterModel> {
  @override
  final int typeId = 0;

  @override
  EncounterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EncounterModel(
      encounterId: fields[0] as String,
      patientId: fields[1] as String,
      workerId: fields[2] as String,
      timestamp: fields[3] as String,
      vitals: (fields[4] as Map).cast<String, dynamic>(),
      symptomInput: (fields[5] as Map).cast<String, dynamic>(),
      locationLat: fields[6] as String?,
      locationLng: fields[7] as String?,
      syncStatus: fields[8] as String,
      triageSeverity: fields[9] as String?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EncounterModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.encounterId)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.workerId)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.vitals)
      ..writeByte(5)
      ..write(obj.symptomInput)
      ..writeByte(6)
      ..write(obj.locationLat)
      ..writeByte(7)
      ..write(obj.locationLng)
      ..writeByte(8)
      ..write(obj.syncStatus)
      ..writeByte(9)
      ..write(obj.triageSeverity)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncounterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

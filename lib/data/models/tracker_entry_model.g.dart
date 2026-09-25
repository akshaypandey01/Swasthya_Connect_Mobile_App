// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'tracker_entry_model.dart';

class TrackerEntryModelAdapter extends TypeAdapter<TrackerEntryModel> {
  @override
  final int typeId = 2;

  @override
  TrackerEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackerEntryModel(
      entryId: fields[0] as String,
      patientId: fields[1] as String,
      type: fields[2] as String,
      entryDate: fields[3] as String,
      data: (fields[4] as Map).cast<String, dynamic>(),
      nextDueDate: fields[5] as String?,
      syncStatus: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrackerEntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.entryId)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.entryDate)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.nextDueDate)
      ..writeByte(6)
      ..write(obj.syncStatus);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

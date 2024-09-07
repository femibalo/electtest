// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentItemAdapter extends TypeAdapter<EquipmentItem> {
  @override
  final int typeId = 1;

  @override
  EquipmentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentItem(
      id: fields[0] as int,
      equipmentId: fields[1] as String,
      classType: fields[2] as String,
      location: fields[3] as String,
      description: fields[4] as String,
      serialNo: fields[5] as String,
      voltage: fields[6] as String,
      rating: fields[7] as String,
      fuse: fields[8] as String,
      inspectionFrequency: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.equipmentId)
      ..writeByte(2)
      ..write(obj.classType)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.serialNo)
      ..writeByte(6)
      ..write(obj.voltage)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.fuse)
      ..writeByte(9)
      ..write(obj.inspectionFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_entity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillingEntityProfilesAdapter extends TypeAdapter<BillingEntityProfiles> {
  @override
  final int typeId = 6;

  @override
  BillingEntityProfiles read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillingEntityProfiles(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      logoURL: fields[3] as String,
      isDeleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BillingEntityProfiles obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.logoURL)
      ..writeByte(4)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingEntityProfilesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

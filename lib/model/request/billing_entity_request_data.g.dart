// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_entity_request_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillingEntityRequestDataAdapter
    extends TypeAdapter<BillingEntityRequestData> {
  @override
  final int typeId = 4;

  @override
  BillingEntityRequestData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillingEntityRequestData(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      logoURL: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BillingEntityRequestData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.logoURL);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingEntityRequestDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

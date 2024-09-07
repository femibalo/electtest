// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_request_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientRequestDataAdapter extends TypeAdapter<ClientRequestData> {
  @override
  final int typeId = 0;

  @override
  ClientRequestData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientRequestData(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      billingAddress: fields[4] as String,
      city: fields[5] as String,
      state: fields[6] as String,
      pinCode: fields[7] as String,
      billingPhoneNumber: fields[8] as String,
      displayName: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClientRequestData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.billingAddress)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
      ..write(obj.pinCode)
      ..writeByte(8)
      ..write(obj.billingPhoneNumber)
      ..writeByte(9)
      ..write(obj.displayName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientRequestDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

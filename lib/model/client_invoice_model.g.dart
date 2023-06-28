// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserClientInvoiceAdapter extends TypeAdapter<UserClientInvoice> {
  @override
  final int typeId = 7;

  @override
  UserClientInvoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserClientInvoice(
      id: fields[0] as int,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String,
      billingAddress: fields[4] as String,
      city: fields[5] as String,
      state: fields[6] as String,
      pinCode: fields[7] as String,
      billingPhoneNumber: fields[8] as String,
      displayName: fields[9] as String,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserClientInvoice obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
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
      ..write(obj.displayName)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserClientInvoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

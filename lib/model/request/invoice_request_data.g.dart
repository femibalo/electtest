// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_request_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceRequestDataAdapter extends TypeAdapter<InvoiceRequestData> {
  @override
  final int typeId = 1;

  @override
  InvoiceRequestData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceRequestData(
      id: fields[0] as int,
      profileID: fields[1] as int,
      clientID: fields[2] as int,
      items: (fields[3] as List).cast<UserBillProductItem>(),
      dueDate: fields[4] as String,
      invoiceDate: fields[5] as String,
      invoiceID: fields[6] as String,
      description: fields[7] as String,
      termsAndConditions: fields[8] as String,
      custom: (fields[9] as List).cast<InvoiceChargeModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceRequestData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileID)
      ..writeByte(2)
      ..write(obj.clientID)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.invoiceDate)
      ..writeByte(6)
      ..write(obj.invoiceID)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.termsAndConditions)
      ..writeByte(9)
      ..write(obj.custom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceRequestDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

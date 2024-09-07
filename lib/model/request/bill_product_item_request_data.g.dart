// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_product_item_request_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillProductItemRequestDataAdapter
    extends TypeAdapter<BillProductItemRequestData> {
  @override
  final int typeId = 3;

  @override
  BillProductItemRequestData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillProductItemRequestData(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as int,
      qty: fields[4] as int,
      currencyID: fields[5] as int,
      taxPercent: fields[6] as num,
      gstPercent: fields[7] as num,
      discountPercent: fields[8] as num,
    );
  }

  @override
  void write(BinaryWriter writer, BillProductItemRequestData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.qty)
      ..writeByte(5)
      ..write(obj.currencyID)
      ..writeByte(6)
      ..write(obj.taxPercent)
      ..writeByte(7)
      ..write(obj.gstPercent)
      ..writeByte(8)
      ..write(obj.discountPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillProductItemRequestDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

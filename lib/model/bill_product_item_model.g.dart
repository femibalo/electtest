// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_product_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserBillProductItemAdapter extends TypeAdapter<UserBillProductItem> {
  @override
  final int typeId = 5;

  @override
  UserBillProductItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserBillProductItem(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as int,
      qty: fields[4] as int,
      currencyID: fields[5] as int,
      currencyCode: fields[6] as String,
      taxPercent: fields[7] as num,
      gstPercent: fields[8] as num,
      discountPercent: fields[9] as num,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserBillProductItem obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.currencyCode)
      ..writeByte(7)
      ..write(obj.taxPercent)
      ..writeByte(8)
      ..write(obj.gstPercent)
      ..writeByte(9)
      ..write(obj.discountPercent)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBillProductItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

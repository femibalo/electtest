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
      equipmentId: fields[11] as String,
      location: fields[12] as String,
      serialNo: fields[13] as String,
      voltage: fields[14] as num,
      rating: fields[15] as num,
      fuse: fields[16] as num,
      inspectionFrequency: fields[17] as String,
      continuityTestGreyedOut: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserBillProductItem obj) {
    writer
      ..writeByte(19)
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
      ..write(obj.isDeleted)
      ..writeByte(11)
      ..write(obj.equipmentId)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.serialNo)
      ..writeByte(14)
      ..write(obj.voltage)
      ..writeByte(15)
      ..write(obj.rating)
      ..writeByte(16)
      ..write(obj.fuse)
      ..writeByte(17)
      ..write(obj.inspectionFrequency)
      ..writeByte(18)
      ..write(obj.continuityTestGreyedOut);
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_charge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceChargeModelAdapter extends TypeAdapter<InvoiceChargeModel> {
  @override
  final int typeId = 8;

  @override
  InvoiceChargeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceChargeModel(
      name: fields[0] as String,
      type: fields[1] as String,
      operation: fields[2] as String,
      value: fields[3] as num,
      isSelected: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceChargeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.operation)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceChargeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoicesAdapter extends TypeAdapter<Invoices> {
  @override
  final int typeId = 9;

  @override
  Invoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoices(
      id: fields[0] as int,
      orderID: fields[1] as int,
      status: fields[2] as int,
      currencyID: fields[3] as int,
      totalPrice: fields[4] as int,
      finalPrice: fields[5] as int,
      totalTaxPrice: fields[6] as int,
      totalGstPrice: fields[7] as int,
      totalDiscountPrice: fields[8] as int,
      clientID: fields[9] as int,
      dueDate: fields[10] as String,
      invoiceDate: fields[11] as String,
      invoiceID: fields[12] as String,
      description: fields[13] as String,
      paymentIdentifier: fields[14] as String,
      clientName: fields[15] as String,
      clientPhone: fields[16] as String,
      clientAddress: fields[17] as String,
      clientEmail: fields[18] as String,
      profileID: fields[19] as int,
      profileName: fields[20] as String,
      profileEmail: fields[21] as String,
      logoURL: fields[22] as String,
      currencyCode: fields[23] as String,
      paymentLink: fields[24] as String,
      details: fields[25] as String,
      items: (fields[26] as List).cast<UserBillProductItem>(),
      termsAndConditions: fields[28] as String,
      custom: (fields[27] as List).cast<InvoiceChargeModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, Invoices obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderID)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.currencyID)
      ..writeByte(4)
      ..write(obj.totalPrice)
      ..writeByte(5)
      ..write(obj.finalPrice)
      ..writeByte(6)
      ..write(obj.totalTaxPrice)
      ..writeByte(7)
      ..write(obj.totalGstPrice)
      ..writeByte(8)
      ..write(obj.totalDiscountPrice)
      ..writeByte(9)
      ..write(obj.clientID)
      ..writeByte(10)
      ..write(obj.dueDate)
      ..writeByte(11)
      ..write(obj.invoiceDate)
      ..writeByte(12)
      ..write(obj.invoiceID)
      ..writeByte(13)
      ..write(obj.description)
      ..writeByte(14)
      ..write(obj.paymentIdentifier)
      ..writeByte(15)
      ..write(obj.clientName)
      ..writeByte(16)
      ..write(obj.clientPhone)
      ..writeByte(17)
      ..write(obj.clientAddress)
      ..writeByte(18)
      ..write(obj.clientEmail)
      ..writeByte(19)
      ..write(obj.profileID)
      ..writeByte(20)
      ..write(obj.profileName)
      ..writeByte(21)
      ..write(obj.profileEmail)
      ..writeByte(22)
      ..write(obj.logoURL)
      ..writeByte(23)
      ..write(obj.currencyCode)
      ..writeByte(24)
      ..write(obj.paymentLink)
      ..writeByte(25)
      ..write(obj.details)
      ..writeByte(26)
      ..write(obj.items)
      ..writeByte(27)
      ..write(obj.custom)
      ..writeByte(28)
      ..write(obj.termsAndConditions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DueDateAdapter extends TypeAdapter<DueDate> {
  @override
  final int typeId = 10;

  @override
  DueDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DueDate(
      time: fields[0] as String,
      valid: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DueDate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.valid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DueDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceDetailModelAdapter extends TypeAdapter<InvoiceDetailModel> {
  @override
  final int typeId = 11;

  @override
  InvoiceDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceDetailModel(
      id: fields[0] as int,
      orderID: fields[1] as int,
      status: fields[2] as String,
      statusInt: fields[3] as int,
      currencyID: fields[4] as int,
      profile: fields[5] as BillingEntityProfiles,
      client: fields[6] as UserClientInvoice,
      totalPrice: fields[7] as int,
      finalPrice: fields[8] as int,
      totalTaxPrice: fields[9] as int,
      totalGstPrice: fields[10] as int,
      totalDiscountPrice: fields[11] as int,
      dueDate: fields[12] as String,
      description: fields[14] as String,
      termsAndConditions: fields[15] as String,
      invoiceDate: fields[13] as String,
      custom: (fields[16] as List).cast<InvoiceChargeModel>(),
      paymentLink: fields[17] as String,
      invoiceID: fields[18] as String,
      paymentIdentifier: fields[19] as String,
      editable: fields[20] as bool,
      details: (fields[21] as List).cast<UserBillProductItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceDetailModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderID)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.statusInt)
      ..writeByte(4)
      ..write(obj.currencyID)
      ..writeByte(5)
      ..write(obj.profile)
      ..writeByte(6)
      ..write(obj.client)
      ..writeByte(7)
      ..write(obj.totalPrice)
      ..writeByte(8)
      ..write(obj.finalPrice)
      ..writeByte(9)
      ..write(obj.totalTaxPrice)
      ..writeByte(10)
      ..write(obj.totalGstPrice)
      ..writeByte(11)
      ..write(obj.totalDiscountPrice)
      ..writeByte(12)
      ..write(obj.dueDate)
      ..writeByte(13)
      ..write(obj.invoiceDate)
      ..writeByte(14)
      ..write(obj.description)
      ..writeByte(15)
      ..write(obj.termsAndConditions)
      ..writeByte(16)
      ..write(obj.custom)
      ..writeByte(17)
      ..write(obj.paymentLink)
      ..writeByte(18)
      ..write(obj.invoiceID)
      ..writeByte(19)
      ..write(obj.paymentIdentifier)
      ..writeByte(20)
      ..write(obj.editable)
      ..writeByte(21)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

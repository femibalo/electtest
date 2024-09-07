import 'package:hive/hive.dart';

part 'invoice_charge_model.g.dart';

@HiveType(typeId:8)
class InvoiceChargeModel {
  @HiveField(0)
  String name;
  @HiveField(1)
  String type;
  @HiveField(2)
  String operation;
  @HiveField(3)
  num value;
  @HiveField(4)
  bool isSelected;

  InvoiceChargeModel({
    this.name = "",
    this.type = "",
    this.operation = "",
    this.value = 0,
    this.isSelected = false,
  });
}

class InvoiceChargeValueTypeModel {
  String title;
  String value;

  InvoiceChargeValueTypeModel({
    this.title = "",
    this.value = "",
  });
}

class InvoiceChargeOperationTypeModel {
  String title;
  String value;

  InvoiceChargeOperationTypeModel({
    this.title = "",
    this.value = "",
  });
}


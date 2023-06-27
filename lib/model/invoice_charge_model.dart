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

  InvoiceChargeModel fromJson(Map<String, dynamic> json) {
    return InvoiceChargeModel(
      name: json['name'] ?? "",
      type: json['type'] ?? "",
      operation: json['operation'] ?? "",
      value: json['value'] ?? 0,
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['operation'] = operation;
    data['value'] = value;
    data['isSelected'] = isSelected;
    return data;
  }
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


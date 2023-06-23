class InvoiceChargeModel {
  String name;
  String type;
  String operation;
  num value;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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

  InvoiceChargeValueTypeModel fromJson(Map<String, dynamic> json) {
    return InvoiceChargeValueTypeModel(
      title: json['title'] ?? "",
      value: json['value'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

class InvoiceChargeOperationTypeModel {
  String title;
  String value;

  InvoiceChargeOperationTypeModel({
    this.title = "",
    this.value = "",
  });

  InvoiceChargeOperationTypeModel fromJson(Map<String, dynamic> json) {
    return InvoiceChargeOperationTypeModel(
      title: json['title'] ?? "",
      value: json['value'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}


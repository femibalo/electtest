import 'package:equatable/equatable.dart';

class UserBillProductItem extends Equatable{
  final int id;
  final String name;
  final String description;
  final int price;
  final int qty;
  final int currencyID;
  final String currencyCode;
  final num taxPercent;
  final num gstPercent;
  final num discountPercent;
  final bool isDeleted;

  UserBillProductItem({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.price = 0,
    this.qty = 0,
    this.currencyID = 0,
    this.currencyCode = "",
    this.taxPercent = 0,
    this.gstPercent = 0,
    this.discountPercent = 0,
    this.isDeleted = false,
  });

  static UserBillProductItem fromJson(Map<String, dynamic> json) {
    return UserBillProductItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? 0,
      qty: json['qty'] ?? 0,
      currencyID: json['currencyID'] ?? 0,
      currencyCode: json['currencyCode'] ?? "",
      taxPercent: json['taxPercent'] ?? 0,
      gstPercent: json['gstPercent'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['qty'] = qty;
    data['currencyID'] = currencyID;
    data['currencyCode'] = currencyCode;
    data['taxPercent'] = taxPercent;
    data['gstPercent'] = gstPercent;
    data['discountPercent'] = discountPercent;
    data['isDeleted'] = isDeleted;
    return data;
  }

  @override
  List<Object?> get props => [id,name,description,price,qty,currencyID,currencyCode,taxPercent,gstPercent,discountPercent,isDeleted];
}

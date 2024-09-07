import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'bill_product_item_model.g.dart';

@HiveType(typeId: 5)
// ignore: must_be_immutable
class UserBillProductItem extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int price;
  @HiveField(4)
  int qty;
  @HiveField(5)
  final int currencyID;
  @HiveField(6)
  final String currencyCode;
  @HiveField(7)
  final num taxPercent;
  @HiveField(8)
  final num gstPercent;
  @HiveField(9)
  final num discountPercent;
  @HiveField(10)
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

  UserBillProductItem copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    int? qty,
    int? currencyID,
    String? currencyCode,
    num? taxPercent,
    num? gstPercent,
    num? discountPercent,
    bool? isDeleted,
  }) {
    return UserBillProductItem(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        qty: qty ?? this.qty,
        currencyID: currencyID ?? this.currencyID,
        currencyCode: currencyCode ?? this.currencyCode,
        taxPercent: taxPercent ?? this.taxPercent,
        gstPercent: gstPercent ?? this.gstPercent,
        discountPercent: discountPercent ?? this.discountPercent);
  }

  Map<String, dynamic> toJson() {
    // ignore: prefer_collection_literals
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
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        qty,
        currencyID,
        currencyCode,
        taxPercent,
        gstPercent,
        discountPercent,
        isDeleted
      ];
}

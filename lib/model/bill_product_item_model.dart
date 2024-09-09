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

  // New fields
  @HiveField(11)
  final String equipmentId;
  @HiveField(12)
  final String location;
  @HiveField(13)
  final String serialNo;
  @HiveField(14)
  final num voltage;
  @HiveField(15)
  final num rating;
  @HiveField(16)
  final num fuse;
  @HiveField(17)
  final String inspectionFrequency;
  @HiveField(18)
  final bool continuityTestGreyedOut;

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
    // Initialize new fields
    this.equipmentId = "",
    this.location = "",
    this.serialNo = "",
    this.voltage = 0,
    this.rating = 0,
    this.fuse = 0,
    this.inspectionFrequency = "",
    this.continuityTestGreyedOut = false,
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
      // Map new fields
      equipmentId: json['equipmentId'] ?? "",
      location: json['location'] ?? "",
      serialNo: json['serialNo'] ?? "",
      voltage: json['voltage'] ?? 0,
      rating: json['rating'] ?? 0,
      fuse: json['fuse'] ?? 0,
      inspectionFrequency: json['inspectionFrequency'] ?? "",
      continuityTestGreyedOut: json['continuityTestGreyedOut'] ?? false,
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
    // New fields
    String? equipmentId,
    String? location,
    String? serialNo,
    num? voltage,
    num? rating,
    num? fuse,
    String? inspectionFrequency,
    bool? continuityTestGreyedOut,
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
      discountPercent: discountPercent ?? this.discountPercent,
      isDeleted: isDeleted ?? this.isDeleted,
      // New fields
      equipmentId: equipmentId ?? this.equipmentId,
      location: location ?? this.location,
      serialNo: serialNo ?? this.serialNo,
      voltage: voltage ?? this.voltage,
      rating: rating ?? this.rating,
      fuse: fuse ?? this.fuse,
      inspectionFrequency: inspectionFrequency ?? this.inspectionFrequency,
      continuityTestGreyedOut: continuityTestGreyedOut ?? this.continuityTestGreyedOut,
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
    // Map new fields
    data['equipmentId'] = equipmentId;
    data['location'] = location;
    data['serialNo'] = serialNo;
    data['voltage'] = voltage;
    data['rating'] = rating;
    data['fuse'] = fuse;
    data['inspectionFrequency'] = inspectionFrequency;
    data['continuityTestGreyedOut'] = continuityTestGreyedOut;
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
        isDeleted,
        // New fields
        equipmentId,
        location,
        serialNo,
        voltage,
        rating,
        fuse,
        inspectionFrequency,
        continuityTestGreyedOut,
      ];
}

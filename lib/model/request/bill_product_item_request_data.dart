import 'package:hive/hive.dart';

part 'bill_product_item_request_data.g.dart';

@HiveType(typeId:3)
class BillProductItemRequestData {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  int price;
  @HiveField(4)
  int qty;
  @HiveField(5)
  int currencyID;
  @HiveField(6)
  num taxPercent;
  @HiveField(7)
  num gstPercent;
  @HiveField(8)
  num discountPercent;

  BillProductItemRequestData({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.price = 0,
    this.qty = 0,
    this.currencyID = 0,
    this.taxPercent = 0,
    this.gstPercent = 0,
    this.discountPercent = 0,
  });

  Map<String, dynamic> toJson() => {
          "id": id,
          "name": name,
          "description": description,
          "price": price,
          "currencyID": currencyID,
          "taxPercent": taxPercent,
          "gstPercent": gstPercent,
          "discountPercent": discountPercent
      };
}

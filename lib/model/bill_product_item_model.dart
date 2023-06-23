class BillProductItemModel {
  BillProductItemData data;

  BillProductItemModel({required this.data});

  static BillProductItemModel fromJson(Map<String, dynamic> json) {
    return BillProductItemModel(
      data: json['data'] == null
          ? BillProductItemData()
          : BillProductItemData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['data'] = this.data.toJson();
    return data;
  }
}

class BillProductItemData {
  List<UserBillProductItem> userItems;
  bool hasNext;

  BillProductItemData({
    this.userItems = const [],
    this.hasNext = false,
  });

  static BillProductItemData fromJson(Map<String, dynamic> json) {
    List<UserBillProductItem> userItems = [];
    if (json['userItems'] == null) {
      userItems = [];
    } else {
      json['userItems'].forEach((v) {
        userItems.add(UserBillProductItem.fromJson(v));
      });
    }
    return BillProductItemData(
      hasNext: json['hasNext'] ?? false,
      userItems: userItems,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['userItems'] = userItems.map((v) => v.toJson()).toList();
    data['hasNext'] = hasNext;
    return data;
  }
}

class UserBillProductItem {
  int id;
  String name;
  String description;
  int price;
  int qty;
  int currencyID;
  String currencyCode;
  num taxPercent;
  num gstPercent;
  num discountPercent;
  bool isDeleted;

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
}

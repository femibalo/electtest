
class BillProductItemRequestData {
  int id;
  String name;
  String description;
  int price;
  int qty;
  int currencyID;
  num taxPercent;
  num gstPercent;
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

import '../bill_product_item_model.dart';
import '../invoice_charge_model.dart';

class InvoiceRequestData {
  int ID;
  int profileID;
  int clientID;
  List<UserBillProductItem> items;
  String dueDate;
  String invoiceDate;
  String invoiceID;
  String description;
  String termsAndConditions;
  List<InvoiceChargeModel> custom;

  InvoiceRequestData({
    this.ID = 0,
    this.profileID = 0,
    this.clientID = 0,
    this.items = const [],
    this.dueDate = "",
    this.invoiceDate = "",
    this.invoiceID = "",
    this.description = "",
    this.termsAndConditions = "",
    this.custom = const [],
  });

  Map<String, dynamic> toJson() => {
          "ID": ID,
          "profileID": profileID,
          "clientID": clientID,
          "items": items.toList(),
          "dueDate": dueDate,
          "invoiceDate": invoiceDate,
          "invoiceID": invoiceID,
          "description": description,
          "termsAndConditions": termsAndConditions,
          "custom": custom.toList(),
      };
}

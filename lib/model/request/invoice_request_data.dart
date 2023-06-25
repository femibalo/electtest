import '../bill_product_item_model.dart';
import '../invoice_charge_model.dart';

class InvoiceRequestData {
  int id;
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
    this.id = 0,
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
}

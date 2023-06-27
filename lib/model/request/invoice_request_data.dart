import 'package:hive/hive.dart';
import '../bill_product_item_model.dart';
import '../invoice_charge_model.dart';

part 'invoice_request_data.g.dart';

@HiveType(typeId:1)
class InvoiceRequestData {
  @HiveField(0)
  int id;
  @HiveField(1)
  int profileID;
  @HiveField(2)
  int clientID;
  @HiveField(3)
  List<UserBillProductItem> items;
  @HiveField(4)
  String dueDate;
  @HiveField(5)
  String invoiceDate;
  @HiveField(6)
  String invoiceID;
  @HiveField(7)
  String description;
  @HiveField(8)
  String termsAndConditions;
  @HiveField(9)
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

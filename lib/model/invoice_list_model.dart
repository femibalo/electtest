import 'package:hive/hive.dart';
import 'bill_product_item_model.dart';
import 'billing_entity_model.dart';
import 'client_invoice_model.dart';
import 'invoice_charge_model.dart';

part 'invoice_list_model.g.dart';

@HiveType(typeId: 9)
class Invoices {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int orderID;
  @HiveField(2)
  int status;
  @HiveField(3)
  final int currencyID;
  @HiveField(4)
  final int totalPrice;
  @HiveField(5)
  final int finalPrice;
  @HiveField(6)
  final int totalTaxPrice;
  @HiveField(7)
  final int totalGstPrice;
  @HiveField(8)
  final int totalDiscountPrice;
  @HiveField(9)
  final int clientID;
  @HiveField(10)
  final String dueDate;
  @HiveField(11)
  final String invoiceDate;
  @HiveField(12)
  final String invoiceID;
  @HiveField(13)
  final String description;
  @HiveField(14)
  final String paymentIdentifier;
  @HiveField(15)
  final String clientName;
  @HiveField(16)
  final String clientPhone;
  @HiveField(17)
  final String clientAddress;
  @HiveField(18)
  final String clientEmail;
  @HiveField(19)
  final int profileID;
  @HiveField(20)
  final String profileName;
  @HiveField(21)
  final String profileEmail;
  @HiveField(22)
  final String logoURL;
  @HiveField(23)
  final String currencyCode;
  @HiveField(24)
  final String paymentLink;
  @HiveField(25)
  final String details;
  @HiveField(26)
  final List<UserBillProductItem> items;
  @HiveField(27)
  final List<InvoiceChargeModel> custom;
  @HiveField(28)
  final String termsAndConditions;

  Invoices({
    this.id = 0,
    this.orderID = 0,
    this.status = 0,
    this.currencyID = 0,
    this.totalPrice = 0,
    this.finalPrice = 0,
    this.totalTaxPrice = 0,
    this.totalGstPrice = 0,
    this.totalDiscountPrice = 0,
    this.clientID = 0,
    required this.dueDate,
    this.invoiceDate = "",
    this.invoiceID = "",
    this.description = "",
    this.paymentIdentifier = "",
    this.clientName = "",
    this.clientPhone = "",
    this.clientAddress = "",
    this.clientEmail = "",
    this.profileID = 0,
    this.profileName = "",
    this.profileEmail = "",
    this.logoURL = "",
    this.currencyCode = "",
    this.paymentLink = "",
    this.details = "",
    this.items = const [],
    this.termsAndConditions = "",
    this.custom = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['orderID'] = orderID;
    data['status'] = status;
    data['currencyID'] = currencyID;
    data['totalPrice'] = totalPrice;
    data['finalPrice'] = finalPrice;
    data['totalTaxPrice'] = totalTaxPrice;
    data['totalGstPrice'] = totalGstPrice;
    data['totalDiscountPrice'] = totalDiscountPrice;
    data['clientID'] = clientID;
    data['dueDate'] = dueDate;
    data['invoiceDate'] = invoiceDate;
    data['invoiceID'] = invoiceID;
    data['description'] = description;
    data['paymentIdentifier'] = paymentIdentifier;
    data['clientName'] = clientName;
    data['clientPhone'] = clientPhone;
    data['clientAddress'] = clientAddress;
    data['clientEmail'] = clientEmail;
    data['profileID'] = profileID;
    data['profileName'] = profileName;
    data['profileEmail'] = profileEmail;
    data['logoURL'] = logoURL;
    data['currencyCode'] = currencyCode;
    data['items'] = items;
    data['charges'] = custom;
    data['termsAndCondition'] = termsAndConditions;
    return data;
  }
}

@HiveType(typeId: 10)
class DueDate {
  @HiveField(0)
  final String time;
  @HiveField(1)
  final bool valid;

  const DueDate({
    this.time = "",
    this.valid = false,
  });
}

@HiveType(typeId: 11)
class InvoiceDetailModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  int orderID;
  @HiveField(2)
  String status;
  @HiveField(3)
  int statusInt;
  @HiveField(4)
  int currencyID;
  @HiveField(5)
  BillingEntityProfiles profile;
  @HiveField(6)
  UserClientInvoice client;
  @HiveField(7)
  int totalPrice;
  @HiveField(8)
  int finalPrice;
  @HiveField(9)
  int totalTaxPrice;
  @HiveField(10)
  int totalGstPrice;
  @HiveField(11)
  int totalDiscountPrice;
  @HiveField(12)
  String dueDate;
  @HiveField(13)
  String invoiceDate;
  @HiveField(14)
  String description;
  @HiveField(15)
  String termsAndConditions;
  @HiveField(16)
  List<InvoiceChargeModel> custom;
  @HiveField(17)
  String paymentLink;
  @HiveField(18)
  String invoiceID;
  @HiveField(19)
  String paymentIdentifier;
  @HiveField(20)
  bool editable;
  @HiveField(21)
  List<UserBillProductItem> details;

  InvoiceDetailModel({
    this.id = 0,
    this.orderID = 0,
    this.status = "",
    this.statusInt = 0,
    this.currencyID = 0,
    this.profile = const BillingEntityProfiles(),
    this.client = const UserClientInvoice(),
    this.totalPrice = 0,
    this.finalPrice = 0,
    this.totalTaxPrice = 0,
    this.totalGstPrice = 0,
    this.totalDiscountPrice = 0,
    this.dueDate = "",
    this.description = "",
    this.termsAndConditions = "",
    this.invoiceDate = "",
    this.custom = const [],
    this.paymentLink = "",
    this.invoiceID = "",
    this.paymentIdentifier = "",
    this.editable = false,
    this.details = const [],
  });
}

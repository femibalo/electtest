import 'bill_product_item_model.dart';
import 'billing_entity_model.dart';
import 'client_invoice_model.dart';
import 'invoice_charge_model.dart';

class Invoices {
  final int id;
  final int orderID;
  int status;
  final int currencyID;
  final int totalPrice;
  final int finalPrice;
  final int totalTaxPrice;
  final int totalGstPrice;
  final int totalDiscountPrice;
  final int clientID;
  final DueDate dueDate;
  final String invoiceDate;
  final String invoiceID;
  final String description;
  final String paymentIdentifier;
  final String clientName;
  final String clientPhone;
  final String clientAddress;
  final String clientEmail;
  final int profileID;
  final String profileName;
  final String profileEmail;
  final String logoURL;
  final String currencyCode;
  final String paymentLink;
  final String details;

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
  });
}

class DueDate {
  final String time;
  final bool valid;

  const DueDate({
    this.time = "",
    this.valid = false,
  });
}

class InvoiceDetailModel {
  int id;
  int orderID;
  String status;
  int statusInt;
  int currencyID;
  BillingEntityProfiles profile;
  UserClientInvoice client;
  int totalPrice;
  int finalPrice;
  int totalTaxPrice;
  int totalGstPrice;
  int totalDiscountPrice;
  String dueDate;
  String invoiceDate;
  String description;
  String termsAndConditions;
  List<InvoiceChargeModel> custom;
  String paymentLink;
  String invoiceID;
  String paymentIdentifier;
  bool editable;
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

import 'bill_product_item_model.dart';
import 'billing_entity_model.dart';
import 'client_invoice_model.dart';
import 'invoice_charge_model.dart';

class InvoiceListModel {
  final InvoiceData data;

  const InvoiceListModel({
    this.data = const InvoiceData(),
  });

  static InvoiceListModel fromJson(Map<String, dynamic> json) {
    return InvoiceListModel(
      data: json['data'] != null
          ? InvoiceData.fromJson(json['data'])
          : const InvoiceData(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['data'] = this.data.toJson();
    return data;
  }
}

class InvoiceData {
  final List<Invoices> invoices;
  final bool hasNext;

  const InvoiceData({
    this.invoices = const [],
    this.hasNext = false,
  });

  static InvoiceData fromJson(Map<String, dynamic> json) {
    List<Invoices> invoices = [];
    if (json['invoices'] == null) {
      invoices = [];
    } else {
      json['invoices'].forEach((v) {
        invoices.add(Invoices.fromJson(v));
      });
    }
    return InvoiceData(
      invoices: invoices,
      hasNext: json['hasNext'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['invoices'] = invoices.map((v) => v.toJson()).toList();
    data['hasNext'] = hasNext;
    return data;
  }
}

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
  final String desription;
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
  final Null details;

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
    this.desription = "",
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
    this.details,
  });

  static Invoices fromJson(Map<String, dynamic> json) {
    return Invoices(
      id: json['id'] ?? 0,
      orderID: json['orderID'] ?? 0,
      status: json['status'] ?? 0,
      currencyID: json['currencyID'] ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      totalTaxPrice: json['totalTaxPrice'] ?? 0,
      totalGstPrice: json['totalGstPrice'] ?? 0,
      totalDiscountPrice: json['totalDiscountPrice'] ?? 0,
      clientID: json['clientID'] ?? 0,
      dueDate: DueDate.fromJson(json['dueDate']),
      invoiceDate: json['invoiceDate'] ?? "",
      invoiceID: json['invoiceID'] ?? "",
      desription: json['desription'] ?? "",
      paymentIdentifier: json['paymentIdentifier'] ?? "",
      clientName: json['clientName'] ?? "",
      clientPhone: json['clientPhone'] ?? "",
      clientAddress: json['clientAddress'] ?? "",
      clientEmail: json['clientEmail'] ?? "",
      profileID: json['profileID'] ?? 0,
      profileName: json['profileName'] ?? "",
      profileEmail: json['profileEmail'] ?? "",
      logoURL: json['logoURL'] ?? "",
      currencyCode: json['currencyCode'] ?? "",
      paymentLink: json['paymentLink'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    data['desription'] = desription;
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
    data['paymentLink'] = paymentLink;
    return data;
  }
}

class DueDate {
  final String time;
  final bool valid;

  const DueDate({
    this.time = "",
    this.valid = false,
  });

  static DueDate fromJson(Map<String, dynamic> json) {
    return DueDate(
      time: json['Time'],
      valid: json['Valid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Time'] = time;
    data['Valid'] = valid;
    return data;
  }
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

  InvoiceDetailModel fromJson(Map<String, dynamic> json) {
    List<InvoiceChargeModel> customs = [];
    List<UserBillProductItem> itemDetails = [];
    if (json['custom'] == null) {
      customs = [];
    } else {
      json['custom'].forEach((v) {
        customs.add(InvoiceChargeModel().fromJson(v));
      });
    }

    if (json['details'] == null) {
      itemDetails = [];
    } else {
      json['details'].forEach((v) {
        itemDetails.add(UserBillProductItem.fromJson(v));
      });
    }
    return InvoiceDetailModel(
      id: json['id'] ?? 0,
      orderID: json['orderID'] ?? 0,
      status: json['status'] ?? "",
      statusInt: json['statusInt'] ?? 0,
      currencyID: json['currencyID'] ?? 0,
      profile: json['profile'] != null
          ? BillingEntityProfiles.fromJson(json['profile'])
          : const BillingEntityProfiles(),
      client: json['client'] != null
          ? UserClientInvoice.fromJson(json['client'])
          : const UserClientInvoice(),
      totalPrice: json['totalPrice'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      totalTaxPrice: json['totalTaxPrice'] ?? 0,
      totalGstPrice: json['totalGstPrice'] ?? 0,
      totalDiscountPrice: json['total_discount_price'] ?? 0,
      dueDate: json['dueDate'] ?? "",
      description: json['description'] ?? "",
      termsAndConditions: json['termsAndConditions'] ?? "",
      invoiceDate: json['invoiceDate'] ?? "",
      custom: customs,
      paymentLink: json['paymentLink'] ?? "",
      invoiceID: json['invoiceID'] ?? "",
      paymentIdentifier: json['paymentIdentifier'] ?? "",
      editable: json['editable'] ?? false,
      details: itemDetails,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['orderID'] = orderID;
    data['status'] = status;
    data['statusInt'] = statusInt;
    data['currencyID'] = currencyID;
    data['profile'] = profile.toJson();
    data['client'] = client.toJson();
    data['totalPrice'] = totalPrice;
    data['finalPrice'] = finalPrice;
    data['totalTaxPrice'] = totalTaxPrice;
    data['totalGstPrice'] = totalGstPrice;
    data['total_discount_price'] = totalDiscountPrice;
    data['dueDate'] = dueDate;
    data['description'] = description;
    data['termsAndConditions'] = termsAndConditions;
    data['invoiceDate'] = invoiceDate;
    data['custom'] = custom.map((e) => e.toJson()).toList();
    data['paymentLink'] = paymentLink;
    data['invoiceID'] = invoiceID;
    data['paymentIdentifier'] = paymentIdentifier;
    data['editable'] = editable;
    data['details'] = details.map((e) => e.toJson()).toList();
    return data;
  }
}

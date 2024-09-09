import 'package:invoice_management/model/supplier.dart';
import 'customer.dart';
import 'bill_product_item_model.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<UserBillProductItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;
  // final String EquipmentIDNumber;
  // final String Location;
  // final int SerialNo;
  // final String FormalVisualInspectionByOccupant;
  // final String CombinedInspectionByAssessor;
  // final String PassFail;
  // final String SuitableForEnv;
  // final String SuitableForContinuedUse;
  // final String Comments;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
    // required this.EquipmentIDNumber,
    // required this.Location,
    // required this.SerialNo,
    // required this.FormalVisualInspectionByOccupant,
    // required this.CombinedInspectionByAssessor,
    // required this.PassFail,
    // required this.SuitableForEnv,
    // required this.SuitableForContinuedUse,
    // required this.Comments,
  });
}

class UserBillProductItem {
  final String description;
  // final DateTime date;
  // final int quantity;
  // final double vat;
  // final double discount;
  // final double unitPrice;
  final String EquipmentIDNumber;
  final String Location;
  final int SerialNo;
  final String FormalVisualInspectionByOccupant;
  final String CombinedInspectionByAssessor;
  final String PassFail;
  final String SuitableForEnv;
  final String SuitableForContinuedUse;
  final String Comments;

  const UserBillProductItem({
    required this.description,
    // required this.date,
    // required this.quantity,
    // required this.vat,
    // required this.discount,
    // required this.unitPrice,
    required this.EquipmentIDNumber,
    required this.Location,
    required this.SerialNo,
    required this.FormalVisualInspectionByOccupant,
    required this.CombinedInspectionByAssessor,
    required this.PassFail,
    required this.SuitableForEnv,
    required this.SuitableForContinuedUse,
    required this.Comments,
  });
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../model/bill_product_item_model.dart';
import '../model/billing_entity_model.dart';
import '../model/client_invoice_model.dart';
import '../model/invoice_charge_model.dart';
import '../model/invoice_list_model.dart';
import '../utils/utils.dart';

const String invoice = 'invoice';

class InvoicesProvider extends ChangeNotifier {
  final box = Hive.box<Invoices>(invoice);
  

  InvoicesProviderState state = InvoicesProviderState(
    billProductItem: [],
    selectedCharges: [],
    detailInvoiceForEdit: InvoiceDetailModel(),
  );

  Future<bool> saveData({
    required String invoiceName,
    required String description,
    required String termsAndConditions,
    required String currencyCode,
    required int finalPrice,
    required int totalPrice,
    required int totalTax,
    required int totalDiscount,
  }) async {
    try {
      Invoices invoices = Invoices(
        id: DateTime.now().millisecondsSinceEpoch,
        dueDate: state.isDueDateActive ? getDate(state.dueDate) : "",
        profileID: state.selectedBillingEntity.id,
        profileName: state.selectedBillingEntity.name,
        profileEmail: state.selectedBillingEntity.email,
        logoURL: state.selectedBillingEntity.logoURL,
        clientID: state.selectedClient.id,
        clientName: state.selectedClient.name,
        clientEmail: state.selectedClient.email,
        clientPhone: state.selectedClient.phone,
        clientAddress: state.selectedClient.billingAddress,
        items: state.billProductItem.toList(),
        invoiceDate: getDate(state.invoiceDate),
        termsAndConditions: termsAndConditions,
        currencyCode: currencyCode,
        finalPrice: finalPrice,
        totalPrice: totalPrice,
        totalTaxPrice: totalTax,
        totalDiscountPrice: totalDiscount,
        invoiceID: invoiceName,
        description: description,
        custom: state.selectedCharges
            .where((element) => element.isSelected == true)
            .toList(),
      );
      await box.add(invoices);
      getData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    state.loading = true;
    state.currentPage = 1;
    try {
      ///get invoice data
      state.invoiceListModel = box.values.toList();
    } catch (e) {
      if (e is IOException) {
        state.isNetworkError = true;
      } else {
        state.isError = true;
      }
    }
    state.loading = false;
    notifyListeners();
  }

  changeDate({required dynamic newDate, required isInvoiceDate}) {
    if (isInvoiceDate) {
      state.invoiceDate = newDate;
    } else {
      state.dueDate = newDate;
    }
    notifyListeners();
  }

  changeDueDateStatus(bool newValue) {
    state.isDueDateActive = newValue;
    notifyListeners();
  }

  changeSelectedClient(UserClientInvoice newValue) {
    state.selectedClient = newValue;
    notifyListeners();
  }

  changeSelectedEntity(BillingEntityProfiles newValue) {
    state.selectedBillingEntity = newValue;
    notifyListeners();
  }

  changeNotesActiveStatus(bool newValue) {
    state.isNotesActive = newValue;
    notifyListeners();
  }

  changeTermsConditionStatus(bool newValue) {
    state.isTermsConditionActive = newValue;
    notifyListeners();
  }

  int getIndexOfEntity(int id) {
    return state.invoiceListModel.indexWhere((element) => element.id == id);
  }

  Future<bool> delete(int id) async {
    try {
      ///delete
      await box.deleteAt(getIndexOfEntity(id));
      state.invoiceListModel.removeAt(getIndexOfEntity(id));
      notifyListeners();
    } catch (e) {
      if (e is IOException) {
        state.isNetworkError = true;
      } else {
        state.isError = true;
      }
    }
    state.loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> update(
      {required int id,
      required String invoiceName,
      required String description,
      required String termsAndConditions,
      required String currencyCode,
      required int finalPrice,
      required int totalPrice,
      required int totalTax,
      required int totalDiscount}) async {
    try {
      ///update invoice by invoiceId
      Invoices invoice = Invoices(
        id: DateTime.now().millisecondsSinceEpoch,
        dueDate: state.isDueDateActive ? getDate(state.dueDate) : "",
        profileID: state.selectedBillingEntity.id,
        profileName: state.selectedBillingEntity.name,
        profileEmail: state.selectedBillingEntity.email,
        logoURL: state.selectedBillingEntity.logoURL,
        clientID: state.selectedClient.id,
        clientName: state.selectedClient.name,
        clientEmail: state.selectedClient.email,
        clientPhone: state.selectedClient.phone,
        clientAddress: state.selectedClient.billingAddress,
        items: state.billProductItem.toList(),
        invoiceDate: getDate(state.invoiceDate),
        termsAndConditions: termsAndConditions,
        currencyCode: currencyCode,
        finalPrice: finalPrice,
        totalPrice: totalPrice,
        totalTaxPrice: totalTax,
        totalDiscountPrice: totalDiscount,
        invoiceID: invoiceName,
        description: description,
        custom: state.selectedCharges
            .where((element) => element.isSelected == true)
            .toList(),
      );
      await box.putAt(getIndexOfEntity(id), invoice);
      getData();
    } catch (e) {
      if (e is IOException) {
        state.isNetworkError = true;
      } else {
        state.isError = true;
      }
    }
    state.loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> markAsPaid(int id) async {
    try {
      ///mark invoice as paid
    } catch (e) {
      if (e is IOException) {
        state.isNetworkError = true;
      } else {
        state.isError = true;
      }
    }
    state.loading = false;
    notifyListeners();
    return false;
  }

  setSelectedBillProductItemsFromItemScreen(
      {required List<UserBillProductItem> newItems}) {
    state.billProductItem = [...newItems];
    notifyListeners();
  }

  setSelectedChargesFromItemScreen(
      {required List<InvoiceChargeModel> newCharges}) {
    state.selectedCharges = [...newCharges];
    notifyListeners();
  }

  void removeItemListWhere(int id) {
    state.invoiceListModel.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // we can use this function from Select Item Screen
  // this function can use if user have selected some item from Select Item Screen
  // and user decided to delete the item from Select Item Screen
  // so we need to remove related item from selectedBillProductItem also
  // because the deleted item is not exist anymore
  void removeBillProductItemWhere(int id) {
    state.billProductItem.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // we can use this from InvoiceChargesScreen after deleting or edit charges
  void changeFullSelectedChargesFromInvoiceChargesScreen(
      {required List<InvoiceChargeModel> newList}) {
    state.selectedCharges = [...newList];
    notifyListeners();
    calculate();
  }

  void reset() {
    state.subTotal = 0;
    state.tax = 0;
    state.discount = 0;
    state.finalPrice = 0;
  }

  calculate() async {
    if (state.billProductItem.isNotEmpty) {
      reset();
      try {
        ///calculate price
        state.billProductItem.map((e) {
          double discount = (e.discountPercent / 100) * (e.qty * e.price);
          double tax = (e.taxPercent / 100) * ((e.qty * e.price) - discount);
          int subTotalPerItem = (e.price * e.qty);
          state.subTotal += subTotalPerItem;
          state.tax += tax.round();
          state.discount += discount.round();
          state.finalPrice = state.subTotal + tax.round() - discount.round();
        }).toList();
        for (InvoiceChargeModel charge in state.selectedCharges) {
          double crg = 0;
          if (charge.type == 'percent') {
            crg = (charge.value / 100) * state.subTotal;
            if (charge.operation == '+') {
              state.finalPrice += crg.round();
            } else {
              state.finalPrice -= crg.round();
            }
          } else {
            if (charge.operation == '+') {
              state.finalPrice += charge.value.round();
            } else {
              state.finalPrice -= charge.value.round();
            }
          }
        }
        notifyListeners();
      } catch (e) {
        if (e is IOException) {
          state.isNetworkError = true;
        } else {
          state.isError = true;
        }
      }
      state.loading = false;
      notifyListeners();
    } else {
      state.subTotal = 0;
      state.tax = 0;
      state.discount = 0;
      state.finalPrice = 0;
      notifyListeners();
    }
  }
}

class InvoicesProviderState {
  // Switch states
  bool isSocketOutletActive = false;
  bool isPlugActive = false;
  bool isFlexActive = false;
  bool isBodyActive = false;
  bool isOtherFaultyActive = false;
  bool isPolarityTicked = false;

  bool isError;
  bool loading;
  bool empty;
  bool isNetworkError;
  bool isDueDateActive;
  bool isNotesActive;
  bool isTermsConditionActive;
  List<Invoices> invoiceListModel;
  BillingEntityProfiles selectedBillingEntity;
  UserClientInvoice selectedClient;
  List<InvoiceChargeModel> selectedCharges;
  List<UserBillProductItem> billProductItem;
  String searchQuery;
  String invoiceName;
  DateTime invoiceDate;
  DateTime dueDate;
  int subTotal;
  int tax;
  int discount;
  int finalPrice;
  int currentPage;
  bool isAfterSearch;
  InvoiceDetailModel detailInvoiceForEdit;

  InvoicesProviderState({
    this.isError = false,
    this.isNetworkError = false,
    this.loading = true,
    this.empty = true,
    this.isDueDateActive = false,
    this.isNotesActive = false,
    this.isTermsConditionActive = false,
    this.invoiceListModel = const [],
    this.searchQuery = "",
    this.invoiceName = "",
    this.selectedBillingEntity = const BillingEntityProfiles(),
    this.selectedClient = const UserClientInvoice(),
    required this.billProductItem,
    required this.selectedCharges,
    required this.detailInvoiceForEdit,
    DateTime? invoiceDate,
    DateTime? dueDate,
    this.subTotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.finalPrice = 0,
    this.currentPage = 1,
    this.isAfterSearch = false,
  })  : invoiceDate = invoiceDate ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now().add(const Duration(days: 30));
}

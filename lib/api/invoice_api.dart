import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/bill_product_item_model.dart';
import '../model/billing_entity_model.dart';
import '../model/client_invoice_model.dart';
import '../model/invoice_charge_model.dart';
import '../model/invoice_list_model.dart';

class InvoicesProvider extends ChangeNotifier {
  InvoicesProviderState state = InvoicesProviderState(
    billProductItem: [],
    selectedCharges: [],
    detailInvoiceForEdit: InvoiceDetailModel(),
  );

  Future<bool> saveData({
    required int id,
    required int profileID,
    required String invoiceName,
    required String description,
    required String termsAndConditions,
  }) async {
    try {
      ///store invoice data
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
    } catch (e) {

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


  setSelectedBillProductItemsFromItemScreen({required List<UserBillProductItem> newItems}) {
    state.billProductItem = [...newItems];
    notifyListeners();
  }

  setSelectedChargesFromItemScreen({required List<InvoiceChargeModel> newCharges}) {
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

  calculate() async {
    if (state.billProductItem.isNotEmpty) {
      Map<String, dynamic> form = {
        "items": state.billProductItem.toList(),
        "custom": state.selectedCharges
            .where((element) => element.isSelected == true)
            .toList(),
      };
      try {
        ///calculate price
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

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/bill_product_item_model.dart';
import '../model/currency_model.dart';

class InvoiceItemProvider extends ChangeNotifier {
  InvoiceItemState states = InvoiceItemState(
    currencies: [],
    selectedCurrency: CurrencyModel(),
    selectedDetailItem: UserBillProductItem(),
    selectedItems: [], billProductItems: [],
  );

  Future<bool> saveData({
    required int id,
    required String name,
    required String description,
    required int price,
    required int qty,
    required int currencyID,
    required num taxPercent,
    required num gstPercent,
    required num discountPercent,
  }) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    states.loading = true;
    try {

    } catch (e) {
      if (e is IOException) {
        states.isNetworkError = true;
      } else {
        states.isError = true;
      }
    }
    states.loading = false;
    notifyListeners();
  }


  Future<void> getCurrencies() async {
    states.loading = true;
    try {

    } catch (e) {
      if (e is IOException) {
        states.isNetworkError = true;
      } else {
        states.isError = true;
      }
    }
    states.loading = false;
    notifyListeners();
  }

  changeSelectedCurrency(CurrencyModel data) {
    states.selectedCurrency = data;
    notifyListeners();
  }

  Future<bool> deleteItem({required int itemId}) async {
    try {

    } catch (e) {
      if (e is IOException) {
        states.isNetworkError = true;
      } else {
        states.isError = true;
      }
    }
    states.loading = false;
    notifyListeners();
    return false;
  }

  setSelectedItemsFromAddInvoiceScreen(
      List<UserBillProductItem> itemsFromAddInvoiceScreen) {
    states.selectedItems.clear();
    for (var element in itemsFromAddInvoiceScreen) {
      states.selectedItems.add(UserBillProductItem.fromJson(element.toJson()));
    }
    notifyListeners();
    calculate();
  }

  increaseItemQty(int itemId) {
    if (states.selectedItems.any((element) => element.id == itemId)) {
      states.selectedItems.singleWhere((element) => element.id == itemId).qty++;
    } else {
      states.selectedItems.add(states.billProductItems.singleWhere((element) => element.id == itemId));
      states.selectedItems.singleWhere((element) => element.id == itemId).qty++;
    }
    notifyListeners();
    calculate();
  }

  decreaseItemQty(int itemId) {
    if (states.selectedItems.any((element) => element.id == itemId) &&
        states.selectedItems
                .singleWhere((element) => element.id == itemId)
                .qty >
            0) {
      states.selectedItems.singleWhere((element) => element.id == itemId).qty--;
      if (states.selectedItems
              .singleWhere((element) => element.id == itemId)
              .qty ==
          0) {
        states.selectedItems.removeWhere((element) => element.id == itemId);
      }
    } else {
      states.selectedItems.removeWhere((element) => element.id == itemId);
    }
    notifyListeners();
    calculate();
  }

  calculate() async {
    if (states.selectedItems.isNotEmpty) {
      Map<String, dynamic> form = {
        "items": states.selectedItems.toList(),
        "custom": [],
      };
      try {

      } catch (e) {
        if (e is IOException) {
          states.isNetworkError = true;
        } else {
          states.isError = true;
        }
      }
      states.loading = false;
      notifyListeners();
    } else {
      states.subTotal = 0;
      states.tax = 0;
      states.discount = 0;
      states.finalPrice = 0;
      notifyListeners();
    }
  }
}

class InvoiceItemState {
  bool isError;
  bool loading;
  bool empty;
  bool isNetworkError;
  String searchQuery;
  int currentPage;
  int subTotal;
  int tax;
  int discount;
  int finalPrice;
  bool isAfterSearch;
  UserBillProductItem selectedDetailItem;
  List<UserBillProductItem> selectedItems;
  List<UserBillProductItem> billProductItems;
  CurrencyModel selectedCurrency;
  List<CurrencyModel> currencies;

  InvoiceItemState({
    this.isError = false,
    this.isNetworkError = false,
    this.loading = true,
    this.empty = true,
    this.searchQuery = "",
    this.currentPage = 1,
    this.subTotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.finalPrice = 0,
    this.isAfterSearch = false,
    required this.selectedDetailItem,
    required this.selectedItems,
    required this.billProductItems,
    required this.selectedCurrency,
    required this.currencies,
  });
}

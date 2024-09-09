import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:invoice_management/isolate/currenciry_isolate.dart';
import '../model/bill_product_item_model.dart';
import '../model/currency_model.dart';

const String billProductItems = 'billProductItems';

class InvoiceItemProvider extends ChangeNotifier {
  final box = Hive.box<UserBillProductItem>(billProductItems);
  InvoiceItemState state = InvoiceItemState(
    currencies: [],
    selectedCurrency: CurrencyModel(),
    selectedDetailItem: UserBillProductItem(),
    selectedItems: [],
    billProductItems: [],
  );

  InvoiceItemProvider() {
    currencyIsolate();
    currenciesReceivePort.listen((message) {
      state.currencies = message as List<CurrencyModel>;
      state.selectedCurrency = state.currencies.first;
      notifyListeners();
    });
  }

  Future<bool> saveData({
    required String name,
    required String description,
    required String equipmentId,
    required String location,
    required String serialNo,
    required num voltage,
    required num rating,
    required num fuse,
    required String inspectionFrequency,
    required bool continuityTestGreyedOut, // Logic for Continuity Test
   
  }) async {
    try {
      UserBillProductItem userBillProductItem = UserBillProductItem(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        description: description,
        // New fields
        equipmentId: equipmentId,
        location: location,
        serialNo: serialNo,
        voltage: voltage,
        rating: rating,
        fuse: fuse,
        inspectionFrequency: inspectionFrequency,
        continuityTestGreyedOut: continuityTestGreyedOut,
     
      );
      await box.add(userBillProductItem);
      state.selectedItems.add(userBillProductItem);
      getData();
      // calculate();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    state.loading = true;
    try {
      state.billProductItems = box.values.toList();
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

  Future<void> getCurrencies() async {
    state.loading = true;
    try {} catch (e) {
      if (e is IOException) {
        state.isNetworkError = true;
      } else {
        state.isError = true;
      }
    }
    state.loading = false;
    notifyListeners();
  }

  Future<void> updateItemEntity(UserBillProductItem newEntity) async {
    state.chooseItems = newEntity;
    await box.putAt(getIndexOfEntity(newEntity.id), newEntity);
    state.billProductItems[getIndexOfEntity(newEntity.id)] = newEntity;
    notifyListeners();
  }

  void removeEntity(int index) async {
    await box.deleteAt(index);
    notifyListeners();
  }

  int getIndexOfEntity(int entityId) {
    return state.billProductItems
        .indexWhere((element) => element.id == entityId);
  }

  changeSelectedCurrency(CurrencyModel data) {
    state.selectedCurrency = data;
    notifyListeners();
  }

  Future<bool> deleteItem({required int itemId}) async {
    try {
      removeEntity(getIndexOfEntity(itemId));
      state.billProductItems.removeAt(getIndexOfEntity(itemId));
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

  setSelectedItemsFromAddInvoiceScreen(
      List<UserBillProductItem> itemsFromAddInvoiceScreen) {
    state.selectedItems.clear();
    for (var item in itemsFromAddInvoiceScreen) {
      state.selectedItems.add(UserBillProductItem.fromJson(item.toJson()));
      if (!state.billProductItems.any((element) => element.id == item.id)) {
        box.add(item);
        getData();
      }
    }
    notifyListeners();
    calculate();
  }

  setItemToSelectedItems(UserBillProductItem item) {
    if (state.selectedItems.any((element) => element.id == item.id)) {
      state.selectedItems.removeWhere((element) => element.id == item.id);
    } else {
      state.selectedItems.add(item);
    }
    notifyListeners();
    calculate();
  }

  bool isItemSelected(UserBillProductItem item) {
    return state.selectedItems.any((element) => element.id == item.id);
  }

  increaseItemQty(int itemId) {
    if (state.billProductItems.any((element) => element.id == itemId)) {
      state.billProductItems
          .singleWhere((element) => element.id == itemId)
          .qty++;
    } else {
      state.billProductItems.add(state.billProductItems
          .singleWhere((element) => element.id == itemId));
      state.billProductItems
          .singleWhere((element) => element.id == itemId)
          .qty++;
    }
    calculate();
  }

  decreaseItemQty(int itemId) {
    if (state.billProductItems.any((element) => element.id == itemId) &&
        state.billProductItems
                .singleWhere((element) => element.id == itemId)
                .qty >
            0) {
      state.billProductItems
          .singleWhere((element) => element.id == itemId)
          .qty--;
      if (state.billProductItems
              .singleWhere((element) => element.id == itemId)
              .qty ==
          0) {
        box.deleteAt(getIndexOfEntity(itemId));
        getData();
      }
    } else {
      state.selectedItems.removeWhere((element) => element.id == itemId);
    }
    calculate();
  }

  calculate() async {
    state.subTotal = 0;
    state.tax = 0;
    state.discount = 0;
    state.finalPrice = 0;
    try {
      state.selectedItems.map((e) {
        double discount = (e.discountPercent / 100) * (e.qty * e.price);
        double tax = (e.taxPercent / 100) * ((e.qty * e.price) - discount);
        int subTotalPerItem = (e.price * e.qty);
        state.subTotal += subTotalPerItem;
        state.tax += tax.round();
        state.discount += discount.round();
        state.finalPrice = state.subTotal + tax.round() - discount.round();
      }).toList();
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
  UserBillProductItem? chooseItems, selectedDetailItem;
  List<UserBillProductItem> selectedItems;
  List<UserBillProductItem> billProductItems;
  CurrencyModel selectedCurrency;
  List<CurrencyModel> currencies;
    // New fields
  String equipmentId;
  String location;
  String serialNo;
  num voltage;
  num rating;
  num fuse;
  String inspectionFrequency;
  bool continuityTestGreyedOut;

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
    this.chooseItems,
    required this.selectedDetailItem,
    required this.selectedItems,
    required this.billProductItems,
    required this.selectedCurrency,
    required this.currencies,
     // Initialize new fields
    this.equipmentId = "",
    this.location = "",
    this.serialNo = "",
    this.voltage = 0,
    this.rating = 0,
    this.fuse = 0,
    this.inspectionFrequency = "",
    this.continuityTestGreyedOut = false,
  });
}

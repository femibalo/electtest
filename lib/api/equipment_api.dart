import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:invoice_management/isolate/currenciry_isolate.dart';
import '../model/equipment_item_model.dart';
import '../model/currency_model.dart';

const String equipmentItemsBox = 'equipmentItems';

class EquipmentItemProvider extends ChangeNotifier {
  final box = Hive.box<EquipmentItem>(equipmentItemsBox);
  EquipmentItemState state = EquipmentItemState(
    currencies: [],
    selectedCurrency: CurrencyModel(),
    selectedDetailItem: EquipmentItem(),
    selectedItems: [],
    equipmentItems: [],
  );

  EquipmentItemProvider() {
    currencyIsolate();
    currenciesReceivePort.listen((message) {
      state.currencies = message as List<CurrencyModel>;
      state.selectedCurrency = state.currencies.first;
      notifyListeners();
    });
  }

  Future<bool> saveData({
    required String equipmentId,
    required String classType,
    required String location,
    required String description,
    required String serialNumber,
    required String voltage,
    required String rating,
    required String fuse,
    required String inspectionFrequency,
  }) async {
    try {
      EquipmentItem equipmentItem = EquipmentItem(
        id: DateTime.now().millisecondsSinceEpoch,
        equipmentId: equipmentId,
        classType: classType,
        location: location,
        description: description,
        serialNo: serialNumber,
        voltage: voltage,
        rating: rating,
        fuse: fuse,
        inspectionFrequency: inspectionFrequency,
      );
      await box.add(equipmentItem);
      state.selectedItems.add(equipmentItem);
      getData();
      calculate();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    state.loading = true;
    try {
      state.equipmentItems = box.values.toList();
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

  Future<void> updateItemEntity(EquipmentItem newEntity) async {
    state.selectedDetailItem = newEntity;
    await box.putAt(getIndexOfEntity(newEntity.id), newEntity);
    state.equipmentItems[getIndexOfEntity(newEntity.id)] = newEntity;
    notifyListeners();
  }

  void removeEntity(int index) async {
    await box.deleteAt(index);
    notifyListeners();
  }

  int getIndexOfEntity(int entityId) {
    return state.equipmentItems.indexWhere((element) => element.id == entityId);
  }

  changeSelectedCurrency(CurrencyModel data) {
    state.selectedCurrency = data;
    notifyListeners();
  }

  Future<bool> deleteItem({required int itemId}) async {
    try {
      removeEntity(getIndexOfEntity(itemId));
      state.equipmentItems.removeAt(getIndexOfEntity(itemId));
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

  setSelectedItemsFromAddEquipmentScreen(
      List<EquipmentItem> itemsFromAddEquipmentScreen) {
    state.selectedItems.clear();
    for (var item in itemsFromAddEquipmentScreen) {
      state.selectedItems.add(EquipmentItem.fromJson(item.toJson()));
      if (!state.equipmentItems.any((element) => element.id == item.id)) {
        box.add(item);
        getData();
      }
    }
    notifyListeners();
    calculate();
  }

  setItemToSelectedItems(EquipmentItem item) {
    if (state.selectedItems.any((element) => element.id == item.id)) {
      state.selectedItems.removeWhere((element) => element.id == item.id);
    } else {
      state.selectedItems.add(item);
    }
    notifyListeners();
    calculate();
  }

  bool isItemSelected(EquipmentItem item) {
    return state.selectedItems.any((element) => element.id == item.id);
  }

  increaseItemQty(int itemId) {
    // Implement quantity management if needed based on EquipmentItem properties
    calculate();
  }

  decreaseItemQty(int itemId) {
    // Implement quantity management if needed based on EquipmentItem properties
    calculate();
  }

  calculate() async {
    state.subTotal = 0;
    state.tax = 0;
    state.discount = 0;
    state.finalPrice = 0;
    try {
      // Update this logic according to the properties of EquipmentItem
      state.selectedItems.map((e) {
        // Example placeholder for calculations
        int subTotalPerItem = 0; // Replace with actual calculation logic
        state.subTotal += subTotalPerItem;
        state.tax += 0; // Replace with actual tax calculation
        state.discount += 0; // Replace with actual discount calculation
        state.finalPrice = state.subTotal + state.tax - state.discount;
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

class EquipmentItemState {
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
  EquipmentItem? selectedDetailItem;
  List<EquipmentItem> selectedItems;
  List<EquipmentItem> equipmentItems;
  CurrencyModel selectedCurrency;
  List<CurrencyModel> currencies;

  EquipmentItemState({
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
    this.selectedDetailItem,
    required this.selectedItems,
    required this.equipmentItems,
    required this.selectedCurrency,
    required this.currencies,
  });
}


import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/screens/analytics/model/currency_model.dart';
import 'package:mezink_app/screens/forgot-password/model/response_state.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:mezink_app/screens/invoices/model/request/bill_product_item_request_data.dart';
import 'package:mezink_app/screens/login/model/error.dart';
import 'package:mezink_app/utils/common/api.dart';
import 'package:mezink_app/utils/common/api_path.dart';

import '../../../utils/common/api_keys.dart';
import '../../../utils/common/app_keys.dart';

class InvoiceItemProvider extends ChangeNotifier {
  InvoiceItemState states = InvoiceItemState(
    billProductItemModel: BillProductItemModel(
      data: BillProductItemData(),
    ),
    currencies: [],
    selectedCurrency: CurrencyModel(),
    selectedDetailItem: UserBillProductItem(),
    selectedItems: [],
  );

  Future<ResponseState> saveData({
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
      var response = await apiPostRequest(
        path: APIPaths.invoiceItemsPublishPath,
        newOptions: BillProductItemRequestData(
          id: id,
          name: name,
          description: description,
          price: price,
          currencyID: currencyID,
          taxPercent: taxPercent,
          gstPercent: gstPercent,
          discountPercent: discountPercent,
        ).toJson(),
      );
      if (response.statusCode == 200) {
        if (id == 0) {
          // insert
          states.billProductItemModel.data.userItems.add(
            UserBillProductItem(
              id: response.data[APIKeys.data][APIKeys.id],
              name: name,
              description: description,
              price: price,
              qty: qty,
              currencyID: states.selectedCurrency.id,
              currencyCode: states.selectedCurrency.code,
              taxPercent: taxPercent,
              gstPercent: 0,
              discountPercent: discountPercent,
            ),
          );
        } else {
          // edit
          int selectedIndexItemEdited =
              states.billProductItemModel.data.userItems.indexWhere((element) {
            return element.id == id;
          });

          // update item in itemList
          states.billProductItemModel.data.userItems[selectedIndexItemEdited] =
              UserBillProductItem(
            id: id,
            name: name,
            description: description,
            price: price,
            qty: qty,
            currencyID: states.selectedCurrency.id,
            currencyCode: states.selectedCurrency.code,
            taxPercent: taxPercent,
            gstPercent: 0,
            discountPercent: discountPercent,
          );

          // update item in selectedItems if item is exist in selectedItems
          if (states.selectedItems.any((element) => element.id == id)) {
            int selectedIndexItemInSelectedItems =
                states.selectedItems.indexWhere((element) => element.id == id);
            states.selectedItems[selectedIndexItemInSelectedItems] =
                UserBillProductItem(
              id: id,
              name: name,
              description: description,
              price: price,
              qty: states.selectedItems
                  .singleWhere((element) => element.id == id)
                  .qty,
              currencyID: states.selectedCurrency.id,
              currencyCode: states.selectedCurrency.code,
              taxPercent: taxPercent,
              gstPercent: 0,
              discountPercent: discountPercent,
            );
            notifyListeners();
          }
          calculate();
        }
        notifyListeners();
        return ResponseState(
          success: true,
          data: response.data[APIKeys.data][APIKeys.id],
        );
      }
      return ResponseState(
        success: false,
        error: Errors.fromJson(response.data).detail,
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return ResponseState(
          success: false,
          error: S.current.check_internet,
        );
      } else {
        return ResponseState(
          success: false,
          error: S.current.something_went_wrong,
        );
      }
    }
  }

  Future<void> getData() async {
    states.loading = true;
    try {
      var response = await apiGetRequest(
        path: APIPaths.invoiceItemsListPath,
        queryParamsAsMap: {
          MConstants.page: 1,
          MConstants.searchTerms: states.searchQuery,
        },
      );
      if (response.statusCode == 200) {
        states.billProductItemModel =
            BillProductItemModel.fromJson(response.data);
        if (states.billProductItemModel.data.hasNext) {
          states.currentPage++;
        }
        notifyListeners();
      } else {
        states.isError = true;
      }
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

  Future<void> getMore() async {
    notifyListeners();
    if (states.billProductItemModel.data.hasNext) {
      try {
        var response = await apiGetRequest(
          path: APIPaths.invoiceItemsListPath,
          queryParamsAsMap: {
            MConstants.page: states.currentPage,
            MConstants.searchTerms: states.searchQuery,
          },
        );
        if (response.statusCode == 200) {
          // get full response from api
          BillProductItemModel resultGetMore =
              BillProductItemModel.fromJson(response.data);

          // checking if has next return true, current will increment
          if (resultGetMore.data.hasNext) {
            states.currentPage++;
          }
          // updating model with new value
          states.billProductItemModel = BillProductItemModel(
            data: BillProductItemData(
              // updating hasNext from resultGetMore
              hasNext: resultGetMore.data.hasNext,

              // keep old model list data
              userItems: states.billProductItemModel.data.userItems,
            ),
          );

          // adding new data from resultGetMore
          resultGetMore.data.userItems.forEach((element) {
            states.billProductItemModel.data.userItems.add(element);
          });
          notifyListeners();
        } else {
          states.isError = true;
        }
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
  }

  Future<bool> getDetailItem(int itemId) async {
    states.loading = true;
    try {
      var response = await apiGetRequest(
        path: APIPaths.invoiceItemsDetailPath,
        queryParamsAsMap: {
          APIKeys.itemId: itemId,
          MConstants.searchTerms: states.searchQuery,
        },
      );
      if (response.statusCode == 200) {
        states.loading = false;
        states.selectedDetailItem =
            UserBillProductItem.fromJson(response.data[APIKeys.data]);
        states.selectedCurrency = states.currencies.singleWhere(
            (element) => element.id == states.selectedDetailItem.currencyID);
        notifyListeners();
        return true;
      } else {
        states.isError = true;
        return false;
      }
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

  Future<void> getCurrencies() async {
    states.loading = true;
    try {
      var currenciesResponse = await apiGetRequest(
        path: APIPaths.currenciesListPath,
      );
      if (currenciesResponse.statusCode == 200) {
        states.currencies.clear();
        List results = currenciesResponse.data[APIKeys.data];
        for (var element in results) {
          states.currencies.add(CurrencyModel().fromJson(element));
        }
        states.selectedCurrency = states.currencies.first;
        notifyListeners();
      } else {
        states.isError = true;
      }
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
      Map<String, dynamic> form = {
        "ids": [itemId],
      };
      var response = await apiPostRequest(
        path: APIPaths.invoiceItemsDeletePath,
        newOptions: {
          "message": form,
        },
      );
      if (response.statusCode == 200) {
        states.billProductItemModel.data.userItems.singleWhere((element) {
          return element.id == itemId;
        }).isDeleted = true;
        notifyListeners();
        return true;
      } else {
        states.isError = true;
        return false;
      }
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
    itemsFromAddInvoiceScreen.forEach((element) {
      states.selectedItems.add(UserBillProductItem.fromJson(element.toJson()));
    });
    notifyListeners();
    calculate();
  }

  increaseItemQty(int itemId) {
    if (states.selectedItems.any((element) => element.id == itemId)) {
      states.selectedItems.singleWhere((element) => element.id == itemId).qty++;
    } else {
      states.selectedItems.add(states.billProductItemModel.data.userItems
          .singleWhere((element) => element.id == itemId));
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
        var response = await apiPostRequest(
          path: APIPaths.invoiceItemsCalculatePath,
          newOptions: {
            "message": form,
          },
        );
        if (response.statusCode == 200) {
          states.subTotal = response.data[APIKeys.data][APIKeys.totalPrice];
          states.tax = response.data[APIKeys.data][APIKeys.taxPrice];
          states.discount = response.data[APIKeys.data][APIKeys.discountPrice];
          states.finalPrice = response.data[APIKeys.data][APIKeys.finalPrice];
          notifyListeners();
        } else {
          states.isError = true;
        }
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
  BillProductItemModel billProductItemModel;
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
    required this.billProductItemModel,
    required this.selectedCurrency,
    required this.currencies,
  });
}

// ignore_for_file: prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/screens/forgot-password/model/response_state.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:mezink_app/screens/invoices/model/billing_entity_model.dart';
import 'package:mezink_app/screens/invoices/model/client_invoice_model.dart';
import 'package:mezink_app/screens/invoices/model/invoice_charge_model.dart';
import 'package:mezink_app/screens/invoices/model/invoice_list_model.dart';
import 'package:mezink_app/screens/invoices/model/request/invoice_request_data.dart';
import 'package:mezink_app/screens/login/model/error.dart';
import 'package:mezink_app/utils/common/api.dart';
import 'package:mezink_app/utils/common/api_keys.dart';
import 'package:mezink_app/utils/common/api_path.dart';
import 'package:mezink_app/utils/common/app_keys.dart';
import 'package:mezink_app/utils/common/utils.dart';

class InvoicesProvider extends ChangeNotifier {
  InvoicesProviderState state = InvoicesProviderState(
    billProductItem: [],
    selectedCharges: [],
    detailInvoiceForEdit: InvoiceDetailModel(),
  );

  Future<ResponseState> saveData({
    required int id,
    required int profileID,
    required String invoiceName,
    required String description,
    required String termsAndConditions,
  }) async {
    try {
      var response = await apiPostRequest(
        path:
            id == 0 ? APIPaths.publishInvoicePath : APIPaths.updateInvoicePath,
        newOptions: InvoiceRequestData(
          ID: id,
          profileID: state.selectedBillingEntity.id,
          clientID: state.selectedClient.id,
          items: state.billProductItem.toList(),
          dueDate: state.isDueDateActive ? getDate(state.dueDate) : "",
          invoiceDate: getDate(state.invoiceDate),
          invoiceID: invoiceName,
          description: description,
          termsAndConditions: termsAndConditions,
          custom: state.selectedCharges
              .where((element) => element.isSelected == true)
              .toList(),
        ).toJson(),
      );
      if (response.statusCode == 200) {
        getData();
        return ResponseState(success: true);
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
    state.loading = true;
    state.currentPage = 1;
    try {
      state.invoiceListModel = InvoiceListModel();
      var response = await apiGetRequest(
        path: APIPaths.invoiceListPath,
        queryParamsAsMap: {
          MConstants.page: state.currentPage,
          MConstants.searchTerms: state.searchQuery,
        },
      );
      if (response.statusCode == 200) {
        state.invoiceListModel = InvoiceListModel.fromJson(response.data);
        if (state.invoiceListModel.data.hasNext) {
          state.currentPage++;
        }
        notifyListeners();
      } else {
        state.isError = true;
      }
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

  Future<void> getMore() async {
    if (state.invoiceListModel.data.hasNext) {
      try {
        var response = await apiGetRequest(
          path: APIPaths.invoiceListPath,
          queryParamsAsMap: {
            MConstants.page: state.currentPage,
            MConstants.searchTerms: state.searchQuery,
          },
        );
        if (response.statusCode == 200) {
          // get full response from api
          InvoiceListModel resultGetMore =
              InvoiceListModel.fromJson(response.data);

          // checking if has next return true, current will increment
          if (resultGetMore.data.hasNext) {
            state.currentPage++;
          }
          // updating invoice list model with new value
          state.invoiceListModel = InvoiceListModel(
            data: InvoiceData(
              // updating hasNext from resultGetMore
              hasNext: resultGetMore.data.hasNext,

              // keep old invoices list data
              invoices: state.invoiceListModel.data.invoices,
            ),
          );

          // adding new invoices from resultGetMore
          resultGetMore.data.invoices.forEach((element) {
            state.invoiceListModel.data.invoices.add(element);
          });
          notifyListeners();
        } else {
          state.isError = true;
        }
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

  Future<void> getDefaultInvoice() async {
    state.loading = true;
    try {
      var response = await apiGetRequest(
        path: APIPaths.defaultInvoicePath,
      );
      if (response.statusCode == 200) {
        state.invoiceDate = DateFormat("yyyy-MM-dd")
            .parse(response.data[APIKeys.data][APIKeys.invoiceDate]);
        state.invoiceName = response.data[APIKeys.data][APIKeys.invoiceID];
        state.selectedBillingEntity = BillingEntityProfiles.fromJson(
            response.data[APIKeys.data][APIKeys.profile]);
        state.billProductItem.clear();
        state.selectedCharges.clear();
        state.selectedClient = UserClientInvoice();
        state.isTermsConditionActive = false;
      } else {
        state.isError = true;
      }
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

  Future<void> getDetailInvoice({required int invoiceID}) async {
    state.loading = true;
    state.billProductItem.clear();
    state.selectedCharges.clear();
    try {
      var response = await apiGetRequest(
        path: APIPaths.detailInvoicePath,
        queryParamsAsMap: {
          APIKeys.invoiceID: invoiceID,
        },
      );
      if (response.statusCode == 200) {
        state.detailInvoiceForEdit =
            InvoiceDetailModel().fromJson(response.data[APIKeys.data]);
        state.selectedBillingEntity = state.detailInvoiceForEdit.profile;
        state.selectedClient = state.detailInvoiceForEdit.client;
        state.billProductItem.addAll(state.detailInvoiceForEdit.details);
        state.selectedCharges.addAll(state.detailInvoiceForEdit.custom);
        state.selectedCharges.forEach((element) {
          element.isSelected = true;
        });
        calculate();
        notifyListeners();
      } else {
        state.isError = true;
      }
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

  Future<bool> markAsPaid(int id) async {
    try {
      var response = await apiPostRequest(
        path: APIPaths.settleInvoice,
        newOptions: {
          "message": {
            "ids": [id],
          },
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        state.isError = true;
        return false;
      }
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

  Future<bool> sendInvoiceReminder(String paymentIdentifier) async {
    try {
      var response = await apiGetRequest(
        path: APIPaths.sendInvoiceReminder,
        queryParamsAsMap: {
          MConstants.paymentIdentifier: paymentIdentifier,
        },
      );
      if (response.statusCode == 200) {
        if (response.data[APIKeys.data][APIKeys.success] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        state.isError = true;
        return false;
      }
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
    state.invoiceListModel.data.invoices
        .removeWhere((element) => element.id == id);
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
        var response = await apiPostRequest(
          path: APIPaths.invoiceItemsCalculatePath,
          newOptions: {
            "message": form,
          },
        );
        if (response.statusCode == 200) {
          state.subTotal = response.data[APIKeys.data][APIKeys.totalPrice];
          state.tax = response.data[APIKeys.data][APIKeys.taxPrice];
          state.discount = response.data[APIKeys.data][APIKeys.discountPrice];
          state.finalPrice = response.data[APIKeys.data][APIKeys.finalPrice];
          notifyListeners();
        } else {
          state.isError = true;
        }
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
  InvoiceListModel invoiceListModel;
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
    this.invoiceListModel = const InvoiceListModel(),
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
        dueDate = dueDate ?? DateTime.now().add(Duration(days: 30));
}

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../model/client_invoice_model.dart';

class ClientInvoiceProvider extends ChangeNotifier {
  ClientInvoiceState states = ClientInvoiceState();

  Future<ResponseState> saveData(
      {required int id,
      required String name,
      required String email,
      required String phone,
      required String billingAddress,
      required String city,
      required String state,
      required String pinCode,
      required String billingPhoneNumber,
      required String displayName}) async {
    try {
      var response = await apiPostRequest(
        path: APIPaths.publishClientInvoicePath,
        newOptions: ClientRequestData(
          id: id,
          name: name,
          email: email,
          phone: phone,
          billingAddress: billingAddress,
          city: city,
          state: state,
          pinCode: pinCode,
          billingPhoneNumber: billingPhoneNumber,
          displayName: displayName,
        ).toJson(),
      );
      if (response.statusCode == 200) {
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
    states.currentPage = 1;
    try {
      var response = await apiGetRequest(
        path: APIPaths.clientInvoicePath,
        queryParamsAsMap: {
          MConstants.page: states.currentPage,
          MConstants.searchTerms: states.searchQuery,
        },
      );
      if (response.statusCode == 200) {
        states.clientInvoiceModel = ClientInvoiceModel.fromJson(response.data);
        if (states.clientInvoiceModel.data.hasNext) {
          states.currentPage++;
        }
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
    if (states.clientInvoiceModel.data.hasNext) {
      try {
        var response = await apiGetRequest(
          path: APIPaths.clientInvoicePath,
          queryParamsAsMap: {
            MConstants.page: states.currentPage,
            MConstants.searchTerms: states.searchQuery,
          },
        );
        if (response.statusCode == 200) {
          // get full response from api
          ClientInvoiceModel resultGetMore =
              ClientInvoiceModel.fromJson(response.data);

          // checking if has next return true, current will increment
          if (resultGetMore.data.hasNext) {
            states.currentPage++;
          }
          // updating invoice list model with new value
          states.clientInvoiceModel = ClientInvoiceModel(
            data: ClientInvoiceData(
              // updating hasNext from resultGetMore
              hasNext: resultGetMore.data.hasNext,

              // keep old clients list data
              userClients: states.clientInvoiceModel.data.userClients,
            ),
          );

          // adding new client from resultGetMore
          resultGetMore.data.userClients.forEach((element) {
            states.clientInvoiceModel.data.userClients.add(element);
          });
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

  Future<bool> getDetailClient(int clientId) async {
    states.loading = true;
    try {
      var response = await apiGetRequest(
        path: APIPaths.detailClientInvoicePath,
        queryParamsAsMap: {
          APIKeys.clientId: clientId,
        },
      );
      if (response.statusCode == 200) {
        states.loading = false;
        states.selectedDetailClient =
            UserClientInvoice.fromJson(response.data[APIKeys.data]);
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

  changeSelectedClient(UserClientInvoice newClient) {
    states.selectedClient = newClient;
    notifyListeners();
  }

  Future<bool> deleteClient({required int clientId}) async {
    try {
      Map<String, dynamic> form = {
        "ids": [clientId],
      };
      var response = await apiPostRequest(
        path: APIPaths.clientInvoiceDeletePath,
        newOptions: {
          "message": form,
        },
      );
      if (response.statusCode == 200) {
        getData();
        states.selectedClient = const UserClientInvoice();
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

  changeStatusBillingAddress(bool newValue) {
    states.isAddBillingAddressActive = newValue;
    notifyListeners();
  }
}

class ClientInvoiceState {
  bool isError;
  bool loading;
  bool empty;
  bool isNetworkError;
  bool isAddBillingAddressActive;
  ClientInvoiceModel clientInvoiceModel;
  String searchQuery;
  UserClientInvoice selectedClient, selectedDetailClient;
  int currentPage;
  bool isAfterSearch;

  ClientInvoiceState({
    this.isError = false,
    this.isNetworkError = false,
    this.loading = true,
    this.empty = true,
    this.isAddBillingAddressActive = false,
    this.searchQuery = "",
    this.clientInvoiceModel = const ClientInvoiceModel(),
    this.selectedClient = const UserClientInvoice(),
    this.selectedDetailClient = const UserClientInvoice(),
    this.currentPage = 1,
    this.isAfterSearch = false,
  });
}

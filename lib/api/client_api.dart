import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/client_invoice_model.dart';

class ClientInvoiceProvider extends ChangeNotifier {
  ClientInvoiceState states = ClientInvoiceState();

  Future<bool> saveData(
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
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    states.loading = true;
    states.currentPage = 1;
    try {
     ///client list
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


  changeSelectedClient(UserClientInvoice newClient) {
    states.selectedClient = newClient;
    notifyListeners();
  }

  Future<bool> deleteClient({required int clientId}) async {
    try {
      ///delete client data
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
  List<UserClientInvoice> clientInvoices;
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
    this.clientInvoices = const [],
    this.selectedClient = const UserClientInvoice(),
    this.selectedDetailClient = const UserClientInvoice(),
    this.currentPage = 1,
    this.isAfterSearch = false,
  });
}

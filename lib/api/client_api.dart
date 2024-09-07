import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../model/client_invoice_model.dart';

const String clientInvoice = 'clientInvoice';

class ClientInvoiceProvider extends ChangeNotifier {
  ClientInvoiceState state = ClientInvoiceState();
  final box = Hive.box<UserClientInvoice>(clientInvoice);

  Future<bool> saveData({
      required String name,
      required String email,
      required String phone,
      required String billingAddress,
      required String city,
      required String stat,
      required String pinCode,
      required String billingPhoneNumber,
      required String displayName}) async {
    try {
      UserClientInvoice userClientInvoice = UserClientInvoice(id: DateTime.now().millisecondsSinceEpoch,name: name,email: email,phone: phone,city: city,state: stat,pinCode: pinCode,billingAddress: billingAddress,displayName: displayName,isBillingActive: state.isAddBillingAddressActive);
      await box.add(userClientInvoice);
      state.clientInvoices.add(userClientInvoice);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    state.loading = true;
    state.currentPage = 1;
    try {
     ///client list
      state.clientInvoices = box.values.toList();
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

  Future<void> updateEntity(UserClientInvoice newEntity) async {
    state.selectedClient = newEntity;
    await box.putAt(getIndexOfEntity(newEntity.id), newEntity);
    state.clientInvoices[getIndexOfEntity(newEntity.id)] = newEntity;
    notifyListeners();
  }

  void removeEntity(int index) async {
    await box.deleteAt(index);
    notifyListeners();
  }

  int getIndexOfEntity(int entityId) {
    return state.clientInvoices.indexWhere((element) => element.id == entityId);
  }


  changeSelectedClient(UserClientInvoice newClient) {
    state.selectedClient = newClient;
    notifyListeners();
  }

  Future<bool> deleteClient({required int clientId}) async {
    try {
      await box.deleteAt(getIndexOfEntity(clientId));
      state.clientInvoices.removeAt(getIndexOfEntity(clientId));
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

  changeStatusBillingAddress(bool newValue) {
    state.isAddBillingAddressActive = newValue;
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

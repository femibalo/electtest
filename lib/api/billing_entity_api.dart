import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../model/billing_entity_model.dart';

class BillingEntityProvider extends ChangeNotifier {
  BillingEntityState state = BillingEntityState();

  Future<bool> saveData({
    required int id,
    required String name,
    required String email,
  }) async {
    try {
      ///save billing data
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getData() async {
    state.loading = true;
    state.currentPage = 1;
    try {
      ///Billing dta
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


  changeSelectedEntity(BillingEntityProfiles newEntity) {
    state.selectedEntity = newEntity;
    notifyListeners();
  }

  Future<bool> deleteEntity({required int entityId}) async {
    try {
      ///delete billing data
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

  removeSelectedLogo() {
    state.selectedLogo = "";
    state.isLogoEmpty = true;
  }

  Future changeSelectedLogoAfterUploadLogo(fileToUpload) async {
    state.selectedLogo = fileToUpload.path;
    state.isLogoEmpty = false;
    notifyListeners();
  }
}

class BillingEntityState {
  bool isError;
  bool loading;
  bool empty;
  bool isNetworkError;
  bool isLogoEmpty;
  List<BillingEntityProfiles> billingEntities;
  String searchQuery;
  String selectedLogo;
  BillingEntityProfiles selectedEntity, selectedDetailEntity;
  int currentPage;
  bool isAfterSearch;

  BillingEntityState({
    this.isError = false,
    this.isNetworkError = false,
    this.loading = true,
    this.empty = true,
    this.isLogoEmpty = true,
    this.billingEntities = const [],
    this.searchQuery = "",
    this.selectedLogo = "",
    this.selectedEntity = const BillingEntityProfiles(),
    this.selectedDetailEntity = const BillingEntityProfiles(),
    this.currentPage = 0,
    this.isAfterSearch = false,
  });
}

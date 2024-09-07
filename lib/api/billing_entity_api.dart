import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../model/billing_entity_model.dart';

const String billingEntity = 'billingEntity';

class BillingEntityProvider extends ChangeNotifier {
  BillingEntityState state = BillingEntityState();
  final box = Hive.box<BillingEntityProfiles>(billingEntity);

  Future<void> saveData({
    required String name,
    required String email,
  }) async {
    try {
      ///save billing data
      BillingEntityProfiles billingEntityProfiles = BillingEntityProfiles(id: DateTime.now().millisecondsSinceEpoch,name: name,email: email,logoURL: state.selectedLogo);
      await box.add(billingEntityProfiles);
      state.billingEntities.add(billingEntityProfiles);
      notifyListeners();
    } catch (e) {
     rethrow;
    }
  }

  Future<void> getEntityData() async {
    state.loading = true;
    notifyListeners();
    try {
      ///Billing data
      state.billingEntities = box.values.toList();
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


  void removeEntity(int index) async {
    await box.deleteAt(index);
    notifyListeners();
  }

  updateEntity(BillingEntityProfiles newEntity) async {
    state.selectedEntity = newEntity;
    await box.putAt(getIndexOfEntity(newEntity.id), newEntity);
    state.billingEntities[getIndexOfEntity(newEntity.id)] = newEntity;
    notifyListeners();
  }

  changeSelectedEntity(BillingEntityProfiles newEntity,int index) async {
    state.selectedEntity = newEntity;
    notifyListeners();
  }

  int getIndexOfEntity(int entityId) {
    return state.billingEntities.indexWhere((element) => element.id == entityId);
  }

  Future<void> deleteEntity({required int entityId}) async {
    try {
      ///delete billing data
      await box.deleteAt(getIndexOfEntity(entityId));
      state.billingEntities.removeAt(getIndexOfEntity(entityId));
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

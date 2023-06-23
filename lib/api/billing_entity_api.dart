import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/screens/forgot-password/model/response_state.dart';
import 'package:mezink_app/screens/invoices/model/billing_entity_model.dart';
import 'package:mezink_app/screens/invoices/model/request/billing_entity_request_data.dart';
import 'package:mezink_app/screens/login/model/error.dart';
import 'package:mezink_app/utils/common/api.dart';
import 'package:mezink_app/utils/common/api_path.dart';
import 'package:mezink_app/utils/common/app_keys.dart';

import '../../../utils/common/api_keys.dart';

class BillingEntityProvider extends ChangeNotifier {
  BillingEntityState state = BillingEntityState();

  Future<ResponseState> saveData({
    required int id,
    required String name,
    required String email,
  }) async {
    try {
      var response = await apiPostRequest(
        path: APIPaths.publishBillingEntityPath,
        newOptions: BillingEntityRequestData(
          id: id,
          name: name,
          email: email,
          logoURL: state.selectedLogo,
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
        return ResponseState(success: false, error: S.current.check_internet);
      } else {
        return ResponseState(
            success: false, error: S.current.something_went_wrong);
      }
    }
  }

  Future<void> getData() async {
    state.loading = true;
    state.currentPage = 1;
    try {
      var response = await apiGetRequest(
        path: APIPaths.billingEntityPath,
        queryParamsAsMap: {
          MConstants.page: state.currentPage,
          MConstants.searchTerms: state.searchQuery,
        },
      );
      if (response.statusCode == 200) {
        state.billingEntityModel = BillingEntityModel.fromJson(response.data);
        if (state.billingEntityModel.billingEntityData.hasNext) {
          state.currentPage++;
        }
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
    if (state.billingEntityModel.billingEntityData.hasNext) {
      try {
        var response = await apiGetRequest(
          path: APIPaths.billingEntityPath,
          queryParamsAsMap: {
            MConstants.page: state.currentPage,
            MConstants.searchTerms: state.searchQuery,
          },
        );
        if (response.statusCode == 200) {
          // get full response from api
          BillingEntityModel resultGetMore =
              BillingEntityModel.fromJson(response.data);

          // checking if has next return true, current will increment
          if (resultGetMore.billingEntityData.hasNext) {
            state.currentPage++;
          }
          // updating model with new value
          state.billingEntityModel = BillingEntityModel(
            billingEntityData: BillingEntityData(
              // updating hasNext from resultGetMore
              hasNext: resultGetMore.billingEntityData.hasNext,

              // keep old model list data
              profiles: state.billingEntityModel.billingEntityData.profiles,
            ),
          );

          // adding new data from resultGetMore
          resultGetMore.billingEntityData.profiles.forEach((element) {
            state.billingEntityModel.billingEntityData.profiles.add(element);
          });
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

  Future<bool> getDetailBillingEntity(int billingEntityId) async {
    state.loading = true;
    try {
      var response = await apiGetRequest(
        path: APIPaths.detailBillingEntityPath,
        queryParamsAsMap: {
          APIKeys.entityId: billingEntityId,
        },
      );
      if (response.statusCode == 200) {
        state.loading = false;
        state.selectedDetailEntity =
            BillingEntityProfiles.fromJson(response.data[APIKeys.data]);
        notifyListeners();
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

  changeSelectedEntity(BillingEntityProfiles newEntity) {
    state.selectedEntity = newEntity;
    notifyListeners();
  }

  Future<bool> deleteEntity({required int entityId}) async {
    try {
      Map<String, dynamic> form = {
        "ids": [entityId],
      };
      var response = await apiPostRequest(
        path: APIPaths.billingEntityDeletePath,
        newOptions: {
          "message": form,
        },
      );
      if (response.statusCode == 200) {
        state.billingEntityModel.billingEntityData.profiles
            .removeWhere((element) {
          return element.id == entityId;
        });
        notifyListeners();
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

  removeSelectedLogo() {
    state.selectedLogo = "";
    state.isLogoEmpty = true;
  }

  Future changeSelectedLogoAfterUploadLogo(fileToUpload) async {
    var imagePath = await createFormData(fileToUpload);
    if (imagePath.containsKey(APIKeys.data)) {
      state.selectedLogo = imagePath[APIKeys.data][APIKeys.uri];
      state.isLogoEmpty = false;
      notifyListeners();
    }
  }

  Future<Map> createFormData(file) async {
    String fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap(
      {
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      },
    );
    var options = {
      "message": formData,
      "type": APIKeys.file,
    };

    var apiData = await apiPostRequest(
      path: APIPaths.uploadBillingEntityLogoPath,
      newOptions: options,
    );
    return apiData.data;
  }
}

class BillingEntityState {
  bool isError;
  bool loading;
  bool empty;
  bool isNetworkError;
  bool isLogoEmpty;
  BillingEntityModel billingEntityModel;
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
    this.billingEntityModel = const BillingEntityModel(),
    this.searchQuery = "",
    this.selectedLogo = "",
    this.selectedEntity = const BillingEntityProfiles(),
    this.selectedDetailEntity = const BillingEntityProfiles(),
    this.currentPage = 0,
    this.isAfterSearch = false,
  });
}

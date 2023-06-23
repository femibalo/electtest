import 'package:flutter/foundation.dart';
import 'package:mezink_app/screens/invoices/model/invoice_charge_model.dart';

class InvoiceChargeProvider extends ChangeNotifier {
  List<InvoiceChargeModel> selectedCharges = [];

  List<InvoiceChargeValueTypeModel> chargeValueType = [];
  List<InvoiceChargeOperationTypeModel> chargeOperationType = [];
  InvoiceChargeValueTypeModel selectedValueType =
      InvoiceChargeValueTypeModel().fromJson({});
  InvoiceChargeOperationTypeModel selectedOperationType =
      InvoiceChargeOperationTypeModel().fromJson({});

  Future<void> saveData({required InvoiceChargeModel value}) async {
    selectedCharges.add(value);
    notifyListeners();
  }

  Future<void> editData({
    required int index,
    required InvoiceChargeModel value,
  }) async {
    selectedCharges[index] = InvoiceChargeModel().fromJson(value.toJson());
    notifyListeners();
  }

  removeData(int index) {
    selectedCharges.removeAt(index);
    notifyListeners();
  }

  changeSelectedCharges({required int index}) {
    selectedCharges[index].isSelected = !selectedCharges[index].isSelected;
    notifyListeners();
  }

  changeSelectedValueType(InvoiceChargeValueTypeModel newSelectedValueType) {
    selectedValueType = newSelectedValueType;
    notifyListeners();
  }

  changeSelectedOperationType(
      InvoiceChargeOperationTypeModel newSelectedOperationType) {
    selectedOperationType = newSelectedOperationType;
    notifyListeners();
  }

  setSelectedChargesFromAddInvoiceScreen(
      List<InvoiceChargeModel> chargesFromAddInvoiceScreen) {
    selectedCharges.clear();
    chargesFromAddInvoiceScreen.forEach((element) {
      selectedCharges.add(InvoiceChargeModel().fromJson(element.toJson()));
    });
    notifyListeners();
  }

  addingValueType({required List<InvoiceChargeValueTypeModel> newValueType}) {
    chargeValueType.clear();
    chargeValueType.addAll(newValueType);
    notifyListeners();
  }

  addingOperationType(
      {required List<InvoiceChargeOperationTypeModel> newOperationType}) {
    chargeOperationType.clear();
    chargeOperationType.addAll(newOperationType);
    notifyListeners();
  }

  deleteCharge(int index) {
    selectedCharges.removeAt(index);
    notifyListeners();
  }
}

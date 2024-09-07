import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../model/invoice_charge_model.dart';

const String billExtraCharge = 'billExtraCharge';

class InvoiceChargeProvider extends ChangeNotifier {
  List<InvoiceChargeModel> selectedCharges = [];
  final box = Hive.box<InvoiceChargeModel>(billExtraCharge);
  List<InvoiceChargeValueTypeModel> chargeValueType = [];
  List<InvoiceChargeOperationTypeModel> chargeOperationType = [];
  InvoiceChargeValueTypeModel selectedValueType = InvoiceChargeValueTypeModel();
  InvoiceChargeOperationTypeModel selectedOperationType = InvoiceChargeOperationTypeModel();


  Future<void> saveData({required InvoiceChargeModel value}) async {
    selectedCharges.add(value);
    await box.add(value);
    getData();
  }

  Future<void> getData() async {
    try {
      selectedCharges = box.values.toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<void> editData({
    required int index,
    required InvoiceChargeModel value,
  }) async {
    selectedCharges[index] = value;
    await box.putAt(index, value);
    getData();
  }

  removeData(int index) async {
    await box.deleteAt(index);
    getData();
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
    for (var element in chargesFromAddInvoiceScreen) {
      selectedCharges.add(element);
    }
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
    removeData(index);
    selectedCharges.removeAt(index);
  }
}

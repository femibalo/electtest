import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../api/invoice_charge_api.dart';
import '../../model/invoice_charge_model.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';

class AddInvoiceChargeScreen extends StatefulWidget {
  final bool isEditMode;
  final int indexCharge;

  const AddInvoiceChargeScreen({
    super.key,
    this.isEditMode = false,
    this.indexCharge = 0,
  });

  static const String id = "addInvoiceCharges";

  static void launchScreen(
      {required BuildContext context,
      required int indexCharge,
      required bool isEditMode}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddInvoiceChargeScreen(
              isEditMode: isEditMode,
              indexCharge: indexCharge,
            )));
  }

  @override
  State<AddInvoiceChargeScreen> createState() => _AddInvoiceChargeScreenState();
}

class _AddInvoiceChargeScreenState extends State<AddInvoiceChargeScreen> {
  late InvoiceChargeProvider provider;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final chargeValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoiceChargeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
      setValueTypeAndOperation();
      if (widget.isEditMode) {
        nameController.text = provider.selectedCharges[widget.indexCharge].name;
        chargeValueController.text =
            provider.selectedCharges[widget.indexCharge].value.toString();
        provider.changeSelectedValueType(provider.chargeValueType.singleWhere(
            (element) =>
                element.value ==
                provider.selectedCharges[widget.indexCharge].type));
        provider.changeSelectedOperationType(provider.chargeOperationType
            .singleWhere((element) =>
                element.value ==
                provider.selectedCharges[widget.indexCharge].operation));
      }
    });
  }

  setValueTypeAndOperation() {
    provider.addingValueType(newValueType: [
      InvoiceChargeValueTypeModel(title: 'percent'.tr(), value: 'percent'),
      InvoiceChargeValueTypeModel(title: 'number'.tr(), value: 'number'),
    ]);
    provider.addingOperationType(newOperationType: [
      InvoiceChargeOperationTypeModel(
        title: 'add'.tr(),
        value: '+',
      ),
      InvoiceChargeOperationTypeModel(
        title: 'subtract'.tr(),
        value: '-',
      ),
    ]);
    provider.changeSelectedValueType(provider.chargeValueType[0]);
    provider.changeSelectedOperationType(provider.chargeOperationType[0]);
    chargeValueController.text = "10";
  }

  validation() {
    if (formKey.currentState!.validate()) {
      saveData();
    }
  }

  saveData() {
    if (widget.isEditMode) {
      provider
          .editData(
        index: widget.indexCharge,
        value: InvoiceChargeModel(
          name: nameController.text.toString(),
          value: int.parse(chargeValueController.text.toString()),
          operation: provider.selectedOperationType.value,
          type: provider.selectedValueType.value,
          isSelected: provider.selectedCharges[widget.indexCharge].isSelected,
        ),
      )
          .then((value) {
        showSnackBar(
          context: context,
          text: 'edit_charge_success'.tr(),
          snackBarType: SnackBarType.success,
        );
        provider.changeSelectedOperationType(provider.chargeOperationType[0]);
        provider.changeSelectedValueType(provider.chargeValueType[0]);
        reset();
        Navigator.pop(context);
      });
    } else {
      provider
          .saveData(
        value: InvoiceChargeModel(
          name: nameController.text.toString(),
          value: int.parse(chargeValueController.text.toString()),
          operation: provider.selectedOperationType.value,
          type: provider.selectedValueType.value,
          isSelected: true,
        ),
      )
          .then((value) {
        provider.changeSelectedOperationType(provider.chargeOperationType[0]);
        provider.changeSelectedValueType(provider.chargeValueType[0]);
        reset();
        Navigator.pop(context);
        showSnackBar(
          context: context,
          text: 'add_charge_success'.tr(),
          snackBarType: SnackBarType.success,
        );
      });
    }
  }

  void reset() {
    nameController.clear();
    chargeValueController.text = "10";
  }

  @override
  void dispose() {
    super.dispose();
    disposingResources();
  }

  disposingResources() {
    nameController.dispose();
    chargeValueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceChargeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_charge'.tr()),
        actions: [_buildSaveButton()],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string == null || string.toString().trim().isEmpty) {
                        return 'charge_name_empty'.tr();
                      }
                      return null;
                    },
                    labelText: 'charge_name'.tr(),
                  ),
                ),
                // === charge name

                // === charge value
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'charge_value'.tr(),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: MTextFormField(
                          controller: chargeValueController,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          keyboardType:
                              provider.selectedValueType.value == 'percent'
                                  ? const TextInputType.numberWithOptions(
                                      decimal: true)
                                  : TextInputType.number,
                          inputFormatters:
                              provider.selectedValueType.value == 'percent'
                                  ? [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^[1-9][0-9]*'),
                                      ),
                                      FilteringTextInputFormatter.digitsOnly
                                    ]
                                  : [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[0-9]{1,7}'))
                                    ],
                          onChanged: (str) {
                            if (provider.selectedValueType.value == 'percent') {
                              if (double.parse(str.toString()) > 100) {
                                setState(() {
                                  chargeValueController.text = "100";
                                  chargeValueController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                      offset: chargeValueController.text.length,
                                    ),
                                  );
                                });
                              }
                            } else {
                              if (str.indexOf("0") == 0) {
                                setState(() {
                                  chargeValueController.clear();
                                });
                              } else if (str.toString().trim().isEmpty) {
                                setState(() {
                                  chargeValueController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                      offset: chargeValueController.text.length,
                                    ),
                                  );
                                });
                              }
                            }
                          },
                          validator: (string) {
                            if (string == null ||
                                string.toString().trim().isEmpty) {
                              return 'charge_value_empty'.tr();
                            }
                            return null;
                          },
                          hintText: "...",
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (provider.chargeValueType.isNotEmpty) {
                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                left: 10,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton(
                                enableFeedback: true,
                                alignment: Alignment.centerLeft,
                                value: provider.selectedValueType,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  // color: MColors.black,
                                ),
                                items: provider.chargeValueType.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value.title,
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                }).toList(),
                                underline: const Opacity(opacity: 0),
                                onChanged:
                                    (InvoiceChargeValueTypeModel? value) {
                                  provider.changeSelectedValueType(value!);
                                  setState(() {
                                    chargeValueController.clear();
                                  });
                                },
                              ),
                            );
                          }
                          return const Opacity(opacity: 0);
                        }),
                      ),
                    ],
                  ),
                ),
                // === charge value

                // === charge value
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'operation'.tr(),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (provider.chargeOperationType.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButton(
                                    enableFeedback: true,
                                    value: provider.selectedOperationType,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    items: provider.chargeOperationType
                                        .map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value.title,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                    underline: const Opacity(opacity: 0),
                                    onChanged: (InvoiceChargeOperationTypeModel?
                                        value) {
                                      provider
                                          .changeSelectedOperationType(value!);
                                    },
                                  ),
                                )
                              ],
                            );
                          }
                          return const Opacity(opacity: 0);
                        }),
                      ),
                    ],
                  ),
                ),
                // === charge value
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          validation();
        },
        child: Text('save'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
      ),
    );
  }
}

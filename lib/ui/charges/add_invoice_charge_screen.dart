// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import '../../../../generated/l10n.dart';
import '../../../../utils/common/snack_bar.dart';
import '../../api/invoice_charge_api.dart';
import '../../model/invoice_charge_model.dart';

class AddInvoiceChargeScreen extends StatefulWidget {
  final bool isEditMode;
  final int indexCharge;
  const AddInvoiceChargeScreen({
    Key? key,
    this.isEditMode = false,
    this.indexCharge = 0,
  }) : super(key: key);

  static const String id = "addInvoiceCharges";
  static void launchScreen(BuildContext context) {
    context.router.pushNamed(id);
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
      InvoiceChargeValueTypeModel(title: S.current.percent, value: 'percent'),
      InvoiceChargeValueTypeModel(title: S.current.number, value: 'number'),
    ]);
    provider.addingOperationType(newOperationType: [
      InvoiceChargeOperationTypeModel(
        title: S.current.add,
        value: '+',
      ),
      InvoiceChargeOperationTypeModel(
        title: S.current.subtract,
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
          text: S.current.edit_charge_success,
          snackBarType: SnackBarType.success,
        );
        provider.changeSelectedOperationType(provider.chargeOperationType[0]);
        provider.changeSelectedValueType(provider.chargeValueType[0]);
        reset();
        context.router.pop();
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
        context.router.pop();
        showSnackBar(
          context: context,
          text: S.current.add_charge_success,
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
  void dispose(){
    super.dispose();
    disposingResources();
  }

  disposingResources(){
    nameController.dispose();
    chargeValueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceChargeProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: S.current.add_new_charge,
        actions: [_buildSaveButton()],
      ),
      body: ListView(
        physics: customScrollPhysics(),
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
                // === charge name
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string == null || string.toString().trim().isEmpty) {
                        return S.current.charge_name_empty;
                      }
                      return null;
                    },
                      labelText: S.current.charge_name,
                  ),
                ),
                // === charge name

                // === charge value
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          S.current.charge_value,
                          style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: MTextFormField(
                          controller: chargeValueController,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          keyboardType: provider.selectedValueType.value ==
                                  'percent'
                              ? TextInputType.numberWithOptions(decimal: true)
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
                              return S.current.charge_value_empty;
                            }
                            return null;
                          },
                          hintText: "...",
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (provider.chargeValueType.isNotEmpty) {
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                left: 10,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.outlineColor,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton(
                                enableFeedback: true,
                                alignment: Alignment.centerLeft,
                                value: provider.selectedValueType,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  // color: MColors.black,
                                ),
                                style: context.getTitleSmallTextStyle(context.onSurfaceColor),
                                items: provider.chargeValueType.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(
                                      value.title,
                                      textAlign: TextAlign.left,
                                    ),
                                    value: value,
                                  );
                                }).toList(),
                                underline: Opacity(opacity: 0),
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
                          return Opacity(opacity: 0);
                        }),
                      ),
                    ],
                  ),
                ),
                // === charge value

                // === charge value
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.current.operation,
                          style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
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
                                  padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.outlineColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButton(
                                    enableFeedback: true,
                                    value: provider.selectedOperationType,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    style: context.getTitleSmallTextStyle(context.onSurfaceColor),
                                    alignment: Alignment.centerLeft,
                                    items: provider.chargeOperationType
                                        .map((value) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          value.title,
                                          textAlign: TextAlign.center,
                                        ),
                                        value: value,
                                      );
                                    }).toList(),
                                    underline: Opacity(opacity: 0),
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
                          return Opacity(opacity: 0);
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
      padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: MTextButton(
        isAppBarAction: true,
        onPressed: () {
          validation();
        },
        child: Text(S.current.save),
      ),
    );
  }
}

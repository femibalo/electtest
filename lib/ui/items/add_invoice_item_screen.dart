import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:invoice_management/model/bill_product_item_model.dart';
import 'package:provider/provider.dart';

import '../../api/item_api.dart';
import '../../model/currency_model.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';

class AddInvoiceItemScreen extends StatefulWidget {
  final int itemID;
  final bool isEditMode;
  final UserBillProductItem? userAddItem;
  const AddInvoiceItemScreen({
    Key? key,
    this.userAddItem,
    this.itemID = 0,
    this.isEditMode = false,
  }) : super(key: key);

  static const String id = "addInvoiceItem";
  static void launchScreen(
      {required BuildContext context,
      required int itemId,
      required bool isEditMode}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddInvoiceItemScreen(
              itemID: itemId,
              isEditMode: isEditMode,
            )));
  }

  @override
  State<AddInvoiceItemScreen> createState() => _AddInvoiceItemScreenState();
}

class _AddInvoiceItemScreenState extends State<AddInvoiceItemScreen> {
  late InvoiceItemProvider provider;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final taxController = TextEditingController();
  final discountController = TextEditingController();

  // New controllers for the new fields
  final equipmentIdController = TextEditingController();
  final locationController = TextEditingController();
  final serialNoController = TextEditingController();
  final voltageController = TextEditingController();
  final ratingController = TextEditingController();
  final fuseController = TextEditingController();
  final inspectionFrequencyController = TextEditingController();

  String? selectedClass;
  bool greyOutContinuityTest = false;

  @override
  void initState() {
    super.initState();

    provider = Provider.of<InvoiceItemProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      priceController.text = "10000";
      if (widget.isEditMode) {
        nameController.text = widget.userAddItem?.name ?? '';
        descriptionController.text = widget.userAddItem?.description ?? '';
        priceController.text = '${widget.userAddItem?.price}';
        taxController.text = '${widget.userAddItem?.taxPercent}';
        discountController.text = '${widget.userAddItem?.discountPercent}';
      }
      loadForm();
    });
  }

  loadForm() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    provider.getCurrencies().then((value) {
      if (widget.isEditMode) {}
    });
  }

  validation() {
    if (formKey.currentState!.validate()) {
      saveData();
    }
  }

  saveData() {
    provider
        .saveData(
      name: nameController.text.toString(),
      description: descriptionController.text.toString(),
      equipmentId: equipmentIdController.text.toString(),
      location: locationController.text.toString(),
      serialNo: serialNoController.text.toString(),
      voltage: int.parse(voltageController.text.toString()),
      rating: int.parse(ratingController.text.toString()),
      fuse: int.parse(fuseController.text.toString()),
      inspectionFrequency: inspectionFrequencyController.text.toString(), //
      continuityTestGreyedOut:
          greyOutContinuityTest, // Logic for Continuity Test
      // price: int.parse(priceController.text.toString()),
      // qty: 1,
      // currencyID: 0,
      // taxPercent: double.parse(taxController.text.toString()),
      // gstPercent: 0,
      // discountPercent: double.parse(
      //   discountController.text.toString(),
      // )
    )
        .then((value) {
      Navigator.pop(context);
      reset();
      if (widget.isEditMode) {
        showSnackBar(
          context: context,
          text: 'edit item success',
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          context: context,
          text: 'add item success',
          snackBarType: SnackBarType.success,
        );
      }
    });
  }

  reset() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    taxController.clear();
    discountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    reset();
    disposingResources();
  }

  disposingResources() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    taxController.dispose();
    discountController.dispose();
  }

  void handleClassChange(String? value) {
    setState(() {
      selectedClass = value;
      greyOutContinuityTest = selectedClass == "Class II";
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceItemProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.isEditMode ? 'edit_item'.tr() : 'add_new_item'.tr()),
          actions: [_buildSaveButton(provider.state)],
        ),
        body: _getWidgetBasedOnState(provider.state));
  }

  Widget _buildSaveButton(InvoiceItemState state) {
    if (state.isNetworkError) {
      return const SizedBox();
    }

    if (state.isError) {
      return const SizedBox();
    }

    if (state.loading) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          if (widget.isEditMode && formKey.currentState!.validate()) {
            final userAddItem = widget.userAddItem?.copyWith(
              name: nameController.text,
              description: descriptionController.text,
              price: int.tryParse(priceController.text),
              discountPercent: int.tryParse(discountController.text),
              taxPercent: int.tryParse(taxController.text),
            );
            provider.updateItemEntity(userAddItem!).then((value) {
              Navigator.pop(context);
            });
          } else {
            validation();
          }
        },
        child: Text(widget.isEditMode ? 'update'.tr() : 'save'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _getWidgetBasedOnState(InvoiceItemState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state.isNetworkError) {
      return NetworkErrorWidget(onRefresh: () {
        loadForm();
      });
    }

    if (state.isError) {
      return GenericErrorWidget(onRefresh: () {
        loadForm();
      });
    }

    return _successContent(state);
  }

  Widget _successContent(InvoiceItemState state) {
    List<Widget> children = [];
    children.add(
      ListView(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        shrinkWrap: true,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                // === item name
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'item_name_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'item_name'.tr()),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 1,
                      labelText: 'item_description'.tr()),
                ),
                // === item description
                // === new Item
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: equipmentIdController,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'equipment_id_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'equipment_id'.tr()),
                ),

                // === Type of Class (Dropdown)
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration:
                        InputDecoration(labelText: 'type_of_class'.tr()),
                    items: [
                      'Class 0',
                      'Class I',
                      'Class II',
                      'Class III',
                    ]
                        .map((classType) => DropdownMenuItem(
                              value: classType,
                              child: Text(classType),
                            ))
                        .toList(),
                    onChanged: handleClassChange,
                    validator: (value) =>
                        value == null ? 'class_type_empty'.tr() : null,
                  ),
                ),

                // === Location
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: locationController,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'location_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'location'.tr()),
                ),

                // === Serial No
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: serialNoController,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'serial_no_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'serial_no'.tr()),
                ),

                // === Voltage (V)
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: voltageController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'voltage_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'voltage_v'.tr()),
                ),

                // === Rating (Watts or A)
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: ratingController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'rating_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'rating_watts_or_a'.tr()),
                ),

                // === Fuse (A)
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: fuseController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'fuse_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'fuse_a'.tr()),
                ),

                // === Frequency of Inspection
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: inspectionFrequencyController,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'inspection_frequency_empty'.tr();
                        }
                        return null;
                      },
                      labelText: 'frequency_of_inspection'.tr()),
                ),

                // === Continuity Test (grey out if Class II is selected)
                Opacity(
                  opacity: greyOutContinuityTest ? 0.5 : 1.0,
                  child: MTextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    enabled: !greyOutContinuityTest,
                    labelText: 'continuity_test'.tr(),
                  ),
                ),
                // === item price
                /*
                Container(
                  margin: const EdgeInsets.only(top: 35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Text('price'.tr(),
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: MTextFormField(
                                controller: priceController,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 10,
                                validator: (string) {
                                  if (string == null ||
                                      string.toString().trim().isEmpty) {
                                    return 'item_price_empty'.tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
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
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: DropdownButton(
                                enableFeedback: true,
                                value: provider.state.selectedCurrency,
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                                items: provider.state.currencies.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(toBeginningOfSentenceCase(
                                        value.code.toUpperCase())!),
                                  );
                                }).toList(),
                                underline: const Opacity(opacity: 0),
                                onChanged: (CurrencyModel? value) {
                                  provider.changeSelectedCurrency(value!);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: taxController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      maxLines: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,2})'))
                      ],
                      onChanged: (str) {
                        if (str.isNotEmpty) {
                          if (double.parse(str.toString()) > 100) {
                            setState(() {
                              taxController.text = "100";
                            });
                          }
                        } else {
                          taxController.text = "0";
                        }
                      },
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'item_tax_empty'.tr();
                        }
                        return null;
                      },
                      labelText: "tax (%)"),
                ),
                // === item tax

                // === item discount
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: discountController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,2})'))
                      ],
                      onChanged: (str) {
                        if (str.isNotEmpty) {
                          if (double.parse(str.toString()) > 100) {
                            setState(() {
                              discountController.text = "100";
                            });
                          }
                        } else {
                          discountController.text = "0";
                        }
                      },
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'item_discount_empty'.tr();
                        }
                        return null;
                      },
                      labelText: "discount_(%)".tr()),
                ), */
                // === item discount
              ],
            ),
          ),
        ],
      ),
    );
    return RefreshIndicator(
      onRefresh: () async {
        loadForm();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

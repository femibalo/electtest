import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/item_api.dart';
import '../../model/currency_model.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';

class AddInvoiceItemScreen extends StatefulWidget {
  final int itemID;
  final bool isEditMode;
  const AddInvoiceItemScreen({
    Key? key,
    this.itemID = 0,
    this.isEditMode = false,
  }) : super(key: key);

  static const String id = "addInvoiceItem";
  static void launchScreen({required BuildContext context,required int itemId, required bool isEditMode}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddInvoiceItemScreen(itemID: itemId,isEditMode: isEditMode,)));
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

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoiceItemProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      priceController.text = "10000";
      taxController.text = "0";
      discountController.text = "0";
      loadForm();
    });
  }

  loadForm() {
    setState(() {
      provider.states.isError = false;
      provider.states.isNetworkError = false;
    });
    provider.getCurrencies().then((value) {
      if (widget.isEditMode) {

      }
    });
  }

  validation() {
    if (formKey.currentState!.validate()) {
      saveData();
    }
  }

  saveData() {
    provider.saveData(
            id: widget.itemID,
            name: nameController.text.toString(),
            description: descriptionController.text.toString(),
            price: int.parse(priceController.text.toString()),
            qty: widget.isEditMode
                ? provider.states.billProductItems
                    .singleWhere((element) => element.id == widget.itemID)
                    .qty
                : 0,
            currencyID: provider.states.selectedCurrency.id,
            taxPercent: double.parse(taxController.text.toString()),
            gstPercent: 0,
            discountPercent: double.parse(
              discountController.text.toString(),
            ))
        .then((value) {
      Navigator.pop(context);
      reset();
      if (widget.isEditMode) {
        showSnackBar(
          context: context,
          text:'edit item success',
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceItemProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditMode ? 'edit item' : 'add new item'),
          actions: [_buildSaveButton(provider.states)],
        ),
        body: _getWidgetBasedOnState(provider.states));
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
          validation();
        },
        child: const Text('save'),
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
                          return 'item name empty';
                        }
                        return null;
                      },
                      labelText: 'item name'),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 1,
                      labelText: 'item description'),
                ),
                // === item description

                // === item price
                Container(
                  margin: const EdgeInsets.only(top: 35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: const Text(
                          'price',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
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
                                    return 'item price empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Container(
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
                                    value: provider.states.selectedCurrency,
                                    icon: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                    ),
                                    items:
                                        provider.states.currencies.map((value) {
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // === item price

                // === item tax
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
                        if (double.parse(str.toString()) > 100) {
                          setState(() {
                            taxController.text = "100";
                          });
                        }
                      },
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'item tax empty';
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
                        if (double.parse(str.toString()) > 100) {
                          setState(() {
                            discountController.text = "100";
                          });
                        }
                      },
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return 'item discount empty';
                        }
                        return null;
                      },
                      labelText: "discount (%)"),
                ),
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

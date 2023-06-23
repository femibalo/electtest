// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/components/error_screens.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/screens/analytics/model/currency_model.dart';
import 'package:mezink_app/screens/invoices/api/item_api.dart';
import 'package:mezink_app/styles/progress_indicator.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/common/snack_bar.dart';

class AddInvoiceItemScreen extends StatefulWidget {
  final int itemID;
  final bool isEditMode;
  const AddInvoiceItemScreen({
    Key? key,
    this.itemID = 0,
    this.isEditMode = false,
  }) : super(key: key);

  static const String id = "addInvoiceItem";
  static void launchScreen(BuildContext context) {
    context.router.pushNamed(id);
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
        provider.getDetailItem(widget.itemID).then((value) {
          if (value != false) {
            // if return true == success load data from api
            var selectedDetail = provider.states.selectedDetailItem;
            nameController.text = selectedDetail.name.toString();
            descriptionController.text = selectedDetail.description.toString();
            priceController.text = selectedDetail.price.toString();
            taxController.text = selectedDetail.taxPercent.toString();
            discountController.text = selectedDetail.discountPercent.toString();
          }
        });
      }
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
            id: widget.itemID,
            name: nameController.text.toString(),
            description: descriptionController.text.toString(),
            price: int.parse(priceController.text.toString()),
            qty: widget.isEditMode
                ? provider.states.billProductItemModel.data.userItems
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
      if (value.success) {
        context.router.pop();
        reset();
        if (widget.isEditMode) {
          showSnackBar(
            context: context,
            text: S.current.edit_item_success,
            snackBarType: SnackBarType.success,
          );
        } else {
          showSnackBar(
            context: context,
            text: S.current.add_item_success,
            snackBarType: SnackBarType.success,
          );
        }
      } else {
        showSnackBar(
          context: context,
          text: value.error,
          snackBarType: SnackBarType.error,
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
        backgroundColor: context.backgroundColor,
        appBar: MAppBar(
          title:
              widget.isEditMode ? S.current.edit_item : S.current.add_new_item,
          actions: [_buildSaveButton(provider.states)],
        ),
        body: _getWidgetBasedOnState(provider.states));
  }

  Widget _buildSaveButton(InvoiceItemState state) {
    if (state.isNetworkError) {
      return SizedBox();
    }

    if (state.isError) {
      return SizedBox();
    }

    if (state.loading) {
      return SizedBox();
    }

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

  Widget _getWidgetBasedOnState(InvoiceItemState state) {
    if (state.loading) {
      return const Center(
        child: AdaptiveProgressIndicator(),
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
        physics: customScrollPhysics(),
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
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 1,
                      validator: (string) {
                        if (string == null ||
                            string.toString().trim().isEmpty) {
                          return S.current.item_name_empty;
                        }
                        return null;
                      },
                      labelText: S.current.item_name),
                ),
                // === item name

                // === item description
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 1,
                      labelText: S.current.item_description),
                ),
                // === item description

                // === item price
                Container(
                  margin: EdgeInsets.only(top: 35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          S.current.price,
                          style: context
                              .getTitleMediumTextStyle(context.onSurfaceColor),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
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
                                    return S.current.item_price_empty;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Container(
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
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: DropdownButton(
                                    enableFeedback: true,
                                    value: provider.states.selectedCurrency,
                                    icon: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                    ),
                                    style: context.getTitleMediumTextStyle(
                                        context.onSurfaceColor),
                                    items:
                                        provider.states.currencies.map((value) {
                                      return DropdownMenuItem(
                                        child: Text(toBeginningOfSentenceCase(
                                            value.code.toUpperCase())!),
                                        value: value,
                                      );
                                    }).toList(),
                                    underline: Opacity(opacity: 0),
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
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                      controller: taxController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                          return S.current.item_tax_empty;
                        }
                        return null;
                      },
                      labelText: "${S.current.tax} (%)"),
                ),
                // === item tax

                // === item discount
                Container(
                  margin: EdgeInsets.only(top: 25),
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
                          return S.current.item_discount_empty;
                        }
                        return null;
                      },
                      labelText: "${S.current.discount} (%)"),
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
        physics: customScrollPhysics(alwaysScroll: true),
      ),
    );
  }
}

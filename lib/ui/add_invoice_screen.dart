// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/components/error_screens.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/filled_button.dart';
import 'package:mezink_app/material_components/buttons/outlined_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/screens/invoices/api/invoice_api.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:mezink_app/screens/invoices/model/billing_entity_model.dart';
import 'package:mezink_app/screens/invoices/model/client_invoice_model.dart';
import 'package:mezink_app/screens/invoices/model/invoice_charge_model.dart';
import 'package:mezink_app/screens/invoices/ui/billing-entity/billing_entity_screen.dart';
import 'package:mezink_app/screens/invoices/ui/client/client_screen.dart';
import 'package:mezink_app/screens/invoices/ui/components/item_in_add_invoice.dart';
import 'package:mezink_app/screens/invoices/ui/items/items_screen.dart';
import 'package:mezink_app/styles/color.dart';
import 'package:mezink_app/styles/progress_indicator.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../material_components/buttons/text_button.dart';
import 'charges/invoice_charges_screen.dart';
import 'items/components/price_detail.dart';

class AddInvoiceScreen extends StatefulWidget {
  final int invoiceId;
  final bool isEditMode;
  const AddInvoiceScreen({
    Key? key,
    this.invoiceId = 0,
    this.isEditMode = false,
  }) : super(key: key);

  static const String id = "addInvoice";
  static void launchScreen(BuildContext context) {
    context.router.pushNamed(id);
  }

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late InvoicesProvider provider;
  final formKey = GlobalKey<FormState>();
  final invoiceNameController = TextEditingController();
  final notesController = TextEditingController();
  final termsConditionController = TextEditingController();

  final invoiceDateController = TextEditingController();
  final dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoicesProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadInvoiceForm();
    });
  }

  loadInvoiceForm() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    if (widget.isEditMode) {
      getDetailInvoice();
    } else {
      getDefaultInvoice();
    }
  }

  getDefaultInvoice() {
    provider.getDefaultInvoice().then((value) {
      invoiceNameController.text = provider.state.invoiceName;
      invoiceDateController.text = getDateddMMMyyyy(provider.state.invoiceDate);
      dueDateController.text = getDateddMMMyyyy(provider.state.dueDate);
      termsConditionController.text =
          S.current.terms_and_condition_default_in_create_invoice;
      invoiceDateController.text = getDateddMMMyyyy(provider.state.invoiceDate);
    });
  }

  getDetailInvoice() {
    provider.getDetailInvoice(invoiceID: widget.invoiceId).then((value) {
      var result = provider.state.detailInvoiceForEdit;
      invoiceNameController.text = result.invoiceID;
      if (result.description.isNotEmpty) {
        provider.state.isNotesActive = true;
        notesController.text = result.description;
      }
      if (result.termsAndConditions.isNotEmpty) {
        provider.state.isTermsConditionActive = true;
        termsConditionController.text = result.termsAndConditions;
      }
      invoiceDateController.text = getDateddMMMyyyy(provider.state.invoiceDate);
      dueDateController.text = getDateddMMMyyyy(provider.state.dueDate);
    });
  }

  reset() {
    provider.state.selectedBillingEntity = BillingEntityProfiles();
    provider.state.selectedClient = UserClientInvoice();
    provider.state.billProductItem = [];
    provider.state.selectedCharges = [];
    provider.state.isDueDateActive = false;
    provider.state.isTermsConditionActive = false;
    provider.state.isNotesActive = false;
    notesController.clear();
    termsConditionController.clear();
    provider.state.subTotal = 0;
    provider.state.tax = 0;
    provider.state.discount = 0;
    provider.state.finalPrice = 0;
  }

  changeEntity() {
    BillingEntityScreen.launchScreen(
        context, provider.state.selectedBillingEntity.id, (entity) {
      provider.changeSelectedEntity(
          BillingEntityProfiles.fromJson(entity.toJson()));
      showSnackBar(
        context: context,
        text: S.current.entity_selected,
        snackBarType: SnackBarType.success,
      );
    });
  }

  changeClient() {
    ClientInvoiceScreen.launchScreen(context, provider.state.selectedClient.id,
        (client) {
      provider
          .changeSelectedClient(UserClientInvoice.fromJson(client.toJson()));
      showSnackBar(
        context: context,
        text: S.current.client_selected,
        snackBarType: SnackBarType.success,
      );
    });
  }

  changeItems() {
    InvoiceItemsScreen.launchScreen(
        context: context,
        selectedItemsInAddInvoiceScreen:
            provider.state.billProductItem.toList(),
        onSaveSelectedItems: (List<UserBillProductItem> items) {
          if (items.isNotEmpty) {
            provider.setSelectedBillProductItemsFromItemScreen(
                newItems: items.toList());
            provider.calculate();
          }
        });
  }

  changeCharges() {
    InvoiceChargesScreen.launchScreen(
        context: context,
        selectedChargesFromAddInvoiceScreen:
            provider.state.selectedCharges.toList(),
        onSaveSelectedCharges: (List<InvoiceChargeModel> charges) {
          if (charges.isNotEmpty) {
            provider.setSelectedChargesFromItemScreen(
                newCharges: charges.toList());
            provider.calculate();
          }
        });
  }

  validation() {
    if (formKey.currentState!.validate()) {
      if (provider.state.isDueDateActive &&
          !provider.state.dueDate.isAfter(provider.state.invoiceDate)) {
        showSnackBar(
          context: context,
          text: S.current.due_date_must_after_invoice_date,
          snackBarType: SnackBarType.error,
        );
      } else if (provider.state.selectedClient.id == 0) {
        showSnackBar(
          context: context,
          text: S.current.client_empty,
          snackBarType: SnackBarType.error,
        );
      } else if (provider.state.billProductItem.isEmpty) {
        showSnackBar(
          context: context,
          text: S.current.item_empty,
          snackBarType: SnackBarType.error,
        );
      } else {
        saveData();
      }
    }
  }

  saveData() {
    provider
        .saveData(
      id: widget.invoiceId,
      profileID: provider.state.selectedBillingEntity.id,
      invoiceName: invoiceNameController.text.toString(),
      description: notesController.text.toString(),
      termsAndConditions: provider.state.isTermsConditionActive
          ? termsConditionController.text.toString()
          : "",
    )
        .then((value) {
      if (value.success) {
        reset();
        context.router.pop();
        if (widget.isEditMode) {
          showSnackBar(
            context: context,
            text: S.current.edit_invoice_success,
            snackBarType: SnackBarType.success,
          );
        } else {
          showSnackBar(
            context: context,
            text: S.current.add_invoice_success,
            snackBarType: SnackBarType.success,
          );
        }
        provider.state.selectedBillingEntity = BillingEntityProfiles();
        provider.state.selectedClient = UserClientInvoice();
        provider.state.billProductItem.clear();
        provider.state.selectedCharges.clear();
        provider.state.isDueDateActive = false;
        notesController.clear();
        provider.state.subTotal = 0;
        provider.state.tax = 0;
        provider.state.discount = 0;
        provider.state.finalPrice = 0;
      } else {
        showSnackBar(
          context: context,
          text: value.error,
          snackBarType: SnackBarType.error,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    reset();
    disposingResources();
  }

  disposingResources() {
    invoiceNameController.dispose();
    notesController.dispose();
    termsConditionController.dispose();
    invoiceDateController.dispose();
    dueDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoicesProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
          title: widget.isEditMode
              ? S.current.edit_invoice
              : S.current.new_invoice,
          actions: [_buildSaveButton(provider.state)]),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _getWidgetBasedOnState(InvoicesProviderState state) {
    if (state.loading) {
      return const Center(
        child: AdaptiveProgressIndicator(),
      );
    }
    if (state.isNetworkError) {
      return NetworkErrorWidget(onRefresh: () {
        loadInvoiceForm();
      });
    }

    if (state.isError) {
      return GenericErrorWidget(onRefresh: () {
        loadInvoiceForm();
      });
    }

    return _successContent(state);
  }

  Widget _buildSaveButton(InvoicesProviderState state) {
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

  Widget _successContent(InvoicesProviderState state) {
    List<Widget> children = [];
    children.add(
      ListView(
        physics: customScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          right: 20.0,
          left: 20.0,
          bottom: MediaQuery.of(context).size.height * 0.1,
          top: 10,
        ),
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === billing entity
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                S.current.billing_entity,
                                style: context.getTitleMediumTextStyle(
                                    context.onSurfaceColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.21,
                              child: MOutlineButton(
                                onPressed: () {
                                  changeEntity();
                                },
                                child: Text(S.current.edit),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          left: 5,
                        ),
                        child: ListTile(
                          onTap: () {
                            changeEntity();
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                              provider.state.selectedBillingEntity.logoURL
                                  .toString(),
                            ),
                          ),
                          title: Text(
                            provider.state.selectedBillingEntity.name
                                .toString(),
                            style: context.getTitleMediumTextStyle(
                                context.onSurfaceColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // === billing entity

                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Divider(),
                ),

                // === invoice name
                Container(
                  margin: EdgeInsets.only(
                    left: 5,
                    top: 20,
                  ),
                  child: Text(
                    S.current.invoice_details,
                    style:
                        context.getTitleMediumTextStyle(context.onSurfaceColor),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 25.0,
                  ),
                  child: MTextFormField(
                    controller: invoiceNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return S.current.invoice_name_empty;
                      }
                      return null;
                    },
                    labelText: "${S.current.invoice_name} #",
                  ),
                ),
                // === invoice name

                // date
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  S.current.date,
                                  style: context.getTitleMediumTextStyle(
                                      context.onSurfaceColor),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                activeColor: context.primaryColor,
                                onChanged: (val) {
                                  provider.changeDueDateStatus(val);
                                },
                                value: provider.state.isDueDateActive,
                                title: Text(
                                  S.current.due_date,
                                  style: context.getTitleMediumTextStyle(
                                      context.onSurfaceColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MTextFormField(
                                      controller: invoiceDateController,
                                      maxLines: 1,
                                      onTap: () {
                                        showDatePicker(
                                          isInvoiceDate: true,
                                        );
                                      },
                                      labelText: S.current.invoice_date,
                                      readOnly: true,
                                      suffixIcon: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 22,
                                            color: MColors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: MTextFormField(
                                      controller: dueDateController,
                                      readOnly: true,
                                      maxLines: 1,
                                      enabled: provider.state.isDueDateActive,
                                      onTap: provider.state.isDueDateActive
                                          ? () {
                                              showDatePicker(
                                                isInvoiceDate: false,
                                              );
                                            }
                                          : null,
                                      labelText: S.current.due_date,
                                      suffixIcon: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 22,
                                            color: MColors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // === date

                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Divider(),
                ),

                // === client name
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                S.current.client_details,
                                style: context.getTitleMediumTextStyle(
                                    context.onSurfaceColor),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.21,
                              child: Builder(builder: (ctx) {
                                if (provider.state.selectedClient.id != 0) {
                                  return MOutlineButton(
                                      onPressed: () {
                                        changeClient();
                                      },
                                      child: Text(S.current.edit));
                                }
                                return MFilledButton(
                                    onPressed: () {
                                      changeClient();
                                    },
                                    child: Text(S.current.add));
                              }),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          left: 5,
                        ),
                        child: Builder(builder: (context) {
                          if (provider.state.selectedClient.id != 0) {
                            return ListTile(
                              onTap: () {
                                changeClient();
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                  "https://ui-avatars.com/api/?name=${provider.state.selectedClient.name.toString()}&background=random",
                                ),
                              ),
                              title: Text(
                                provider.state.selectedClient.displayName
                                            .toString() ==
                                        ''
                                    ? provider.state.selectedClient.name
                                    : provider.state.selectedClient.displayName
                                        .toString(),
                                style: context.getTitleMediumTextStyle(
                                    context.onSurfaceColor),
                              ),
                            );
                          }
                          return Opacity(opacity: 0);
                        }),
                      ),
                    ],
                  ),
                ),
                // === client name

                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Divider(),
                ),

                // add bill product or item button
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          S.current.item_details,
                          style: context
                              .getTitleMediumTextStyle(context.onSurfaceColor),
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: Builder(builder: (ctx) {
                            if (provider.state.billProductItem.isEmpty) {
                              return MFilledButton(
                                  onPressed: () {
                                    changeItems();
                                  },
                                  child: Text(S.current.add));
                            }
                            return MOutlineButton(
                                onPressed: () {
                                  changeItems();
                                },
                                child: Text(S.current.edit));
                          })),
                    ],
                  ),
                ),
                // add bill product or item button

                // bill product or item list
                ListView.builder(
                  itemCount: provider.state.billProductItem.length,
                  shrinkWrap: true,
                  physics: customScrollPhysics(),
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (ctx, index) {
                    return ItemInAddInvoiceScreen(
                      model: provider.state.billProductItem[index],
                    );
                  },
                ),
                // bill product or item list

                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Divider(),
                ),

                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      initiallyExpanded: provider.state.detailInvoiceForEdit
                                  .description.isNotEmpty ||
                              provider.state.detailInvoiceForEdit
                                  .termsAndConditions.isNotEmpty
                          ? true
                          : false,
                      title: Text(
                        S.current.additional_details,
                        style: context
                            .getTitleMediumTextStyle(context.onSurfaceColor),
                      ),
                      children: [
                        // === note
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: provider.state.isNotesActive,
                          onChanged: provider.changeNotesActiveStatus,
                          title: Text(
                            S.current.notes,
                            style: context.getTitleMediumTextStyle(
                                context.onSurfaceColor),
                          ),
                          activeColor: context.primaryColor,
                        ),
                        Builder(builder: (context) {
                          if (provider.state.isNotesActive) {
                            return Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: MTextFormField(
                                controller: notesController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                labelText: S.current.notes,
                                hintText: S.current.notes_placeholder,
                              ),
                            );
                          }
                          return Opacity(opacity: 0);
                        }),
                        // === note

                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Divider(
                            color: MColors.divider,
                          ),
                        ),

                        // === terms condition
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: provider.state.isTermsConditionActive,
                          onChanged: provider.changeTermsConditionStatus,
                          title: Text(
                            S.current.terms_and_condition,
                            style: context.getTitleMediumTextStyle(
                                context.onSurfaceColor),
                          ),
                          activeColor: context.primaryColor,
                        ),
                        Builder(builder: (context) {
                          if (provider.state.isTermsConditionActive) {
                            return Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: MTextFormField(
                                controller: termsConditionController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                maxLines: 3,
                                labelText: S.current.terms_and_condition,
                              ),
                            );
                          }
                          return Opacity(opacity: 0);
                        })
                        // === terms condition
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 20),
            child: Divider(),
          ),

          // === sub total
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  int subTotalNativePrice = 0;
                  provider.state.billProductItem.forEach((element) {
                    subTotalNativePrice += element.price * element.qty;
                  });
                  return TotalItemsPriceDetail(
                    title: S.current.total_item_price,
                    value: NumberFormat("#,###").format(subTotalNativePrice),
                  );
                }),
              ],
            ),
          ),
          // === sub total

          // === tax
          Container(
            margin: EdgeInsets.only(top: 15),
            child: TotalItemsPriceDetail(
              title: S.current.total_tax,
              value: NumberFormat("#,###").format(provider.state.tax),
            ),
          ),
          // === tax

          // === discount
          Container(
            margin: EdgeInsets.only(top: 15),
            child: TotalItemsPriceDetail(
              title: S.current.total_item_discount,
              value: provider.state.discount == 0
                  ? "0"
                  : "-${NumberFormat("#,###").format(provider.state.discount)}",
            ),
          ),
          // === discount

          // === other tax
          Builder(builder: (context) {
            if (provider.state.billProductItem.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: provider.state.selectedCharges
                            .where((element) => element.isSelected == true)
                            .toList()
                            .length,
                        shrinkWrap: true,
                        physics: customScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          List<InvoiceChargeModel> finalListSelectedCharges = [
                            ...provider.state.selectedCharges
                                .where((element) => element.isSelected == true)
                                .toList()
                          ];
                          String title = finalListSelectedCharges[index].type ==
                                  'percent'
                              ? "${finalListSelectedCharges[index].name} (${finalListSelectedCharges[index].value}% ${S.current.from.toLowerCase()} ${S.current.total_price})"
                              : finalListSelectedCharges[index].name;
                          String valuePercentageToNominal =
                              "${finalListSelectedCharges[index].operation == '-' ? '-' : ''}${NumberFormat('#,###').format((finalListSelectedCharges[index].value / 100) * (provider.state.subTotal + provider.state.tax))}";
                          String valueNominal =
                              "${finalListSelectedCharges[index].operation == '-' ? '-' : ''}${NumberFormat('#,###').format(finalListSelectedCharges[index].value)}";
                          return Container(
                            margin: EdgeInsets.only(top: 15),
                            child: TotalItemsPriceDetail(
                              title: title,
                              value: finalListSelectedCharges[index].type ==
                                      'percent'
                                  ? valuePercentageToNominal
                                  : valueNominal,
                            ),
                          );
                        }),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(top: 15),
                    child: GestureDetector(
                      onTap: () {
                        changeCharges();
                      },
                      child: Text(
                        "+ ${S.current.other_tax_and_discount}",
                        textAlign: TextAlign.right,
                        style: context
                            .getTitleMediumTextStyle(MColors.primaryBlue),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Opacity(opacity: 0);
          }),
          // === other tax

          // === total price
          Container(
            margin: EdgeInsets.only(top: 35),
            child: TotalItemsPriceDetail(
              title: S.current.total_price,
              value: NumberFormat("#,###").format(provider.state.finalPrice),
              isBold: true,
            ),
          ),
          // === total price
        ],
      ),
    );
    return RefreshIndicator(
      onRefresh: () async {
        loadInvoiceForm();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
        physics: customScrollPhysics(alwaysScroll: true),
      ),
    );
  }

  showDatePicker({required bool isInvoiceDate}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: SfDateRangePicker(
                  onSelectionChanged: (arg) {
                    provider.changeDate(
                      isInvoiceDate: isInvoiceDate,
                      newDate: arg.value,
                    );
                    if (isInvoiceDate) {
                      invoiceDateController.text =
                          getDateddMMMyyyy(provider.state.invoiceDate);
                    } else {
                      dueDateController.text =
                          getDateddMMMyyyy(provider.state.dueDate);
                    }
                    Navigator.of(context).pop();
                  },
                  onSubmit: (arg) {},
                  todayHighlightColor: context.primaryColor,
                  selectionColor: context.primaryColor,
                  rangeSelectionColor: context.primaryColor.withOpacity(0.1),
                  startRangeSelectionColor: context.primaryColor,
                  endRangeSelectionColor: context.primaryColor,
                  maxDate: DateTime.now().add(Duration(days: 30)),
                  initialDisplayDate: DateTime.now(),
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  allowViewNavigation: true,
                  headerStyle: DateRangePickerHeaderStyle(
                    textStyle:
                        context.getTitleMediumTextStyle(context.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

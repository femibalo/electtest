import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../api/invoice_api.dart';
import '../api/item_api.dart';
import '../model/bill_product_item_model.dart';
import '../model/billing_entity_model.dart';
import '../model/client_invoice_model.dart';
import '../model/invoice_charge_model.dart';
import '../model/invoice_list_model.dart';
import '../utils/utils.dart';
import 'billing-entity/billing_entity_screen.dart';
import 'charges/invoice_charges_screen.dart';
import 'client/client_screen.dart';
import 'components/error_screens.dart';
import 'components/form_text_field.dart';
import 'components/item_in_add_invoice.dart';
import 'components/snack_bar.dart';
import 'items/components/price_detail.dart';
import 'items/items_screen.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Invoices? invoice;
  final bool isEditMode;

  const AddInvoiceScreen({
    Key? key,
    this.invoice,
    this.isEditMode = false,
  }) : super(key: key);

  static void launchScreen(BuildContext context,
      {int? invoiceId, bool? isEditMode}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddInvoiceScreen()));
  }

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late InvoicesProvider provider;
  late InvoiceItemProvider invoiceItemProvider;
  final formKey = GlobalKey<FormState>();
  final invoiceNameController = TextEditingController();
  final notesController = TextEditingController();
  final termsConditionController = TextEditingController();
  String symbol = '\$';
  String code = '\$';
  final invoiceDateController = TextEditingController();
  final dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoicesProvider>(context, listen: false);
    invoiceItemProvider =
        Provider.of<InvoiceItemProvider>(context, listen: false);
    symbol = context.read<InvoiceItemProvider>().state.selectedCurrency.symbol;
    code = context.read<InvoiceItemProvider>().state.selectedCurrency.code;
    if (widget.isEditMode) {
      init(invoices: widget.invoice!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadInvoiceForm();
    });
  }

  loadInvoiceForm() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
  }

  init({required Invoices invoices}) {
    provider.state.selectedBillingEntity = BillingEntityProfiles(
        id: invoices.profileID,
        name: invoices.profileName,
        email: invoices.profileEmail,
        logoURL: invoices.logoURL);
    provider.state.selectedClient = UserClientInvoice(
        id: invoices.clientID,
        name: invoices.clientName,
        email: invoices.clientEmail,
        phone: invoices.clientPhone,
        billingAddress: invoices.clientAddress);
    provider.state.billProductItem = invoices.items;
    provider.state.selectedCharges = invoices.custom;
    provider.state.isDueDateActive = false;
    provider.state.isTermsConditionActive = false;
    provider.state.isNotesActive = false;
    if (invoices.dueDate.isNotEmpty) {
      provider.state.dueDate = getDateFromString(invoices.dueDate);
    }
    notesController.text = invoices.description;
    termsConditionController.text = invoices.termsAndConditions;
    invoiceNameController.text = invoices.invoiceID;
    provider.state.invoiceDate = getDateFromString(invoices.invoiceDate);
    provider.state.subTotal = invoices.totalPrice;
    provider.state.tax = invoices.totalTaxPrice;
    provider.state.discount = invoices.totalDiscountPrice;
    provider.state.finalPrice = invoices.finalPrice;
  }

  reset() {
    provider.state.selectedBillingEntity = const BillingEntityProfiles();
    provider.state.selectedClient = const UserClientInvoice();
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
        text: 'entity selected',
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
        text: 'client selected',
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
          text: 'due date must after invoice date',
          snackBarType: SnackBarType.error,
        );
      } else if (provider.state.selectedClient.id == 0) {
        showSnackBar(
          context: context,
          text: 'client empty',
          snackBarType: SnackBarType.error,
        );
      } else if (provider.state.billProductItem.isEmpty) {
        showSnackBar(
          context: context,
          text: 'item empty',
          snackBarType: SnackBarType.error,
        );
      } else {
        if (widget.isEditMode) {
          updateData();
        } else {
          saveData();
        }
      }
    }
  }

  updateData() {
    provider
        .update(
      id: widget.invoice?.id ?? 0,
      finalPrice: provider.state.finalPrice,
      totalPrice: provider.state.subTotal,
      totalDiscount: provider.state.discount,
      totalTax: provider.state.tax,
      currencyCode: symbol,
      invoiceName: invoiceNameController.text.toString(),
      description: notesController.text.toString(),
      termsAndConditions: provider.state.isTermsConditionActive
          ? termsConditionController.text.toString()
          : "",
    )
        .then((value) {
      if (value) {
        Navigator.pop(context);
        showSnackBar(
          context: context,
          text: 'Register updated',
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          context: context,
          text: 'Update error',
          snackBarType: SnackBarType.success,
        );
      }
    });
  }

  saveData() {
    provider
        .saveData(
      finalPrice: provider.state.finalPrice,
      totalPrice: provider.state.subTotal,
      totalDiscount: provider.state.discount,
      totalTax: provider.state.tax,
      currencyCode:
          context.read<InvoiceItemProvider>().state.selectedCurrency.symbol,
      invoiceName: invoiceNameController.text.toString(),
      description: notesController.text.toString(),
      termsAndConditions: provider.state.isTermsConditionActive
          ? termsConditionController.text.toString()
          : "",
    )
        .then((value) {
      if (value) {
        Navigator.pop(context);
        showSnackBar(
          context: context,
          text: 'Add Register Success',
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          context: context,
          text: 'Add error',
          snackBarType: SnackBarType.success,
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
      backgroundColor: Colors.grey[100],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildSaveButton(provider.state),
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Register'.tr() : 'New Register'.tr(),
        ),
        // actions: [_buildSaveButton(provider.state)]
      ),
      body: Container(
          height: MediaQuery.of(context).size.height / 1,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/images/background.png",
              ),
            ),
          ),
          child: _getWidgetBasedOnState(provider.state)),
    );
  }

  Widget _getWidgetBasedOnState(InvoicesProviderState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
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
      return const SizedBox();
    }

    if (state.isError) {
      return const SizedBox();
    }

    if (state.loading) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          //change width and height on your need width = 200 and height = 50
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          validation();
        },
        child: Text('Save'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _successContent(InvoicesProviderState state) {
    List<Widget> children = [];
    invoiceDateController.text = getDateddMMMyyyy(state.invoiceDate);
    dueDateController.text = getDateddMMMyyyy(state.dueDate);
    children.add(
      ListView(
        physics: customScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          right: 20.0,
          left: 20.0,
          bottom: 20,
          top: 20,
        ),
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === billing entity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('Assessor'.tr(),
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          height: MediaQuery.of(context).size.height * 0.04,
                          child: ElevatedButton(
                            onPressed: () {
                              changeEntity();
                            },
                            child: Text('Edit'.tr(),
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ),
                      ],
                    ),
                    ListTile(
                      onTap: () {
                        changeEntity();
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: provider.state.selectedBillingEntity.logoURL
                                  .toString()
                                  .isNotEmpty ==
                              true
                          ? CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: FileImage(File(provider
                                  .state.selectedBillingEntity.logoURL
                                  .toString())),
                            )
                          : const Icon(Icons.add_a_photo),
                      title: provider.state.selectedBillingEntity.name
                                  .toString()
                                  .isNotEmpty ==
                              true
                          ? Text(
                              provider.state.selectedBillingEntity.name
                                  .toString(),
                              style: Theme.of(context).textTheme.titleLarge)
                          : Text(
                              'Add Assessor'.tr(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                    ),
                  ],
                ),
                // === billing entity

                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: const Divider(),
                ),

                // === invoice name
                // Container(
                //   margin: const EdgeInsets.only(
                //     left: 5,
                //     top: 14,
                //   ),
                //   child: Text('invoice_details'.tr(),
                //       style: Theme.of(context).textTheme.titleLarge),
                // ),
                // Card(
                //   shape: RoundedRectangleBorder(
                //       side: BorderSide(
                //         color: Colors.green.withOpacity(0.3),
                //       ),
                //       borderRadius: BorderRadius.circular(15)),
                //   elevation: 4,
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 12),
                //     child: TextFormField(
                //       maxLength: 1000,
                //       decoration: InputDecoration(
                //           border: InputBorder.none,
                //           focusedBorder: InputBorder.none,
                //           enabledBorder: InputBorder.none,
                //           errorBorder: InputBorder.none,
                //           disabledBorder: InputBorder.none,
                //           hintText: "add_details".tr()),
                //       controller: invoiceNameController,
                //       textInputAction: TextInputAction.next,
                //       textCapitalization: TextCapitalization.words,
                //       maxLines: 1,
                //       validator: (string) {
                //         if (string.toString().isEmpty) {
                //           return 'invoice_name_empty'.tr();
                //         }
                //         return null;
                //       },
                //     ),
                //   ),
                // ),
                // === invoice name

                // date
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Date'.tr(),
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            // Expanded(
                            //   child: SwitchListTile(
                            //     contentPadding: EdgeInsets.zero,
                            //     dense: true,
                            //     onChanged: (val) {
                            //       provider.changeDueDateStatus(val);
                            //     },
                            //     value: provider.state.isDueDateActive,
                            //     title: Text('due_date'.tr(),
                            //         style:
                            //             Theme.of(context).textTheme.titleLarge),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0),
                                    child: MTextFormField(
                                      controller: invoiceDateController,
                                      maxLines: 1,
                                      onTap: () {
                                        showDatePicker(
                                          isInvoiceDate: true,
                                        );
                                      },
                                      labelText: 'Register Date'.tr(),
                                      readOnly: true,
                                      suffixIcon: const Padding(
                                        padding: EdgeInsets.only(right: 5.0),
                                        child: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 22,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // Expanded(
                                //   child: MTextFormField(
                                //     controller: dueDateController,
                                //     readOnly: true,
                                //     maxLines: 1,
                                //     hintText: state.invoiceDate.toString(),
                                //     enabled: provider.state.isDueDateActive,
                                //     onTap: provider.state.isDueDateActive
                                //         ? () {
                                //             showDatePicker(
                                //               isInvoiceDate: false,
                                //             );
                                //           }
                                //         : null,
                                //     labelText: 'due_date'.tr(),
                                //     suffixIcon: const Padding(
                                //       padding: EdgeInsets.only(right: 5.0),
                                //       child: Icon(
                                //         Icons.calendar_today_outlined,
                                //         size: 22,
                                //         color: Colors.black,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // === date
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: const Divider(),
                ),

                // === client name
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text('Client Details'.tr(),
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.21,
                            height: MediaQuery.of(context).size.height * 0.04,
                            child: Builder(builder: (ctx) {
                              if (provider.state.selectedClient.id != 0) {
                                return ElevatedButton(
                                    onPressed: () {
                                      changeClient();
                                    },
                                    child: Text('Edit'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge));
                              }
                              return ElevatedButton(
                                  onPressed: () {
                                    changeClient();
                                  },
                                  child: Text('Add'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge));
                            }),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
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
                              ),
                            );
                          }
                          return const Opacity(opacity: 0);
                        }),
                      ),
                    ],
                  ),
                ),
                // === client name

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Divider(),
                ),

                // add bill product or item button
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Equipment Items'.tr(),
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          height: MediaQuery.of(context).size.height * 0.04,
                          child: Builder(builder: (ctx) {
                            if (provider.state.billProductItem.isEmpty) {
                              return ElevatedButton(
                                  onPressed: () {
                                    changeItems();
                                  },
                                  child: Text('Add'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge));
                            }
                            return ElevatedButton(
                                onPressed: () {
                                  changeItems();
                                },
                                child: Text('Edit'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge));
                          })),
                    ],
                  ),
                ),
                // add bill product or item button

                // bill product or item list
                ListView.builder(
                  itemCount: provider.state.billProductItem.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (ctx, index) {
                    return ItemInAddInvoiceScreen(
                      model: provider.state.billProductItem[index],
                    );
                  },
                ),
                // bill product or item list

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Divider(),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      children: [
                        // Existing ExpansionTile for Additional Details
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          initiallyExpanded: provider.state.detailInvoiceForEdit
                                      .description.isNotEmpty ||
                                  provider.state.detailInvoiceForEdit
                                      .termsAndConditions.isNotEmpty
                              ? true
                              : false,
                          title: Text('Additional Details'.tr(),
                              style: Theme.of(context).textTheme.titleLarge),
                          children: [
                            // Note Switch
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: provider.state.isNotesActive,
                              onChanged: provider.changeNotesActiveStatus,
                              title: Text('notes'.tr(),
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            Builder(builder: (context) {
                              if (provider.state.isNotesActive) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: MTextFormField(
                                    controller: notesController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    labelText: 'notes'.tr(),
                                    hintText: 'notes_placeholder'.tr(),
                                  ),
                                );
                              }
                              return const Opacity(opacity: 0);
                            }),
                            // Divider
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: const Divider()),

                            // Terms and Conditions Switch
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: provider.state.isTermsConditionActive,
                              onChanged: provider.changeTermsConditionStatus,
                              title: Text('terms_and_condition'.tr()),
                            ),
                            Builder(builder: (context) {
                              if (provider.state.isTermsConditionActive) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: MTextFormField(
                                    controller: termsConditionController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 3,
                                    labelText: 'terms_and_condition'.tr(),
                                  ),
                                );
                              }
                              return const Opacity(opacity: 0);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Divider(),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      children: [
                        // Existing ExpansionTile for Additional Details
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          initiallyExpanded: provider.state.detailInvoiceForEdit
                                      .description.isNotEmpty ||
                                  provider.state.detailInvoiceForEdit
                                      .termsAndConditions.isNotEmpty
                              ? true
                              : false,
                          title: Text('Additional Details'.tr(),
                              style: Theme.of(context).textTheme.titleLarge),
                          children: [
                            // Note Switch
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: provider.state.isNotesActive,
                              onChanged: provider.changeNotesActiveStatus,
                              title: Text('notes'.tr(),
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            Builder(builder: (context) {
                              if (provider.state.isNotesActive) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: MTextFormField(
                                    controller: notesController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    labelText: 'notes'.tr(),
                                    hintText: 'notes_placeholder'.tr(),
                                  ),
                                );
                              }
                              return const Opacity(opacity: 0);
                            }),
                            // Divider
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: const Divider()),

                            // Terms and Conditions Switch
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: provider.state.isTermsConditionActive,
                              onChanged: provider.changeTermsConditionStatus,
                              title: Text('terms_and_condition'.tr()),
                            ),
                            Builder(builder: (context) {
                              if (provider.state.isTermsConditionActive) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: MTextFormField(
                                    controller: termsConditionController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 3,
                                    labelText: 'terms_and_condition'.tr(),
                                  ),
                                );
                              }
                              return const Opacity(opacity: 0);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Divider(),
          ),

          // === sub total
          // Container(
          //   margin: const EdgeInsets.only(top: 20),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Builder(builder: (context) {
          //         return TotalItemsPriceDetail(
          //           title: 'total_item_price'.tr(),
          //           value:
          //               '${NumberFormat("#,###").format(provider.state.subTotal)}$symbol',
          //         );
          //       }),
          //     ],
          //   ),
          // ),
          // === sub total

          // === tax
          // Container(
          //   margin: const EdgeInsets.only(top: 10),
          //   child: TotalItemsPriceDetail(
          //     title: 'total_tax'.tr(),
          //     value:
          //         '${NumberFormat("#,###").format(provider.state.tax)}$symbol',
          //   ),
          // ),
          // === tax

          // === discount
          // Container(
          //   margin: const EdgeInsets.only(top: 10),
          //   child: TotalItemsPriceDetail(
          //     title: 'total_item_discount'.tr(),
          //     value: provider.state.discount == 0
          //         ? "0$symbol"
          //         : "-${NumberFormat("#,###").format(provider.state.discount)}$symbol",
          //   ),
          // ),
          // === discount

          // === other tax
          Builder(builder: (context) {
            if (provider.state.billProductItem.isNotEmpty) {
              return Column(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: provider.state.selectedCharges
                          .where((element) => element.isSelected == true)
                          .toList()
                          .length,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        List<InvoiceChargeModel> finalListSelectedCharges = [
                          ...provider.state.selectedCharges
                              .where((element) => element.isSelected == true)
                              .toList()
                        ];
                        String title = finalListSelectedCharges[index].type ==
                                'percent'
                            ? "${finalListSelectedCharges[index].name} (${finalListSelectedCharges[index].value}% from total price)"
                            : finalListSelectedCharges[index].name;
                        String valuePercentageToNominal =
                            "${finalListSelectedCharges[index].operation == '-' ? '-' : ''}${NumberFormat('#,###').format((finalListSelectedCharges[index].value / 100) * (provider.state.subTotal + provider.state.tax))}";
                        String valueNominal =
                            "${finalListSelectedCharges[index].operation == '-' ? '-' : ''}${NumberFormat('#,###').format(finalListSelectedCharges[index].value)}";
                        return Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: TotalItemsPriceDetail(
                            title: title,
                            value: finalListSelectedCharges[index].type ==
                                    'percent'
                                ? valuePercentageToNominal
                                : valueNominal,
                          ),
                        );
                      }),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        changeCharges();
                      },
                      child: Text("_other_tax_and_discount".tr(),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                ],
              );
            }
            return const Opacity(opacity: 0);
          }),
          // === other tax

          // === total price
          // Container(
          //   margin: const EdgeInsets.only(top: 10),
          //   child: TotalItemsPriceDetail(
          //     title: 'total_price'.tr(),
          //     value:
          //         '${NumberFormat("#,###").format(provider.state.finalPrice)}$symbol',
          //     isBold: true,
          //   ),
          // ),

          // === total price
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
    return RefreshIndicator(
      onRefresh: () async {
        loadInvoiceForm();
      },
      child: ListView(
        physics: customScrollPhysics(alwaysScroll: true),
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }

  showDatePicker({required bool isInvoiceDate}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(
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
                    } else {}
                    Navigator.of(context).pop();
                  },
                  onSubmit: (arg) {},
                  todayHighlightColor: Colors.blue,
                  selectionColor: Colors.blue,
                  rangeSelectionColor: Colors.blue.withOpacity(0.1),
                  startRangeSelectionColor: Colors.blue,
                  endRangeSelectionColor: Colors.blue,
                  maxDate: DateTime.now().add(const Duration(days: 30)),
                  initialDisplayDate: DateTime.now(),
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  allowViewNavigation: true,
                  headerStyle: const DateRangePickerHeaderStyle(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

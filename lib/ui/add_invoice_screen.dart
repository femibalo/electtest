import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_management/ui/items/add_invoice_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../api/invoice_api.dart';
import '../model/bill_product_item_model.dart';
import '../model/billing_entity_model.dart';
import '../model/client_invoice_model.dart';
import '../model/invoice_charge_model.dart';
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
  final int invoiceId;
  final bool isEditMode;

  const AddInvoiceScreen({
    Key? key,
    this.invoiceId = 0,
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

        });
  }

  changeCharges() {
    InvoiceChargesScreen.launchScreen(
        context: context,
        selectedChargesFromAddInvoiceScreen: provider.state.selectedCharges.toList(),
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
      showSnackBar(
        context: context,
        text: 'add invoice success',
        snackBarType: SnackBarType.success,
      );
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
      appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'edit invoice' : 'new invoice',
          ),
          actions: [_buildSaveButton(provider.state)]),
      body: _getWidgetBasedOnState(provider.state),
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
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          validation();
        },
        child: Text('Save',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('billing entity',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: ElevatedButton(
                            onPressed: () {
                              changeEntity();
                            },
                            child: Text('Edit',
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        left: 5,
                      ),
                      child: ListTile(
                        onTap: () {
                          changeEntity();
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                              // provider.state.selectedBillingEntity.logoURL.toString(),
                              'https://img.freepik.com/premium-vector/abstract-bird-logo-design_99536-200.jpg'),
                        ),
                        title: Text(
                            // provider.state.selectedBillingEntity.name.toString(),
                            'selectedBillingEntity',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                  ],
                ),
                // === billing entity

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Divider(),
                ),

                // === invoice name
                Container(
                  margin: const EdgeInsets.only(
                    left: 5,
                    top: 20,
                  ),
                  child: Text('Invoice details',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 25.0,
                  ),
                  child: TextFormField(
                    controller: invoiceNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return 'invoice name empty';
                      }
                      return null;
                    },
                  ),
                ),
                // === invoice name

                // date
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('date',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                onChanged: (val) {
                                  provider.changeDueDateStatus(val);
                                },
                                value: provider.state.isDueDateActive,
                                title: Text('due date',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ),
                            ),
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
                                  child: MTextFormField(
                                    controller: invoiceDateController,
                                    maxLines: 1,
                                    onTap: () {
                                      showDatePicker(
                                        isInvoiceDate: true,
                                      );
                                    },
                                    labelText: 'Invoice date',
                                    readOnly: true,
                                    suffixIcon: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 22,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: MTextFormField(
                                    controller: dueDateController,
                                    readOnly: true,
                                    maxLines: 1,
                                    hintText: state.invoiceDate.toString(),
                                    enabled: provider.state.isDueDateActive,
                                    onTap: provider.state.isDueDateActive
                                        ? () {
                                            showDatePicker(
                                              isInvoiceDate: false,
                                            );
                                          }
                                        : null,
                                    labelText: 'Due date',
                                    suffixIcon: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 22,
                                          color: Colors.grey,
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
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text('client details',
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.21,
                            child: Builder(builder: (ctx) {
                              if (provider.state.selectedClient.id != 0) {
                                return ElevatedButton(
                                    onPressed: () {
                                      changeClient();
                                    },
                                    child: Text('edit',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge));
                              }
                              return ElevatedButton(
                                  onPressed: () {
                                    changeClient();
                                  },
                                  child: Text('add',
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
                        child: Text('item details',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: Builder(builder: (ctx) {
                            if (provider.state.billProductItem.isEmpty) {
                              return ElevatedButton(
                                  onPressed: () {
                                    changeItems();
                                  },
                                  child: Text('add',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge));
                            }
                            return ElevatedButton(
                                onPressed: () {
                                  changeItems();
                                },
                                child: Text('edit',
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
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      initiallyExpanded: provider.state.detailInvoiceForEdit
                                  .description.isNotEmpty ||
                              provider.state.detailInvoiceForEdit
                                  .termsAndConditions.isNotEmpty
                          ? true
                          : false,
                      title: Text('additional details',
                          style: Theme.of(context).textTheme.titleLarge),
                      children: [
                        // === note
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: provider.state.isNotesActive,
                          onChanged: provider.changeNotesActiveStatus,
                          title: const Text(
                            'notes',
                          ),
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
                                labelText: 'notes',
                                hintText: 'notes placeholder',
                              ),
                            );
                          }
                          return const Opacity(opacity: 0);
                        }),
                        // === note

                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Divider(),
                        ),

                        // === terms condition
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: provider.state.isTermsConditionActive,
                          onChanged: provider.changeTermsConditionStatus,
                          title: const Text(
                            'terms and condition',
                          ),
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
                                labelText: 'terms and condition',
                              ),
                            );
                          }
                          return const Opacity(opacity: 0);
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
            margin: const EdgeInsets.only(top: 20),
            child: const Divider(),
          ),

          // === sub total
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  int subTotalNativePrice = 0;
                  for (var element in provider.state.billProductItem) {
                    subTotalNativePrice += element.price * element.qty;
                  }
                  return TotalItemsPriceDetail(
                    title: 'total_item_price',
                    value: NumberFormat("#,###").format(subTotalNativePrice),
                  );
                }),
              ],
            ),
          ),
          // === sub total

          // === tax
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: TotalItemsPriceDetail(
              title: 'total tax',
              value: NumberFormat("#,###").format(provider.state.tax),
            ),
          ),
          // === tax

          // === discount
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: TotalItemsPriceDetail(
              title: 'total item discount',
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
                    margin: const EdgeInsets.only(top: 15),
                    child: GestureDetector(
                      onTap: () {
                        changeCharges();
                      },
                      child: Text("+ other tax and discount",
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
          Container(
            margin: const EdgeInsets.only(top: 35),
            child: TotalItemsPriceDetail(
              title: 'total price',
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

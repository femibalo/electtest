// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/routes/app_routing.gr.dart';
import 'package:mezink_app/screens/invoices/api/invoice_api.dart';
import 'package:mezink_app/screens/invoices/model/invoice_charge_model.dart';
import 'package:mezink_app/screens/invoices/ui/charges/add_invoice_charge_screen.dart';
import 'package:mezink_app/screens/invoices/ui/charges/components/item_list.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../../utils/common/snack_bar.dart';
import '../../api/invoice_charge_api.dart';

class InvoiceChargesScreen extends StatefulWidget {
  final List<InvoiceChargeModel> selectedChargesFromAddInvoiceScreen;
  final void Function(List<InvoiceChargeModel>) onSaveSelectedCharges;
  const InvoiceChargesScreen({
    Key? key,
    required this.selectedChargesFromAddInvoiceScreen,
    required this.onSaveSelectedCharges,
  }) : super(key: key);

  static const String id = "invoiceCharges";
  static void launchScreen({required BuildContext context, 
  required List<InvoiceChargeModel> selectedChargesFromAddInvoiceScreen, 
  required Function(List<InvoiceChargeModel>) onSaveSelectedCharges}) {
     context.router.push<List<InvoiceChargeModel>>(
        InvoiceChargesScreenRoute(selectedChargesFromAddInvoiceScreen: selectedChargesFromAddInvoiceScreen, 
        onSaveSelectedCharges: onSaveSelectedCharges,));
  }

  @override
  State<InvoiceChargesScreen> createState() => _InvoiceChargesScreenState();
}

class _InvoiceChargesScreenState extends State<InvoiceChargesScreen> {
  late InvoiceChargeProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoiceChargeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getSelectedCharges();
    });
  }

  getSelectedCharges() {
    provider.setSelectedChargesFromAddInvoiceScreen(
        widget.selectedChargesFromAddInvoiceScreen);
  }

  addChargesToAddInvoiceScreen() {
    widget.onSaveSelectedCharges(provider.selectedCharges.toList());
    context.router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceChargeProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: S.current.other_charges,
        actions: [_buildSaveButton()],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        physics: customScrollPhysics(),
        children: [
          // === add charge button
          Container(
            margin: EdgeInsets.only(
              top: 10,
            ),
            child: InkWell(
              onTap: () {
                AddInvoiceChargeScreen.launchScreen(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/add_charges.png",
                      width: 20,
                      height: 20,
                      color: context.primaryColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      S.current.add_new_charge,
                      style: context.getTitleMediumTextStyle(context.primaryColor),
                    )
                  ],
                ),
              ),
            ),
          ),
          // === add charge button

          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            child: Divider(),
          ),

          Builder(builder: (context) {
            if (provider.selectedCharges.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      S.current.previous_charges,
                      style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                    ),
                  ),
                  ListView.builder(
                    itemCount: provider.selectedCharges.length,
                    shrinkWrap: true,
                    physics: customScrollPhysics(),
                    padding: EdgeInsets.only(top: 10),
                    itemBuilder: (ctx, index) {
                      return ItemListChargesInvoice(
                        model: provider.selectedCharges[index],
                        onTap: () {
                          provider.changeSelectedCharges(index: index);
                        },
                        onEdit: () {
                          context.router
                              .push(AddInvoiceChargeScreenRoute(
                            isEditMode: true,
                            indexCharge: index,
                          ))
                              .then((value) {
                            Provider.of<InvoicesProvider>(
                              context,
                              listen: false,
                            ).changeFullSelectedChargesFromInvoiceChargesScreen(
                              newList: provider.selectedCharges.toList(),
                            );
                          });
                        },
                        onDelete: () {
                          if (provider.selectedCharges[index].isSelected) {
                            showSnackBar(
                              context: context,
                              text: S.current.delete_selected_charge,
                              snackBarType: SnackBarType.error,
                            );
                          } else {
                            Future.delayed(
                              const Duration(seconds: 0),
                              () {
                                showCustomAlertDialog(
                                  title: S.current.delete,
                                  subTitle: S.current
                                      .are_you_sure_want_to_delete_charge,
                                  context: context,
                                  leftButtonText: S.current.yes,
                                  rightButtonText: S.current.cancel,
                                  onLeftButtonClicked: () {
                                    Navigator.of(context).pop();
                                    provider.deleteCharge(index);
                                    Provider.of<InvoicesProvider>(
                                      context,
                                      listen: false,
                                    ).changeFullSelectedChargesFromInvoiceChargesScreen(
                                      newList:
                                          provider.selectedCharges.toList(),
                                    );
                                    showSnackBar(
                                      context: context,
                                      text: S.current.delete_charge_success,
                                      snackBarType: SnackBarType.success,
                                    );
                                  },
                                  onRightButtonClicked: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            }
            return Opacity(opacity: 0);
          })
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
          addChargesToAddInvoiceScreen();
        },
        child: Text(S.current.save),
      ),
    );
  }
}

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:mezink_app/commands/email_validator.dart';
import 'package:mezink_app/components/error_screens.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/routes/app_routing.gr.dart';
import 'package:mezink_app/screens/invoices/api/client_api.dart';
import 'package:mezink_app/screens/invoices/model/client_invoice_model.dart';
import 'package:mezink_app/styles/progress_indicator.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/common/snack_bar.dart';

class AddClientScreen extends StatefulWidget {
  final int clientID;
  final bool isEditMode;
  final Function(UserClientInvoice) onSavedNewClient;
  const AddClientScreen({
    Key? key,
    this.clientID = 0,
    this.isEditMode = false,
    required this.onSavedNewClient,
  }) : super(key: key);

  static const String id = "addClientInvoice";
  static void launchScreen(BuildContext context, int clientId, bool isEditMode,
      Function(UserClientInvoice) onSaved) {
    context.router.push<UserClientInvoice>(AddClientScreenRoute(
        onSavedNewClient: onSaved, clientID: clientId, isEditMode: isEditMode));
  }

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  late ClientInvoiceProvider provider;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final displayNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final billingAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final billingPhoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ClientInvoiceProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadForm();
    });
  }

  loadForm() {
    setState(() {
      provider.states.isError = false;
      provider.states.isNetworkError = false;
    });
    if (widget.isEditMode) {
      provider.getDetailClient(widget.clientID).then((value) {
        if (value != false) {
          var selectedDetailClient = provider.states.selectedDetailClient;
          // if return true == success load data from api
          nameController.text = selectedDetailClient.name.toString();
          emailController.text = selectedDetailClient.email.toString();
          phoneController.text = selectedDetailClient.phone.toString();
          billingAddressController.text =
              selectedDetailClient.billingAddress.toString();
          cityController.text = selectedDetailClient.city.toString();
          stateController.text = selectedDetailClient.state.toString();
          pinCodeController.text = selectedDetailClient.pinCode.toString();
          billingPhoneNumberController.text =
              selectedDetailClient.billingPhoneNumber.toString();
          displayNameController.text =
              selectedDetailClient.displayName.toString();

          // check if add billing address not empty, will set active add billing address status
          if (billingAddressController.text.isNotEmpty ||
              cityController.text.isNotEmpty ||
              stateController.text.isNotEmpty ||
              pinCodeController.text.isNotEmpty ||
              billingPhoneNumberController.text.isNotEmpty) {
            provider.changeStatusBillingAddress(true);
          }
        }
      });
    }
  }

  validation() {
    if (formKey.currentState!.validate()) {
      saveData();
    }
  }

  saveData() {
    provider
        .saveData(
      id: widget.clientID,
      name: nameController.text.toString(),
      email: emailController.text.toString(),
      phone: phoneController.text.toString(),
      billingAddress: billingAddressController.text.toString(),
      city: cityController.text.toString(),
      state: stateController.text.toString(),
      pinCode: pinCodeController.text.toString(),
      billingPhoneNumber: billingPhoneNumberController.text.toString(),
      displayName: displayNameController.toString().isEmpty
          ? nameController.text.toString()
          : displayNameController.text.toString(),
    )
        .then((value) {
      if (value.success) {
        widget.onSavedNewClient(UserClientInvoice(
          id: value.data, // entity id from api return
          name: nameController.text.toString(),
          email: emailController.text.toString(),
          phone: phoneController.text.toString(),
          billingAddress: billingAddressController.text.toString(),
          city: cityController.text.toString(),
          state: stateController.text.toString(),
          pinCode: pinCodeController.text.toString(),
          billingPhoneNumber: billingPhoneNumberController.text.toString(),
          displayName: displayNameController.toString().isEmpty
              ? nameController.text.toString()
              : displayNameController.text.toString(),
        ));
        reset();
        if (widget.isEditMode) {
          showSnackBar(
            context: context,
            text: S.current.edit_client_success,
            snackBarType: SnackBarType.success,
          );
          return;
        } else {
          showSnackBar(
            context: context,
            text: S.current.add_client_success,
            snackBarType: SnackBarType.success,
          );
          return;
        }
      } else {
        showSnackBar(
          context: context,
          text: value.error,
          snackBarType: SnackBarType.error,
        );
        return;
      }
    });
  }

  reset() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    billingAddressController.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
    billingPhoneNumberController.clear();
    displayNameController.clear();
    provider.states.isAddBillingAddressActive = false;
  }

  importContact() async {
    if (Platform.isAndroid) {
      await FlutterContactPicker.pickFullContact().then((value) {
        nameController.text = "${value.name?.nickName}";
        displayNameController.text = "${value.name?.nickName}";
        emailController.text =
            value.emails.isNotEmpty ? value.emails.first.email.toString() : "";
        phoneController.text =
            value.phones.isNotEmpty ? value.phones.first.number.toString() : "";
      });
    } else if (Platform.isIOS) {
      await FlutterContactPicker.pickEmailContact().then((value) {
        nameController.text = value.fullName.toString();
        emailController.text = value.email.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    reset();
    disposingResources();
  }

  disposingResources() {
    nameController.dispose();
    displayNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    billingAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    billingPhoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientInvoiceProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: widget.isEditMode
            ? S.current.edit_client
            : S.current.add_new_client,
        actions: [_buildSaveButton(provider.states)],
      ),
      body: _getWidgetBasedOnState(provider.states),
    );
  }

  Widget _buildSaveButton(ClientInvoiceState state) {
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

  Widget _getWidgetBasedOnState(ClientInvoiceState state) {
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

  Widget _successContent(ClientInvoiceState state) {
    List<Widget> children = [];
    children.add(
      ListView(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        physics: customScrollPhysics(),
        shrinkWrap: true,
        children: [
          // === import client button
          Container(
            margin: EdgeInsets.only(
              top: 20,
              left: 10,
            ),
            child: InkWell(
              onTap: () {
                importContact();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/import_contact.png",
                      width: 20,
                      height: 20,
                      color: context.primaryColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      S.current.import_from_contact,
                      style:
                          context.getTitleMediumTextStyle(context.primaryColor),
                    )
                  ],
                ),
              ),
            ),
          ),
          // === import client button

          Form(
            key: formKey,
            child: Column(
              children: [
                // === client name
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return S.current.client_name_empty;
                      }
                      return null;
                    },
                    labelText: S.current.client_name,
                  ),
                ),
                // === client name

                // === client email
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return S.current.client_email_empty;
                      } else if (!EmailValidator.validate(string.toString())) {
                        return S.current.enter_valid_email;
                      }
                      return null;
                    },
                    labelText: S.current.email,
                  ),
                ),
                // === client email

                // === client phone
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    maxLength: 15,
                    labelText: S.current.contact_number,
                  ),
                ),
                // === client phone

                // === client display name
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: displayNameController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    labelText: S.current.contact_display_name,
                  ),
                ),
                // === client name

                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Divider(),
                ),

                // === add billing address
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: provider.states.isAddBillingAddressActive,
                        activeColor: context.primaryColor,
                        onChanged: (val) {
                          provider.changeStatusBillingAddress(val);
                          if (!val) {
                            setState(() {
                              cityController.clear();
                              stateController.clear();
                              pinCodeController.clear();
                              billingPhoneNumberController.clear();
                              billingAddressController.clear();
                            });
                          }
                        },
                        contentPadding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        title: Text(
                          S.current.add_billing_address,
                          style: context
                              .getTitleMediumTextStyle(context.onSurfaceColor),
                        ),
                      ),
                      Builder(
                        builder: (ctx) {
                          if (provider.states.isAddBillingAddressActive) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // === client street address
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: billingAddressController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: S.current.street_address,
                                  ),
                                ),
                                // === client street address

                                // === client city
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: cityController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: S.current.city,
                                  ),
                                ),
                                // === client city

                                // === client state
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: stateController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: S.current.state,
                                  ),
                                ),
                                // === client state

                                // === client pin code
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: pinCodeController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    maxLength: 6,
                                    validator: (str) {
                                      RegExp regex = RegExp(r'^[1-9][0-9]{5}$');
                                      if (provider
                                          .states.isAddBillingAddressActive) {
                                        if (!regex.hasMatch(str.toString())) {
                                          return 'Pincode not valid';
                                        }
                                      }
                                      return null;
                                    },
                                    labelText: S.current.pin_code,
                                  ),
                                ),
                                // === client pin code

                                // === client billing contact number
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: billingPhoneNumberController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    maxLength: 15,
                                    labelText: S.current.contact_number,
                                  ),
                                ),
                                // === client billing contact number
                              ],
                            );
                          }
                          return Opacity(opacity: 0);
                        },
                      )
                    ],
                  ),
                ),
                // === add billing address
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

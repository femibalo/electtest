import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:provider/provider.dart';

import '../../api/client_api.dart';
import '../../model/client_invoice_model.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';
import 'components/email_validator.dart';


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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddClientScreen(onSavedNewClient: onSaved, clientID: clientId, isEditMode: isEditMode)));
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
    ).then((value) {
      showSnackBar(
        context: context,
        text: 'edit client success',
        snackBarType: SnackBarType.success,
      );
      return;
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
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? 'edit client'
            :'add new client'),
        actions: [_buildSaveButton(provider.states)],
      ),
      body: _getWidgetBasedOnState(provider.states),
    );
  }

  Widget _buildSaveButton(ClientInvoiceState state) {
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

  Widget _getWidgetBasedOnState(ClientInvoiceState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state.isNetworkError) {
      return NetworkErrorWidget(onRefresh: () {

      });
    }

    if (state.isError) {
      return GenericErrorWidget(onRefresh: () {

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
        shrinkWrap: true,
        children: [
          // === import client button
          Container(
            margin: const EdgeInsets.only(
              top: 20,
              left: 10,
            ),
            child: InkWell(
              onTap: () {
                importContact();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(
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
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'import from contact',
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
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return 'client name empty';
                      }
                      return null;
                    },
                    labelText: 'client name',
                  ),
                ),
                // === client name

                // === client email
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    validator: (string) {
                      if (string.toString().isEmpty) {
                        return 'client email empty';
                      } else if (!EmailValidator.validate(string.toString())) {
                        return 'enter valid email';
                      }
                      return null;
                    },
                    labelText: 'email',
                  ),
                ),
                // === client email

                // === client phone
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    maxLength: 15,
                    labelText: 'contact number',
                  ),
                ),
                // === client phone

                // === client display name
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: MTextFormField(
                    controller: displayNameController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    labelText: 'contact display name',
                  ),
                ),
                // === client name

                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: const Divider(),
                ),

                // === add billing address
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: provider.states.isAddBillingAddressActive,
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
                        contentPadding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        title: const Text(
                          'add billing address',
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
                                  margin: const EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: billingAddressController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: 'street address',
                                  ),
                                ),
                                // === client street address

                                // === client city
                                Container(
                                  margin: const EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: cityController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: 'city',
                                  ),
                                ),
                                // === client city

                                // === client state
                                Container(
                                  margin: const EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: stateController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    labelText: 'state',
                                  ),
                                ),
                                // === client state

                                // === client pin code
                                Container(
                                  margin: const EdgeInsets.only(top: 25),
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
                                          return 'Pin code not valid';
                                        }
                                      }
                                      return null;
                                    },
                                    labelText: 'pin code',
                                  ),
                                ),
                                // === client pin code

                                // === client billing contact number
                                Container(
                                  margin: const EdgeInsets.only(top: 25),
                                  child: MTextFormField(
                                    controller: billingPhoneNumberController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLines: 1,
                                    maxLength: 15,
                                    labelText: 'contact number',
                                  ),
                                ),
                                // === client billing contact number
                              ],
                            );
                          }
                          return const Opacity(opacity: 0);
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

      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

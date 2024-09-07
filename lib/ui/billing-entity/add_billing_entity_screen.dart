import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/billing_entity_api.dart';
import '../../model/billing_entity_model.dart';
import '../client/components/email_validator.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/image_editor.dart';
import '../components/snack_bar.dart';

class AddBillingEntityScreen extends StatefulWidget {
  final BillingEntityProfiles billingEntity;
  final bool isEditMode;
  final Function(BillingEntityProfiles) onSavedNewEntity;

  const AddBillingEntityScreen({
    super.key,
    required this.billingEntity,
    this.isEditMode = false,
    required this.onSavedNewEntity,
  });

  static const String id = "addBillingEntity";

  static void launchScreen(
      BuildContext context,
      BillingEntityProfiles billingEntity,
      bool isEditMode,
      Function(BillingEntityProfiles) onSaved) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddBillingEntityScreen(
            onSavedNewEntity: onSaved,
            billingEntity: billingEntity,
            isEditMode: isEditMode)));
  }

  @override
  State<AddBillingEntityScreen> createState() => _AddBillingEntityScreenState();
}

class _AddBillingEntityScreenState extends State<AddBillingEntityScreen> {
  late BillingEntityProvider provider;
  final entityNameController = TextEditingController();
  final entityEmailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  validation() {
    if (formKey.currentState!.validate()) {
      if (provider.state.isLogoEmpty) {
        showSnackBar(
          context: context,
          text: 'assessor_logo_empty'.tr(),
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
            name: entityNameController.text.toString(),
            email: entityEmailController.text.toString())
        .then((value) {
      Navigator.pop(context);
    });
  }

  updateData({required BillingEntityProfiles profile}) {
    provider.updateEntity(profile).then((value) {
      Navigator.pop(context);
    });
  }

  reset() {
    provider.removeSelectedLogo();
    entityNameController.clear();
    entityEmailController.clear();
  }

  loadForm() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    if (widget.isEditMode) {}
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      entityEmailController.text = widget.billingEntity.email;
      entityNameController.text = widget.billingEntity.name;
    }
    provider = Provider.of<BillingEntityProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadForm();
    });
  }

  @override
  void dispose() {
    super.dispose();
    reset();
    disposingResources();
  }

  disposingResources() {
    entityNameController.dispose();
    entityEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BillingEntityProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: _buildSaveButton(provider.state),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(
            widget.isEditMode ? 'edit_assessor'.tr() : 'add_new_assessor'.tr()),
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

  Widget _buildSaveButton(BillingEntityState state) {
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
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          if (widget.isEditMode) {
            final billingProfile = widget.billingEntity.copyWith(
                name: entityNameController.text,
                email: entityEmailController.text,
                logoURL: state.selectedLogo);
            updateData(profile: billingProfile);
          } else {
            validation();
          }
        },
        child: Text('save'.tr(), style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }

  Widget _getWidgetBasedOnState(BillingEntityState state) {
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

  Widget _successContent(BillingEntityState state) {
    List<Widget> children = [];
    children.add(
      Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          shrinkWrap: true,
          children: [
            // === select logo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text('assessor_information'.tr(),
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    left: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            height: MediaQuery.of(context).size.width * 0.18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 0.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    selectImageUpload();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 20,
                                    child: Builder(builder: (ctx) {
                                      if (provider.state.isLogoEmpty) {
                                        return Image.asset(
                                          "assets/images/import_contact.png",
                                          width: 25.0,
                                          height: 25.0,
                                        );
                                      }
                                      return Image.file(
                                        File(provider.state.selectedLogo),
                                        width: 35,
                                        height: 35,
                                      );
                                    }),
                                  ),
                                ),
                                Builder(
                                  builder: (ctx) {
                                    if (!provider.state.isLogoEmpty) {
                                      return GestureDetector(
                                        onTap: () {
                                          provider.removeSelectedLogo();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                            right: 2,
                                          ),
                                          alignment: Alignment.topRight,
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Opacity(opacity: 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 15),
                        child: TextButton(
                          onPressed: () {
                            selectImageUpload();
                          },
                          child: Text('upload_logo'.tr(),
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // === select logo

            // === entity name
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: MTextFormField(
                controller: entityNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                validator: (str) {
                  if (str.toString().isEmpty) {
                    return 'assessor_name_empty'.tr();
                  }
                  return null;
                },
                labelText: 'assessor_name',
              ),
            ),
            // === entity name

            // === entity email
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: MTextFormField(
                controller: entityEmailController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                validator: (str) {
                  if (str.toString().isEmpty) {
                    return 'assessor_email_empty'.tr();
                  } else if (!EmailValidator.validate(str.toString())) {
                    return 'enter_valid_email'.tr();
                  }
                  return null;
                },
                labelText: 'assessor_email'.tr(),
              ),
            ),
            // === entity email
          ],
        ),
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

  selectImageUpload() {
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () async {
                await choosingImageV2(
                  context: context,
                  isFromCamera: true,
                  isSquare: true,
                ).then((result) {
                  if (result is File) {
                    showSnackBar(
                        context: context,
                        text: 'uploading'.tr(),
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: 'success_upload'.tr(),
                          snackBarType: SnackBarType.success);
                    });
                  }
                });
              },
              leading: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.camera_alt_rounded,
                ),
              ),
              title: Text(
                'camera'.tr(),
              ),
            ),
            ListTile(
              onTap: () async {
                await choosingImageV2(
                  context: context,
                  isFromCamera: false,
                  isSquare: true,
                ).then((result) {
                  if (result is File) {
                    showSnackBar(
                        context: context,
                        text: 'uploading'.tr(),
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: 'success_upload'.tr(),
                          snackBarType: SnackBarType.success);
                    });
                  }
                });
              },
              leading: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.image,
                ),
              ),
              title: Text(
                'gallery'.tr(),
              ),
            ),
          ],
        );
      },
    );
  }
}

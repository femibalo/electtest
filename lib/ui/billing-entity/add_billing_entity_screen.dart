// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mezink_app/commands/email_validator.dart';
import 'package:mezink_app/commands/image_editor.dart';
import 'package:mezink_app/components/error_screens.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/screens/invoices/api/billing_entity_api.dart';
import 'package:mezink_app/screens/invoices/model/billing_entity_model.dart';
import 'package:mezink_app/styles/color.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:mezink_app/styles/progress_indicator.dart';

import '../../../../routes/app_routing.gr.dart';

class AddBillingEntityScreen extends StatefulWidget {
  final int billingEntityId;
  final bool isEditMode;
  final Function(BillingEntityProfiles) onSavedNewEntity;
  const AddBillingEntityScreen({
    Key? key,
    this.billingEntityId = 0,
    this.isEditMode = false,
    required this.onSavedNewEntity,
  }) : super(key: key);

  static const String id = "addBillingEntity";
  static void launchScreen(BuildContext context, int billingEntityId,
      bool isEditMode, Function(BillingEntityProfiles) onSaved)  {
     context.router.push<BillingEntityProfiles>(
        AddBillingEntityScreenRoute(
            onSavedNewEntity: onSaved,
            billingEntityId: billingEntityId,
            isEditMode: isEditMode));
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
          text: S.current.billing_entity_logo_empty,
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
      id: widget.billingEntityId,
      name: entityNameController.text.toString(),
      email: entityEmailController.text.toString(),
    )
        .then((value) {
      if (value.success) {
        widget.onSavedNewEntity(BillingEntityProfiles(
          id: value.data, // entity id from api return
          name: entityNameController.text.toString(),
          email: entityEmailController.text.toString(),
          logoURL: provider.state.selectedLogo,
        ));
        reset();
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
    provider.removeSelectedLogo();
    entityNameController.clear();
    entityEmailController.clear();
  }

  loadForm() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    if (widget.isEditMode) {
      provider.getDetailBillingEntity(widget.billingEntityId).then((value) {
        if (value) {
          // return true
          entityEmailController.text =
              provider.state.selectedDetailEntity.email;
          entityNameController.text = provider.state.selectedDetailEntity.name;
          provider.state.selectedLogo =
              provider.state.selectedDetailEntity.logoURL;
          if (provider.state.selectedDetailEntity.logoURL != "") {
            provider.state.isLogoEmpty = false;
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
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

  disposingResources(){
    entityNameController.dispose();
    entityEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BillingEntityProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: widget.isEditMode
            ? S.current.edit_entity
            : S.current.add_new_entity,
        actions: [_buildSaveButton(provider.state)],
      ),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _buildSaveButton(BillingEntityState state) {
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

  Widget _getWidgetBasedOnState(BillingEntityState state) {
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
          physics: customScrollPhysics(),
          shrinkWrap: true,
          children: [
            // === select logo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    S.current.entity_information,
                    style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
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
                                color: MColors.lightGrey,
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
                                    child: Builder(builder: (ctx) {
                                      if (provider.state.isLogoEmpty) {
                                        return SvgPicture.asset(
                                          "assets/images/empty_thumbnail.svg",
                                          width: 22,
                                          height: 22,
                                          placeholderBuilder:
                                              (BuildContext context) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.all(30.0),
                                              child:
                                                  const AdaptiveProgressIndicator(),
                                            );
                                          },
                                        );
                                      }
                                      return Image.network(
                                        provider.state.selectedLogo,
                                        width: 35,
                                        height: 35,
                                      );
                                    }),
                                    radius: 20,
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
                                          margin: EdgeInsets.only(
                                            top: 2,
                                            right: 2,
                                          ),
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.close,
                                            color: MColors.red,
                                            size: 16,
                                          ),
                                        ),
                                      );
                                    }
                                    return Opacity(opacity: 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 15),
                        child: MTextButton(
                          onPressed: (){
                            selectImageUpload();
                          },
                          child: Text(S.current.upload_logo),
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
              margin: EdgeInsets.only(top: 30),
              child: MTextFormField(
                controller: entityNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                validator: (str) {
                  if (str.toString().isEmpty) {
                    return S.current.billing_entity_name_empty;
                  }
                  return null;
                },
                labelText: S.current.entity_name,
              ),
            ),
            // === entity name

            // === entity email
            Container(
              margin: EdgeInsets.only(top: 20),
              child: MTextFormField(
                controller: entityEmailController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                validator: (str) {
                  if (str.toString().isEmpty) {
                    return S.current.billing_entity_email_empty;
                  } else if (!EmailValidator.validate(str.toString())) {
                    return S.current.enter_valid_email;
                  }
                  return null;
                },
                labelText: S.current.entity_email,
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
        physics: customScrollPhysics(alwaysScroll: true),
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
                        text: S.current.uploading,
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: S.current.success_upload,
                          snackBarType: SnackBarType.success);
                    });
                  }
                });
              },
              leading: const CircleAvatar(
                backgroundColor: MColors.transparent,
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: MColors.secondaryGrey,
                ),
              ),
              title: Text(
                S.current.camera,
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
                        text: S.current.uploading,
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: S.current.success_upload,
                          snackBarType: SnackBarType.success);
                    });
                  }
                });
              },
              leading: const CircleAvatar(
                backgroundColor: MColors.transparent,
                child: Icon(
                  Icons.image,
                  color: MColors.secondaryGrey,
                ),
              ),
              title: Text(
                S.current.gallery,
              ),
            ),
          ],
        );
      },
    );
  }
}

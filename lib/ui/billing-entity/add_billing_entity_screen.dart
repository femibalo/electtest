import 'dart:io';
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
  static void launchScreen(BuildContext context, int billingEntityId, bool isEditMode, Function(BillingEntityProfiles) onSaved)  {
     Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddBillingEntityScreen( onSavedNewEntity: onSaved,
         billingEntityId: billingEntityId,
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
          text: 'Billing entity logo empty',
          snackBarType: SnackBarType.error,
        );
      } else {
        saveData();
      }
    }
  }

  saveData() {
    provider.saveData(
      id: widget.billingEntityId,
      name: entityNameController.text.toString(),
      email: entityEmailController.text.toString(),
    ).then((value) {

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
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? 'Edit entity'
            : 'Add new entity'),
        actions: [_buildSaveButton(provider.state)],
      ),
      body: _getWidgetBasedOnState(provider.state),
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
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          validation();
        },
        child: const Text('save'),
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
                  child: const Text(
                    'Entity information',
                  ),
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
                                          "assets/images/empty_thumbnail.png",
                                          width: 22,
                                          height: 22,
                                        );
                                      }
                                      return Image.network(
                                        provider.state.selectedLogo,
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
                          onPressed: (){
                            selectImageUpload();
                          },
                          child: const Text('upload logo'),
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
                    return 'billing entity name empty';
                  }
                  return null;
                },
                labelText: 'entity name',
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
                    return 'billing entity email empty';
                  } else if (!EmailValidator.validate(str.toString())) {
                    return 'enter valid email';
                  }
                  return null;
                },
                labelText: 'entity email',
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
                        text: 'uploading',
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: 'Success upload',
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
              title: const Text(
                'camera',
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
                        text: 'uploading',
                        snackBarType: SnackBarType.general);
                    provider
                        .changeSelectedLogoAfterUploadLogo(result)
                        .whenComplete(() {
                      showSnackBar(
                          context: context,
                          text: 'success upload',
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
              title: const Text(
                'gallery',
              ),
            ),
          ],
        );
      },
    );
  }
}

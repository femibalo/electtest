// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/filled_button.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/routes/app_routing.gr.dart';
import 'package:mezink_app/screens/invoices/api/billing_entity_api.dart';
import 'package:mezink_app/screens/invoices/api/invoice_api.dart';
import 'package:mezink_app/screens/invoices/model/billing_entity_model.dart';
import 'package:mezink_app/screens/invoices/ui/billing-entity/add_billing_entity_screen.dart';
import 'package:mezink_app/screens/invoices/ui/billing-entity/components/item_list.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:mezink_app/styles/progress_indicator.dart';

import '../../../../components/error_screens.dart';

class BillingEntityScreen extends StatefulWidget {
  final int? selectedEntityID;
  final Function(BillingEntityProfiles) onSavedSelectedEntity;
  const BillingEntityScreen(
      {Key? key, this.selectedEntityID, required this.onSavedSelectedEntity})
      : super(key: key);

  static const String id = "billingEntity";

  static void launchScreen(BuildContext context, int selectedEntityID,
      Function(BillingEntityProfiles) onSaved)  {
     context.router.push<BillingEntityProfiles>(BillingEntityScreenRoute(
        selectedEntityID: selectedEntityID, onSavedSelectedEntity: onSaved));
  }

  @override
  State<BillingEntityScreen> createState() => _BillingEntityScreenState();
}

class _BillingEntityScreenState extends State<BillingEntityScreen> {
  late BillingEntityProvider provider;
  final searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? _debounce;

  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchEntity(query: searchController.text.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<BillingEntityProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
      provider.getData().then((value) {
        if (widget.selectedEntityID != 0) {
          provider.state.selectedEntity = provider
              .state.billingEntityModel.billingEntityData.profiles
              .singleWhere((e) {
            return e.id == widget.selectedEntityID;
          });
        } else {
          provider.state.selectedEntity = provider
              .state.billingEntityModel.billingEntityData.profiles.first;
        }
      });
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        provider.getMore().then((value) {
          if (widget.selectedEntityID != 0) {
            provider.state.selectedEntity = provider
                .state.billingEntityModel.billingEntityData.profiles
                .singleWhere((e) {
              return e.id == widget.selectedEntityID;
            });
          }
        });
      }
    });
  }

  searchEntity({required String query}) {
    setState(() {
      provider.state.searchQuery = query;
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
    });
    provider.getData().then((value) {
      if (widget.selectedEntityID != 0) {
        provider.state.selectedEntity = provider
            .state.billingEntityModel.billingEntityData.profiles
            .singleWhere((e) {
          return e.id == widget.selectedEntityID;
        });
      }
    });
  }

  void refreshData() {
    setState(() {
      provider.state.searchQuery = "";
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = false;
      provider.state.isError = false;
      provider.state.isNetworkError = false;
      searchController.clear();
    });
    provider.getData().then((value) {
      if (widget.selectedEntityID != 0) {
        provider.state.selectedEntity = provider
            .state.billingEntityModel.billingEntityData.profiles
            .singleWhere((e) {
          return e.id == widget.selectedEntityID;
        });
      }
    });
  }

  // after open add new entity screen,
  // when it finish it will close this below screen
  // - add billing entity screen
  // - billing entity screen
  // and automatically set current billing entity in add invoice screen
  addNewEntity() async {
    AddBillingEntityScreen.launchScreen(context, 0, false, (entity) {
      widget.onSavedSelectedEntity(entity);
      context.router.popUntilRouteWithName(AddInvoiceScreenRoute.name);
    });
  }

  // send selected entity to add invoice screen
  saveSelectedEntity() {
    widget.onSavedSelectedEntity(provider.state.selectedEntity);
    context.router.pop();
  }

  reset() {
    setState(() {
      provider.state.searchQuery = "";
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BillingEntityProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: S.current.billing_entity,
        actions: [_buildSaveButton(provider.state)],
      ),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _getWidgetBasedOnState(BillingEntityState state) {
    if (state.isNetworkError) {
      return NetworkErrorWidget(onRefresh: () {
        refreshData();
      });
    }

    if (state.isError) {
      return GenericErrorWidget(onRefresh: () {
        refreshData();
      });
    }

    return _successContent(state);
  }

  Widget _successContent(BillingEntityState state) {
    List<Widget> children = [];
    children.add(
      const SizedBox(
        height: 25,
      ),
    );

    children.add(
      // === search field
      Builder(builder: (context) {
        if (provider
                .state.billingEntityModel.billingEntityData.profiles.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return Container(
          child: MTextFormField(
            controller: searchController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 1,
            onChanged: onSearchChanged,
            labelText: S.current.search_billing_entity,
            prefixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/search.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      // === search field
    );

    children.add(SizedBox(
      height: 20,
    ));

    children.add(
      // create new entity button
      Builder(builder: (context) {
        if (provider
                .state.billingEntityModel.billingEntityData.profiles.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }

        return UnconstrainedBox(
          child: MFilledButton(
            onPressed: () {
              addNewEntity();
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: context.onPrimaryColor,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  S.current.add_new_entity,
                ),
              ],
            ),
          ),
        );
      }),
      // create new entity button
    );
    

    children.add(SizedBox(height: 20));
    children.add(
      Builder(builder: (context) {
        if (state.loading) {
          return Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Center(
              child: AdaptiveProgressIndicator(),
            ),
          );
        } else if (provider
                .state.billingEntityModel.billingEntityData.profiles.isEmpty &&
            !provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Column(
              children: [
                EmptyWidget(
                  onRefresh: () {
                    addNewEntity();
                  },
                  text: S.current.no_billing_entity_added,
                  refreshButtonText: S.current.add_new_entity,
                ),
              ],
            ),
          );
        } else if (provider
                .state.billingEntityModel.billingEntityData.profiles.isEmpty &&
            provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
            ),
            child: EmptyWidget(
              onRefresh: () {
                refreshData();
              },
              text: S.current.no_results_found,
            ),
          );
        }
        return ListView.builder(
          itemCount: provider
              .state.billingEntityModel.billingEntityData.profiles.length,
          shrinkWrap: true,
          physics: customScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            var profile = provider
                .state.billingEntityModel.billingEntityData.profiles[index];
            return ItemListBillingEntity(
              model: profile,
              groupValue: provider.state.selectedEntity,
              onTap: () {
                provider.changeSelectedEntity(profile);
              },
              onEdit: () {
                AddBillingEntityScreen.launchScreen(context, profile.id, true,
                    (entity) {
                  context.router.pop();
                  widget.onSavedSelectedEntity(entity);
                  refreshData();
                });
              },
              onDelete: () {
                // handle selected entity to delete
                if (provider.state.selectedEntity.id != profile.id) {
                  Future.delayed(
                    const Duration(seconds: 0),
                    () {
                      showCustomAlertDialog(
                        title: "${S.current.delete} ${profile.name}",
                        subTitle: S
                            .current.are_you_sure_want_to_delete_billing_entity,
                        context: context,
                        leftButtonText: S.current.yes,
                        rightButtonText: S.current.cancel,
                        onLeftButtonClicked: () {
                          Navigator.of(context).pop();
                          showSnackBar(
                            context: context,
                            text: S.current.please_wait,
                          );
                          provider
                              .deleteEntity(entityId: profile.id)
                              .then((value) {
                            if (value) {
                              showSnackBar(
                                context: context,
                                text: S.current.delete_entity_success,
                                snackBarType: SnackBarType.success,
                              );
                              // when delete same profile as in selected profile in add invoice
                              // also delete the selected profile in add invoice
                              if(Provider.of<InvoicesProvider>(context, listen: false).state.selectedBillingEntity.id == profile.id) {
                                if(provider.state.billingEntityModel.billingEntityData.profiles.isNotEmpty) {
                                  var profile = provider.state.billingEntityModel.billingEntityData.profiles.single;
                                  provider.changeSelectedEntity(profile);
                                  Provider.of<InvoicesProvider>(context, listen: false).changeSelectedEntity(profile);
                                }
                              }
                            } else {
                              showSnackBar(
                                context: context,
                                text: S.current.delete_entity_error,
                                snackBarType: SnackBarType.success,
                              );
                            }
                          });
                        },
                        onRightButtonClicked: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                } else {
                  showSnackBar(
                    context: context,
                    text: S.current.delete_selected_entity,
                    snackBarType: SnackBarType.error,
                  );
                }
              },
            );
          },
        );
      }),
    );
    return RefreshIndicator(
      onRefresh: () async {
        refreshData();
      },
      child: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        children: children,
        controller: scrollController,
        physics: customScrollPhysics(alwaysScroll: true),
      ),
    );
  }

  Widget _buildSaveButton(BillingEntityState state) {
    if (state.isNetworkError) {
      return SizedBox();
    }

    if (state.isError) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: MTextButton(
        isAppBarAction: true,
        onPressed: () {
          saveSelectedEntity();
        },
        child: Text(S.current.save),
      ),
    );
  }
}

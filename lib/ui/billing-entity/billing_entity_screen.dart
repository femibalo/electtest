import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice_management/ui/add_invoice_screen.dart';
import 'package:provider/provider.dart';
import '../../api/billing_entity_api.dart';
import '../../api/invoice_api.dart';
import '../../model/billing_entity_model.dart';
import '../components/dialog.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';
import 'add_billing_entity_screen.dart';
import 'components/item_list.dart';

class BillingEntityScreen extends StatefulWidget {
  final int? selectedEntityID;
  final Function(BillingEntityProfiles) onSavedSelectedEntity;

  const BillingEntityScreen(
      {super.key, this.selectedEntityID, required this.onSavedSelectedEntity});

  static const String id = "billingEntity";

  static void launchScreen(BuildContext context, int selectedEntityID,
      Function(BillingEntityProfiles) onSaved) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BillingEntityScreen(
              onSavedSelectedEntity: onSaved,
              selectedEntityID: selectedEntityID,
            )));
  }

  @override
  State<BillingEntityScreen> createState() => _BillingEntityScreenState();
}

class _BillingEntityScreenState extends State<BillingEntityScreen> {
  late BillingEntityProvider provider;
  final searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? _debounce;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
      await provider.getEntityData();
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {}
    });
  }

  searchEntity({required String query}) {
    setState(() {
      provider.state.searchQuery = query;
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
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
  }

  // after open add new entity screen,
  // when it finish it will close this below screen
  // - add billing entity screen
  // - billing entity screen
  // and automatically set current billing entity in add invoice screen
  addNewEntity() async {
    AddBillingEntityScreen.launchScreen(
        context, const BillingEntityProfiles(), false, (entity) {
      widget.onSavedSelectedEntity(entity);
      AddInvoiceScreen.launchScreen(context);
    });
  }

  // send selected entity to add invoice screen
  saveSelectedEntity() {
    widget.onSavedSelectedEntity(provider.state.selectedEntity);
    Navigator.pop(context);
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
      backgroundColor: Colors.grey.shade100,
      key: scaffoldKey,
      floatingActionButton: _buildSaveButton(provider.state),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text('assessor'.tr()),
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
        if (provider.state.billingEntities.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return SizedBox(
          height: 50,
          child: MTextFormField(
            controller: searchController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 1,
            onChanged: onSearchChanged,
            labelText: 'search_assessor'.tr(),
            prefixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/search.png",
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        );
      }),
      // === search field
    );

    children.add(const SizedBox(
      height: 20.0,
    ));

    children.add(
      // create new entity button
      Builder(builder: (context) {
        if (provider.state.billingEntities.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }

        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              addNewEntity();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  'add_new_assessor'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        );
      }),
      // create new entity button
    );

    children.add(const SizedBox(height: 20));
    children.add(
      Builder(builder: (context) {
        if (state.loading) {
          return Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (provider.state.billingEntities.isEmpty &&
            !provider.state.isAfterSearch) {
          return Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
            child: Column(
              children: [
                EmptyWidget(
                  onRefresh: () {
                    addNewEntity();
                  },
                  text: 'no_assessor_added',
                  refreshButtonText: 'add_new_assessor'.tr(),
                ),
              ],
            ),
          );
        } else if (provider.state.billingEntities.isEmpty &&
            provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
            ),
            child: EmptyWidget(
              onRefresh: () {
                refreshData();
              },
              text: 'no_results_found'.tr(),
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.state.billingEntities.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            var profile = provider.state.billingEntities[index];
            return ItemListBillingEntity(
              model: profile,
              groupValue: provider.state.selectedEntity,
              onTap: () {
                provider.changeSelectedEntity(profile, index);
              },
              onEdit: () {
                provider.changeSelectedEntity(profile, index);
                AddBillingEntityScreen.launchScreen(
                    scaffoldKey.currentContext!, profile, true, (entity) {
                  Navigator.pop(context);
                  widget.onSavedSelectedEntity(entity);
                  refreshData();
                });
              },
              onDelete: () {
                Future.delayed(
                  const Duration(seconds: 0),
                  () {
                    showCustomAlertDialog(
                      title: "delete ${profile.name}".tr(),
                      subTitle:
                          "are_you_sure_want_to_delete_billing_assessor".tr(),
                      context: context,
                      leftButtonText: 'yes'.tr(),
                      rightButtonText: 'cancel'.tr(),
                      onLeftButtonClicked: () {
                        Navigator.of(context).pop();
                        showSnackBar(
                          context: context,
                          text: 'please_wait'.tr(),
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          provider
                              .deleteEntity(entityId: profile.id)
                              .then((value) {
                            showSnackBar(
                              context: context,
                              text: 'delete_assessor_success'.tr(),
                              snackBarType: SnackBarType.success,
                            );
                            // when delete same profile as in selected profile in add invoice
                            // also delete the selected profile in add invoice
                            if (Provider.of<InvoicesProvider>(context,
                                        listen: false)
                                    .state
                                    .selectedBillingEntity
                                    .id ==
                                profile.id) {
                              if (provider.state.billingEntities.isNotEmpty) {
                                var profile =
                                    provider.state.billingEntities.single;
                                provider.changeSelectedEntity(profile, index);
                                Provider.of<InvoicesProvider>(context,
                                        listen: false)
                                    .changeSelectedEntity(profile);
                              }
                            }
                          });
                        });
                      },
                      onRightButtonClicked: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
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
        controller: scrollController,
        children: children,
      ),
    );
  }

  Widget _buildSaveButton(BillingEntityState state) {
    if (state.isNetworkError) {
      return const SizedBox();
    }

    if (state.isError) {
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
          saveSelectedEntity();
        },
        child: Text('save'.tr(), style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

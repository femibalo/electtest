import 'dart:async';
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
      {Key? key, this.selectedEntityID, required this.onSavedSelectedEntity})
      : super(key: key);

  static const String id = "billingEntity";

  static void launchScreen(BuildContext context, int selectedEntityID, Function(BillingEntityProfiles) onSaved)  {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BillingEntityScreen(onSavedSelectedEntity: onSaved,selectedEntityID: selectedEntityID,)));
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

      });
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {

      }
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
    AddBillingEntityScreen.launchScreen(context, 0, false, (entity) {
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
      appBar: AppBar(
        title: const Text('Billing entity'),
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
        if (provider.state.billingEntities.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return MTextFormField(
          controller: searchController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
          onChanged: onSearchChanged,
          labelText: 'Search billing entity',
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
            child: const Row(
              children: [
                Icon(
                  Icons.add,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Add new entity',
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (provider.state.billingEntities.isEmpty && !provider.state.isAfterSearch) {
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
                  text: 'No billing entity added',
                  refreshButtonText: 'Add new entity',
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
              text: 'No results found',
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.state.billingEntities.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            var profile = provider.state.billingEntities[index];
            return ItemListBillingEntity(
              model: profile,
              groupValue: provider.state.selectedEntity,
              onTap: () {
                provider.changeSelectedEntity(profile);
              },
              onEdit: () {
                AddBillingEntityScreen.launchScreen(context, profile.id, true, (entity) {
                  Navigator.pop(context);
                  widget.onSavedSelectedEntity(entity);
                  refreshData();
                });
              },
              onDelete: () {
                // handle selected entity to delete
                if (provider.state.selectedEntity.id != profile.id) {
                  Future.delayed(
                    const Duration(seconds: 0), () {
                      showCustomAlertDialog(
                        title: "delete ${profile.name}",
                        subTitle: "Are you sure want to delete billing entity",
                        context: context,
                        leftButtonText: 'yes',
                        rightButtonText: 'Cancel',
                        onLeftButtonClicked: () {
                          Navigator.of(context).pop();
                          showSnackBar(
                            context: context,
                            text: 'please wait',
                          );
                          provider
                              .deleteEntity(entityId: profile.id)
                              .then((value) {
                            if (value) {
                              showSnackBar(
                                context: context,
                                text: 'Delete entity success',
                                snackBarType: SnackBarType.success,
                              );
                              // when delete same profile as in selected profile in add invoice
                              // also delete the selected profile in add invoice
                              if(Provider.of<InvoicesProvider>(context, listen: false).state.selectedBillingEntity.id == profile.id) {
                                if(provider.state.billingEntities.isNotEmpty) {
                                  var profile = provider.state.billingEntities.single;
                                  provider.changeSelectedEntity(profile);
                                  Provider.of<InvoicesProvider>(context, listen: false).changeSelectedEntity(profile);
                                }
                              }
                            } else {
                              showSnackBar(
                                context: context,
                                text: 'Delete entity error',
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
                    text: 'Delete selected entity',
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
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          saveSelectedEntity();
        },
        child: const Text('save'),
      ),
    );
  }
}

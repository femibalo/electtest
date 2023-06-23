// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/filled_button.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/routes/app_routing.gr.dart';
import 'package:mezink_app/screens/invoices/api/client_api.dart';
import 'package:mezink_app/screens/invoices/api/invoice_api.dart';
import 'package:mezink_app/screens/invoices/model/client_invoice_model.dart';
import 'package:mezink_app/screens/invoices/ui/client/components/item_list.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';

import '../../../../components/error_screens.dart';
import '../../../../generated/l10n.dart';
import 'package:mezink_app/styles/progress_indicator.dart';

import 'add_client_screen.dart';

class ClientInvoiceScreen extends StatefulWidget {
  final int? selectedClientID;
  final void Function(UserClientInvoice) onSaveSelectedClient;
  const ClientInvoiceScreen({Key? key, this.selectedClientID, required this.onSaveSelectedClient})
      : super(key: key);

  static const String id = "clientInvoice";
  static void launchScreen(BuildContext context, int selectedClientID,
      Function(UserClientInvoice) onSaved)  {
     context.router.push<UserClientInvoice>(ClientInvoiceScreenRoute(
      selectedClientID: selectedClientID, onSaveSelectedClient: onSaved,
    ));
  }

  @override
  State<ClientInvoiceScreen> createState() => _ClientInvoiceScreenState();
}

class _ClientInvoiceScreenState extends State<ClientInvoiceScreen> {
  late ClientInvoiceProvider provider;
  final searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? _debounce;

  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchClient(query: searchController.text.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ClientInvoiceProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
      provider.getData().then((value) {
        if (widget.selectedClientID != 0) {
          provider.states.selectedClient = provider
              .states.clientInvoiceModel.data.userClients
              .singleWhere((e) {
            return e.id == widget.selectedClientID;
          });
        }
      });
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        provider.getMore().then((value) {
          if (widget.selectedClientID != 0) {
            provider.states.selectedClient = provider
                .states.clientInvoiceModel.data.userClients
                .singleWhere((e) {
              return e.id == widget.selectedClientID;
            });
          }
        });
      }
    });
  }

  searchClient({required String query}) {
    setState(() {
      provider.states.searchQuery = query;
      provider.states.currentPage = 1;
      provider.states.isAfterSearch = true;
    });
    provider.getData().then((value) {
      if (widget.selectedClientID != 0) {
        provider.states.selectedClient = provider
            .states.clientInvoiceModel.data.userClients
            .singleWhere((e) {
          return e.id == widget.selectedClientID;
        });
      }
    });
  }

  void refreshData() {
    setState(() {
      provider.states.currentPage = 1;
      provider.states.searchQuery = "";
      provider.states.isAfterSearch = false;
      provider.states.isError = false;
      provider.states.isNetworkError = false;
      searchController.clear();
    });
    provider.getData().then((value) {
      if (widget.selectedClientID != 0) {
        provider.states.selectedClient = provider
            .states.clientInvoiceModel.data.userClients
            .singleWhere((e) {
          return e.id == widget.selectedClientID;
        });
      }
    });
  }

  // after open add new client screen,
  // when it finish it will close this below screen
  // - add client screen
  // - client screen
  // and automatically set current client in add invoice screen
  addNewClient() async {
    AddClientScreen.launchScreen(context, 0, false, (client) {
      widget.onSaveSelectedClient(client);
      context.router.popUntilRouteWithName(AddInvoiceScreenRoute.name);
    });
  }

  // send selected client to add invoice screen
  saveSelectedClient() {
    if (provider.states.selectedClient.id != 0) {
      // id 0 means client not selected
      widget.onSaveSelectedClient(provider.states.selectedClient);
      context.router.pop();
      setState(() {
        provider.states.selectedClient = UserClientInvoice();
      });
    } else {
      showSnackBar(
        context: context,
        text: S.current.client_not_selected,
        snackBarType: SnackBarType.error,
      );
    }
  }

  reset() {
    setState(() {
      provider.states.searchQuery = "";
      provider.states.currentPage = 1;
      provider.states.selectedClient = UserClientInvoice();
      provider.states.isAfterSearch = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientInvoiceProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: S.current.select_client,
        actions: [_buildSaveButton(provider.states)]
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

    if (state.clientInvoiceModel.data.userClients.isEmpty) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: MTextButton(
        isAppBarAction: true,
        onPressed: () {
          saveSelectedClient();
        },
        child: Text(S.current.save),
      ),
    );
  }

  Widget _getWidgetBasedOnState(ClientInvoiceState state) {
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

  Widget _successContent(ClientInvoiceState state) {
    List<Widget> children = [];
    children.add(
      const SizedBox(
        height: 15,
      ),
    );

    children.add(
      // === search field
      Builder(
        builder: (ctx) {
          if (provider.states.clientInvoiceModel.data.userClients.isEmpty &&
              provider.states.isAfterSearch == false) {
            return Container();
          }
          return Container(
            child: MTextFormField(
              controller: searchController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
              onChanged: onSearchChanged,
              labelText: S.current.search_client,
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
        },
      ),
      // === search field
    );

    children.add(SizedBox(
      height: 20,
    ));

    children.add(
      // create new client button
      Builder(builder: (ctx) {
        if (provider.states.clientInvoiceModel.data.userClients.isEmpty &&
            provider.states.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: MFilledButton(
            onPressed: () {
              addNewClient();
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
                  S.current.add_new_client,
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
      Builder(builder: (ctx) {
        if (state.loading) {
          return Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Center(
              child: AdaptiveProgressIndicator(),
            ),
          );
        } else if (provider
                .states.clientInvoiceModel.data.userClients.isEmpty &&
            !provider.states.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Column(
              children: [
                EmptyWidget(
                  onRefresh: () {
                    addNewClient();
                  },
                  text: S.current.no_client_added,
                  refreshButtonText: S.current.add_new_client,
                ),
              ],
            ),
          );
        } else if (provider
                .states.clientInvoiceModel.data.userClients.isEmpty &&
            provider.states.isAfterSearch) {
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
        } else {
          return ListView.builder(
            itemCount:
                provider.states.clientInvoiceModel.data.userClients.length,
            shrinkWrap: true,
            physics: customScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (ctx, index) {
              var userClient =
                  provider.states.clientInvoiceModel.data.userClients[index];
              return ItemListClientInvoice(
                model: userClient,
                groupValue: provider.states.selectedClient,
                onTap: () {
                  provider.changeSelectedClient(userClient);
                },
                onEdit: () {
                  AddClientScreen.launchScreen(context, userClient.id, true, (client) {
                    context.router.pop();
                    widget.onSaveSelectedClient(client);
                    refreshData();
                  });
                },
                onDelete: () {
                  // handle selected entity to delete
                  if (provider.states.selectedClient.id != userClient.id) {
                    Future.delayed(
                      const Duration(seconds: 0),
                      () {
                        showCustomAlertDialog(
                          title: "${S.current.delete} ${userClient.name}",
                          subTitle:
                              S.current.are_you_sure_want_to_delete_client,
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
                                .deleteClient(clientId: userClient.id)
                                .then((value) {
                              if (value) {
                                showSnackBar(
                                  context: context,
                                  text: S.current.delete_client_success,
                                  snackBarType: SnackBarType.success,
                                );

                                // when delete same client as in selected client in add invoice
                                // also delete the selected client in add invoice
                                if(Provider.of<InvoicesProvider>(context, listen: false).state.selectedClient.id == userClient.id) {
                                  Provider.of<InvoicesProvider>(context, listen: false).changeSelectedClient(UserClientInvoice());
                                  provider.changeSelectedClient(UserClientInvoice());
                                }
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: S.current.delete_client_error,
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
                      text: S.current.delete_selected_client,
                      snackBarType: SnackBarType.error,
                    );
                  }
                },
              );
            },
          );
        }
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
}

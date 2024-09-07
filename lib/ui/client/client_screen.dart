import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/client_api.dart';
import '../../api/invoice_api.dart';
import '../../model/client_invoice_model.dart';
import '../add_invoice_screen.dart';
import '../components/dialog.dart';
import '../components/error_screens.dart';
import '../components/form_text_field.dart';
import '../components/snack_bar.dart';
import 'add_client_screen.dart';
import 'components/item_list.dart';

class ClientInvoiceScreen extends StatefulWidget {
  final int? selectedClientID;
  final void Function(UserClientInvoice) onSaveSelectedClient;
  const ClientInvoiceScreen(
      {super.key, this.selectedClientID, required this.onSaveSelectedClient});

  static const String id = "clientInvoice";
  static void launchScreen(BuildContext context, int selectedClientID,
      Function(UserClientInvoice) onSaved) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ClientInvoiceScreen(
              selectedClientID: selectedClientID,
              onSaveSelectedClient: onSaved,
            )));
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
      provider.getData();
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {}
    });
  }

  searchClient({required String query}) {
    setState(() {
      provider.state.searchQuery = query;
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
    });
    provider.getData().then((value) {
      if (widget.selectedClientID != 0) {
        provider.state.selectedClient =
            provider.state.clientInvoices.singleWhere((e) {
          return e.id == widget.selectedClientID;
        });
      }
    });
  }

  void refreshData() {
    setState(() {
      provider.state.currentPage = 1;
      provider.state.searchQuery = "";
      provider.state.isAfterSearch = false;
      provider.state.isError = false;
      provider.state.isNetworkError = false;
      searchController.clear();
    });
    provider.getData().then((value) {
      if (widget.selectedClientID != 0) {
        provider.state.selectedClient =
            provider.state.clientInvoices.singleWhere((e) {
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
    AddClientScreen.launchScreen(context, const UserClientInvoice(), false,
        (client) {
      widget.onSaveSelectedClient(client);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddInvoiceScreen()));
    });
  }

  // send selected client to add invoice screen
  saveSelectedClient() {
    if (provider.state.selectedClient.id != 0) {
      // id 0 means client not selected
      widget.onSaveSelectedClient(provider.state.selectedClient);
      Navigator.of(context).pop();
      setState(() {
        provider.state.selectedClient = const UserClientInvoice();
      });
    } else {
      showSnackBar(
        context: context,
        text: 'client not selected',
        snackBarType: SnackBarType.error,
      );
    }
  }

  reset() {
    setState(() {
      provider.state.searchQuery = "";
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = false;
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
      backgroundColor: Colors.grey.shade100,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildSaveButton(provider.state),
      appBar: AppBar(
        title: Text('select_client'.tr()),
        // actions: [_buildSaveButton(provider.state)]
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

    if (state.clientInvoices.isEmpty) {
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
          saveSelectedClient();
        },
        child: Text(
          'save'.tr(),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
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
          if (provider.state.clientInvoices.isEmpty &&
              provider.state.isAfterSearch == false) {
            return Container();
          }
          return SizedBox(
            height: 60,
            child: MTextFormField(
              controller: searchController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
              onChanged: onSearchChanged,
              labelText: 'search_client'.tr(),
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
        },
      ),
      // === search field
    );

    children.add(const SizedBox(
      height: 20.0,
    ));

    children.add(
      // create new client button
      Builder(builder: (ctx) {
        if (provider.state.clientInvoices.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              addNewClient();
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
                  'add_new_client'.tr(),
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
      Builder(builder: (ctx) {
        if (state.loading) {
          return Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (provider.state.clientInvoices.isEmpty &&
            !provider.state.isAfterSearch) {
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
                  text: 'no_client_added'.tr(),
                  refreshButtonText: 'add_new_client'.tr(),
                ),
              ],
            ),
          );
        } else if (provider.state.clientInvoices.isEmpty &&
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
        } else {
          return ListView.builder(
            itemCount: provider.state.clientInvoices.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (ctx, index) {
              var userClient = provider.state.clientInvoices[index];
              return ItemListClientInvoice(
                model: userClient,
                groupValue: provider.state.selectedClient,
                onTap: () {
                  provider.changeSelectedClient(userClient);
                },
                onEdit: () {
                  AddClientScreen.launchScreen(context, userClient, true,
                      (client) {
                    Navigator.of(context).pop();
                    widget.onSaveSelectedClient(client);
                    refreshData();
                  });
                },
                onDelete: () {
                  // handle selected entity to delete
                  if (provider.state.selectedClient.id != userClient.id) {
                    Future.delayed(
                      const Duration(seconds: 0),
                      () {
                        showCustomAlertDialog(
                          title: "delete ${userClient.name}".tr(),
                          subTitle: 'are_you_sure_want_to_delete_client?'.tr(),
                          context: context,
                          leftButtonText: 'yes'.tr(),
                          rightButtonText: 'cancel'.tr(),
                          onLeftButtonClicked: () {
                            Navigator.of(context).pop();
                            showSnackBar(
                              context: context,
                              text: 'please_wait'.tr(),
                            );
                            provider
                                .deleteClient(clientId: userClient.id)
                                .then((value) {
                              if (value) {
                                showSnackBar(
                                  context: context,
                                  text: 'delete_client_success'.tr(),
                                  snackBarType: SnackBarType.success,
                                );

                                // when delete same client as in selected client in add invoice
                                // also delete the selected client in add invoice
                                if (Provider.of<InvoicesProvider>(context,
                                            listen: false)
                                        .state
                                        .selectedClient
                                        .id ==
                                    userClient.id) {
                                  Provider.of<InvoicesProvider>(context,
                                          listen: false)
                                      .changeSelectedClient(
                                          const UserClientInvoice());
                                  provider.changeSelectedClient(
                                      const UserClientInvoice());
                                }
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: 'delete_client_error'.tr(),
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
                      text: 'delete_selected_client'.tr(),
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
        controller: scrollController,
        children: children,
      ),
    );
  }
}

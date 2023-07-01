import 'dart:async';
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
  const ClientInvoiceScreen({Key? key, this.selectedClientID, required this.onSaveSelectedClient})
      : super(key: key);

  static const String id = "clientInvoice";
  static void launchScreen(BuildContext context, int selectedClientID, Function(UserClientInvoice) onSaved)  {
     Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientInvoiceScreen(
       selectedClientID: selectedClientID, onSaveSelectedClient: onSaved,
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
      provider.getData().then((value) {
        if (widget.selectedClientID != 0) {
          provider.states.selectedClient = provider
              .states.clientInvoices.singleWhere((e) {
            return e.id == widget.selectedClientID;
          });
        }
      });
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {

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
            .states.clientInvoices
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
            .states.clientInvoices
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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddInvoiceScreen()));
    });
  }

  // send selected client to add invoice screen
  saveSelectedClient() {
    if (provider.states.selectedClient.id != 0) {
      // id 0 means client not selected
      widget.onSaveSelectedClient(provider.states.selectedClient);
      Navigator.of(context).pop();
      setState(() {
        provider.states.selectedClient = const UserClientInvoice();
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
      provider.states.searchQuery = "";
      provider.states.currentPage = 1;
      provider.states.selectedClient = const UserClientInvoice();
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
      appBar: AppBar(
        title: const Text('select client'),
        actions: [_buildSaveButton(provider.states)]
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

    if (state.clientInvoices.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          saveSelectedClient();
        },
        child: const Text('save'),
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
          if (provider.states.clientInvoices.isEmpty &&
              provider.states.isAfterSearch == false) {
            return Container();
          }
          return MTextFormField(
            controller: searchController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 1,
            onChanged: onSearchChanged,
            labelText: 'search client',
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
        if (provider.states.clientInvoices.isEmpty &&
            provider.states.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              addNewClient();
            },
            child: const Row(
              children: [
                Icon(Icons.add,),
                SizedBox(
                  width: 4,
                ),
                Text('add new client',
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (provider.states.clientInvoices.isEmpty &&
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
                  text: 'no client added',
                  refreshButtonText: 'add new client',
                ),
              ],
            ),
          );
        } else if (provider.states.clientInvoices.isEmpty &&
            provider.states.isAfterSearch) {
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
        } else {
          return ListView.builder(
            itemCount:
                provider.states.clientInvoices.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (ctx, index) {
              var userClient = provider.states.clientInvoices[index];
              return ItemListClientInvoice(
                model: userClient,
                groupValue: provider.states.selectedClient,
                onTap: () {
                  provider.changeSelectedClient(userClient);
                },
                onEdit: () {
                  AddClientScreen.launchScreen(context, userClient.id, true, (client) {
                    Navigator.of(context).pop();
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
                          title: "delete ${userClient.name}",
                          subTitle: 'Are you sure want to delete client?',
                          context: context,
                          leftButtonText: 'Yes',
                          rightButtonText: 'Cancel',
                          onLeftButtonClicked: () {
                            Navigator.of(context).pop();
                            showSnackBar(
                              context: context,
                              text: 'Please wait',
                            );
                            provider
                                .deleteClient(clientId: userClient.id)
                                .then((value) {
                              if (value) {
                                showSnackBar(
                                  context: context,
                                  text: 'delete client success',
                                  snackBarType: SnackBarType.success,
                                );

                                // when delete same client as in selected client in add invoice
                                // also delete the selected client in add invoice
                                if(Provider.of<InvoicesProvider>(context, listen: false).state.selectedClient.id == userClient.id) {
                                  Provider.of<InvoicesProvider>(context, listen: false).changeSelectedClient(const UserClientInvoice());
                                  provider.changeSelectedClient(const UserClientInvoice());
                                }
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: 'Delete client error',
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
                      text: 'Delete selected client',
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

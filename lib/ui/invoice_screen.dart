import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/invoice_api.dart';
import '../model/invoice_list_model.dart';
import 'add_invoice_screen.dart';
import 'components/dialog.dart';
import 'components/error_screens.dart';
import 'components/form_text_field.dart';
import 'components/invoice_item.dart';
import 'components/snack_bar.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late InvoicesProvider provider;
  final searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Timer? _debounce;

  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchInvoice(query: searchController.text.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoicesProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.getData();
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
      }
    });
  }

  refreshData() {
    searchController.clear();
    setState(() {
      provider.state.searchQuery = "";
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = false;
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    provider.getData();
  }

  searchInvoice({required String query}) {
    setState(() {
      provider.state.searchQuery = query;
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
    });
    provider.getData();
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    provider.state.currentPage = 1;
    provider.state.isAfterSearch = false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoicesProvider>(context);
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(title: const Text('invoice')),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _getWidgetBasedOnState(InvoicesProviderState state) {
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

  Widget _successContent(InvoicesProviderState state) {
    List<Widget> children = [];
    children.add(
      const SizedBox(
        height: 25,
      ),
    );

    children.add(
      // === search field
      Builder(builder: (context) {
        if (provider.state.invoiceListModel.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return ITextFormField(
          controller: searchController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
          onChanged: onSearchChanged,
          labelText: 'search invoice',
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
      height: 20,
    ));

    children.add(
      // create new invoice button
      Builder(builder: (context) {
        if (provider.state.invoiceListModel.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              AddInvoiceScreen.launchScreen(context);
            },
            child: const Row(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.purple,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'add new invoice',
                ),
              ],
            ),
          ),
        );
      }),
      // create new invoice button
    );

    children.add(const SizedBox(height: 20));
    children.add(
      Builder(builder: (context) {
        if (state.loading) {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              child: const CircularProgressIndicator(),
            ),
          );
        } else if (provider.state.invoiceListModel.isEmpty &&
            !provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Column(
              children: [
                EmptyWidget(
                  onRefresh: () {
                    AddInvoiceScreen.launchScreen(context);
                  },
                  text: 'no invoice added',
                  refreshButtonText: 'add new invoice',
                ),
              ],
            ),
          );
        } else if (provider.state.invoiceListModel.isEmpty &&
            provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.15,
            ),
            child: EmptyWidget(
              onRefresh: () {
                refreshData();
              },
              text: 'no results found',
            ),
          );
        } else {
          return ListView.builder(
            itemCount: provider.state.invoiceListModel.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              Invoices invoice =
                  provider.state.invoiceListModel[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InvoiceItem(
                  model: invoice,
                  onTap: () {},
                  onEdit: () {
                    // context.router.push(AddInvoiceScreenRoute(
                    //   invoiceId: invoice.id,
                    //   isEditMode: true,
                    // ));
                  },
                  onViewInvoice: () {
                    // context.router.push(InvoiceDetailScreenRoute(
                    //   invoices: invoice,
                    // ));
                  },
                  onSendInvoice: () {
                    showSnackBar(
                      context: context,
                      text: 'send invoice reminder success',
                      snackBarType: SnackBarType.success,
                    );
                  },
                  onMarkAsPaid: () {
                    Future.delayed(
                      const Duration(seconds: 0),
                      () {
                        showCustomAlertDialog(
                          title: 'mark as paid',
                          subTitle: 'are you sure want to mark as paid this invoice',
                          context: context,
                          leftButtonText: 'yes',
                          rightButtonText: 'cancel',
                          onLeftButtonClicked: () {
                            Navigator.of(context).pop();
                            showSnackBar(
                              context: context,
                              text: 'please wait',
                            );
                            provider.markAsPaid(invoice.id).then((value) {
                              if (value) {
                                setState(() {
                                  provider.state.invoiceListModel.singleWhere((element) {
                                    return element.id == invoice.id;
                                  }).status = 4;
                                });
                                showSnackBar(
                                  context: context,
                                  text: 'mark as paid success',
                                  snackBarType: SnackBarType.success,
                                );
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: 'mark as paid error',
                                  snackBarType: SnackBarType.error,
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
                  },
                ),
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

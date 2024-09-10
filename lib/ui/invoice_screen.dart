import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice_management/language/language_screen.dart';
import 'package:provider/provider.dart';

import '../api/invoice_api.dart';
import '../model/invoice_list_model.dart';
import 'add_invoice_screen.dart';
import 'components/dialog.dart';
import 'components/error_screens.dart';
import 'components/form_text_field.dart';
import 'components/invoice_item.dart';
import 'components/snack_bar.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

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
          scrollController.position.maxScrollExtent) {}
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Registers'.tr()),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //     child: IconButton(
        //         onPressed: () {
        //           Navigator.pushReplacement(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => const LanguageScreen()),
        //           );
        //         },
        //         icon: const Icon(
        //           Icons.language_outlined,
        //           color: Colors.white,
        //         )),
        //   )
        // ],
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
    children.add(const SizedBox(height: 25.0));

    children.add(
      Builder(builder: (context) {
        if (provider.state.invoiceListModel.isEmpty &&
            provider.state.isAfterSearch == false) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 60,
          child: MTextFormField(
            controller: searchController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 1,
            onChanged: onSearchChanged,
            labelText: 'Registers'.tr(),
            prefixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/search.png",
                  width: 24,
                  height: 24,
                  color: Colors.blue,
                ),
              ],
            ),
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
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.purple,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  'Add New Register'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  text: 'No Register'.tr(),
                  refreshButtonText: 'Add Register'.tr(),
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
              text: 'No Results Found'.tr(),
            ),
          );
        } else {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.state.invoiceListModel.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              Invoices invoice = provider.state.invoiceListModel[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InvoiceItem(
                  model: invoice,
                  onTap: () {},
                  onDelete: () {
                    Future.delayed(
                      const Duration(seconds: 0),
                      () {
                        showCustomAlertDialog(
                          title: 'Delete Register',
                          subTitle:
                              'are_you_sure_want_to_delete_this_register'.tr(),
                          context: context,
                          leftButtonText: 'yes'.tr(),
                          rightButtonText: 'cancel'.tr(),
                          onLeftButtonClicked: () {
                            Navigator.of(context).pop();
                            showSnackBar(
                              context: context,
                              text: 'please_wait'.tr(),
                            );
                            provider.delete(invoice.id).then((value) {
                              if (value) {
                                showSnackBar(
                                  context: context,
                                  text: 'register_deleted'.tr(),
                                  snackBarType: SnackBarType.success,
                                );
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: 'error'.tr(),
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
                  onEdit: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddInvoiceScreen(
                            invoice: invoice, isEditMode: true)));
                  },
                  onViewInvoice: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            InvoiceDetailScreen(invoices: invoice)));
                  },
                  // onMarkAsPaid: () {
                  //   Future.delayed(
                  //     const Duration(seconds: 0),
                  //     () {
                  //       showCustomAlertDialog(
                  //         title: 'mark as paid',
                  //         subTitle:
                  //             'are you sure want to mark as paid this invoice',
                  //         context: context,
                  //         leftButtonText: 'yes',
                  //         rightButtonText: 'cancel',
                  //         onLeftButtonClicked: () {
                  //           Navigator.of(context).pop();
                  //           showSnackBar(
                  //             context: context,
                  //             text: 'please wait',
                  //           );
                  //           provider.markAsPaid(invoice.id).then((value) {
                  //             if (value) {
                  //               setState(() {
                  //                 provider.state.invoiceListModel
                  //                     .singleWhere((element) {
                  //                   return element.id == invoice.id;
                  //                 }).status = 4;
                  //               });
                  //               showSnackBar(
                  //                 context: context,
                  //                 text: 'mark as paid success',
                  //                 snackBarType: SnackBarType.success,
                  //               );
                  //             } else {
                  //               showSnackBar(
                  //                 context: context,
                  //                 text: 'mark as paid error',
                  //                 snackBarType: SnackBarType.error,
                  //               );
                  //             }
                  //           });
                  //         },
                  //         onRightButtonClicked: () {
                  //           Navigator.of(context).pop();
                  //         },
                  //       );
                  //     },
                  //   );
                  // },
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

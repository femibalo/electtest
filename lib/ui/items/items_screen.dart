import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_management/ui/components/form_text_field.dart';
import 'package:provider/provider.dart';
import '../../api/invoice_api.dart';
import '../../api/item_api.dart';
import '../../model/bill_product_item_model.dart';
import '../components/dialog.dart';
import '../components/error_screens.dart';
import '../components/snack_bar.dart';
import 'add_invoice_item_screen.dart';
import 'components/item_list.dart';
import 'components/price_detail.dart';

class InvoiceItemsScreen extends StatefulWidget {
  final List<UserBillProductItem> selectedItemsInAddInvoiceScreen;
  final void Function(List<UserBillProductItem>) onSaveSelectedItems;
  const InvoiceItemsScreen(
      {super.key,
      required this.selectedItemsInAddInvoiceScreen,
      required this.onSaveSelectedItems});

  static const String id = "itemsInvoice";
  static void launchScreen(
      {required BuildContext context,
      required List<UserBillProductItem> selectedItemsInAddInvoiceScreen,
      required Function(List<UserBillProductItem>) onSaveSelectedItems}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InvoiceItemsScreen(
                  selectedItemsInAddInvoiceScreen:
                      selectedItemsInAddInvoiceScreen,
                  onSaveSelectedItems: onSaveSelectedItems,
                )));
  }

  @override
  State<InvoiceItemsScreen> createState() => _InvoiceItemsScreenState();
}

class _InvoiceItemsScreenState extends State<InvoiceItemsScreen> {
  late InvoiceItemProvider provider;
  final searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? _debounce;

  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchItem(query: searchController.text.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoiceItemProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
      provider.getData();
      provider.setSelectedItemsFromAddInvoiceScreen(
          widget.selectedItemsInAddInvoiceScreen);
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {}
    });
  }

  searchItem({required String query}) {
    setState(() {
      provider.state.searchQuery = query;
      provider.state.currentPage = 1;
      provider.state.isAfterSearch = true;
    });
    provider.getData();
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
    provider.getData();
  }

  addNewItem() async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddInvoiceItemScreen()));
  }

  // send selected items to add invoice screen
  saveSelectedItems() {
    if (provider.state.selectedItems.isEmpty) {
      showSnackBar(
        context: context,
        text: 'select at least one equipment item',
        snackBarType: SnackBarType.error,
      );
    } else {
      widget.onSaveSelectedItems(provider.state.selectedItems.toList());
      Navigator.pop(context);
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
    final provider = Provider.of<InvoiceItemProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('select_equipment_items'.tr()),
          actions: [_buildSaveButton(provider.state)],
        ),
        bottomNavigationBar: _buildPriceDetailCard(provider.state),
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
      ),
    );
  }

  Widget _buildPriceDetailCard(InvoiceItemState state) {
    if (state.isNetworkError) {
      return const SizedBox();
    }

    if (state.isError) {
      return const SizedBox();
    }

    if (state.loading) {
      return Container(
        height: 82,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(),
            ),
          ),
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Container(
          //       margin: const EdgeInsets.only(
          //         top: 5,
          //         bottom: 10,
          //         left: 20,
          //         right: 20,
          //       ),
          //       child: TotalItemsPriceDetail(
          //         title: 'subtotal'.tr(),
          //         value: NumberFormat("#,###").format(provider.state.subTotal),
          //       ),
          //     ),
          //     Container(
          //       margin: const EdgeInsets.only(
          //         top: 5,
          //         bottom: 10,
          //         left: 20,
          //         right: 20,
          //       ),
          //       child: TotalItemsPriceDetail(
          //         title: 'tax'.tr(),
          //         value: NumberFormat("#,###").format(provider.state.tax),
          //       ),
          //     ),
          //     Container(
          //       margin: const EdgeInsets.only(
          //         top: 5,
          //         bottom: 10,
          //         left: 20,
          //         right: 20,
          //       ),
          //       child: TotalItemsPriceDetail(
          //         title: 'discount'.tr(),
          //         value: NumberFormat("#,###").format(provider.state.discount),
          //       ),
          //     ),
          //     Container(
          //       margin: const EdgeInsets.only(
          //         top: 5,
          //         bottom: 15,
          //         left: 20,
          //         right: 20,
          //       ),
          //       child: TotalItemsPriceDetail(
          //         title: 'total'.tr(),
          //         value:
          //             NumberFormat("#,###").format(provider.state.finalPrice),
          //         isBold: true,
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(InvoiceItemState state) {
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
      child: TextButton(
        onPressed: () {
          saveSelectedItems();
        },
        child: Text('save'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _getWidgetBasedOnState(InvoiceItemState state) {
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

  Widget _successContent(InvoiceItemState state) {
    List<Widget> children = [];
    children.add(
      const SizedBox(
        height: 15,
      ),
    );

    children.add(
      // === search field
      Builder(builder: (ctx) {
        if (provider.state.billProductItems.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return SizedBox(
          height: 50,
          child: MTextFormField(
            controller: searchController,
            textInputAction: TextInputAction.done,
            labelText: 'search'.tr(),

            textCapitalization: TextCapitalization.sentences,
            maxLines: 1,
            // decoration: const InputDecoration(hintText: 'Search'),
            onChanged: onSearchChanged,
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
      height: 20,
    ));

    children.add(
      // create new item button
      Builder(builder: (ctx) {
        if (provider.state.billProductItems.isEmpty &&
            provider.state.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              addNewItem();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text('add_new_equipment_item'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      }),
      // create new item button
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
        } else if (provider.state.billProductItems.isEmpty &&
            !provider.state.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Column(
              children: [
                EmptyWidget(
                  onRefresh: () {
                    addNewItem();
                  },
                  text: 'no_equipment_items_added'.tr(),
                  refreshButtonText: 'add_new_equipment_item'.tr(),
                ),
              ],
            ),
          );
        } else if (provider.state.billProductItems.isEmpty &&
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
          itemCount: provider.state.billProductItems.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            var userItem = provider.state.billProductItems[index];
            return ItemListInvoiceItem(
              model: userItem,
              selectedItems: provider.state.selectedItems,
              onIncrease: () {
                provider.increaseItemQty(userItem.id);
              },
              onDecrease: () {
                provider.decreaseItemQty(userItem.id);
              },
              onEdit: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddInvoiceItemScreen(
                        itemID: userItem.id,
                        userAddItem: userItem,
                        isEditMode: true)));
              },
              onDelete: () {
                // handle selected item to delete
                // UserBillProductItem? checkItemIsInSelectedItem = provider.state.selectedItems.firstWhere((element) => element.id == userItem.id);

                Future.delayed(
                  const Duration(seconds: 0),
                  () {
                    showCustomAlertDialog(
                      title: 'delete ${userItem.name}',
                      subTitle:
                          'are_you_sure_want_to_delete_equipment_item'.tr(),
                      context: context,
                      leftButtonText: 'yes'.tr(),
                      rightButtonText: 'cancel'.tr(),
                      onLeftButtonClicked: () {
                        Navigator.of(context).pop();
                        showSnackBar(
                          context: context,
                          text: 'please_wait'.tr(),
                        );
                        provider.deleteItem(itemId: userItem.id).then((value) {
                          if (value) {
                            showSnackBar(
                              context: context,
                              text: 'delete_item_success'.tr(),
                              snackBarType: SnackBarType.success,
                            );
                            Provider.of<InvoicesProvider>(
                              context,
                              listen: false,
                            ).removeBillProductItemWhere(0);
                            Provider.of<InvoicesProvider>(
                              context,
                              listen: false,
                            ).calculate();
                          } else {
                            showSnackBar(
                              context: context,
                              text: 'delete_item_error'.tr(),
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
}

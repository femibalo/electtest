import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      {Key? key,
      required this.selectedItemsInAddInvoiceScreen,
      required this.onSaveSelectedItems})
      : super(key: key);

  static const String id = "itemsInvoice";
  static void launchScreen({required BuildContext context, 
  required List<UserBillProductItem> selectedItemsInAddInvoiceScreen, 
  required Function(List<UserBillProductItem>) onSaveSelectedItems}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceItemsScreen(selectedItemsInAddInvoiceScreen: selectedItemsInAddInvoiceScreen, onSaveSelectedItems: onSaveSelectedItems,)));
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
        widget.selectedItemsInAddInvoiceScreen,
      );
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {

      }
    });
  }

  searchItem({required String query}) {
    setState(() {
      provider.states.searchQuery = query;
      provider.states.currentPage = 1;
      provider.states.isAfterSearch = true;
    });
    provider.getData();
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
    provider.getData();
  }

  addNewItem() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddInvoiceItemScreen()));
  }

  // send selected items to add invoice screen
  saveSelectedItems() {
    if (provider.states.selectedItems.isEmpty) {
      showSnackBar(
        context: context,
        text: 'select at least one item',
        snackBarType: SnackBarType.error,
      );
    } else {
      widget.onSaveSelectedItems(provider.states.selectedItems.toList());
      Navigator.pop(context);
    }
  }

  reset() {
    setState(() {
      provider.states.searchQuery = "";
      provider.states.currentPage = 1;
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
    final provider = Provider.of<InvoiceItemProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('select items'),
          actions: [_buildSaveButton(provider.states)],
        ),
        bottomNavigationBar: _buildPriceDetailCard(provider.states),
        body: _getWidgetBasedOnState(provider.states),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: 'subtotal',
                  value: NumberFormat("#,###").format(provider.states.subTotal),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: 'tax',
                  value: NumberFormat("#,###").format(provider.states.tax),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: 'discount',
                  value: NumberFormat("#,###").format(provider.states.discount),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 15,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: 'total',
                  value:
                      NumberFormat("#,###").format(provider.states.finalPrice),
                  isBold: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(InvoiceItemState state){
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
        child: const Text('save'),
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
        if (provider.states.billProductItems.isEmpty &&
            provider.states.isAfterSearch == false) {
          return Container();
        }
        return TextFormField(
          controller: searchController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
          onChanged: onSearchChanged,
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
        if (provider.states.billProductItems.isEmpty &&
            provider.states.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: ElevatedButton(
            onPressed: () {
              addNewItem();
            },
            child: const Row(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'add new item',
                ),
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (provider
                .states.billProductItems.isEmpty &&
            !provider.states.isAfterSearch) {
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
                  text: 'no items added',
                  refreshButtonText: 'add new item',
                ),
              ],
            ),
          );
        } else if (provider
                .states.billProductItems.isEmpty &&
            provider.states.isAfterSearch) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
            ),
            child: EmptyWidget(
              onRefresh: () {
                refreshData();
              },
              text: 'no results found',
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.states.billProductItems.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            var userItems =
                provider.states.billProductItems[index];
            return ItemListInvoiceItem(
              model: userItems,
              selectedItems: provider.states.selectedItems,
              onIncrease: () {
                provider.increaseItemQty(userItems.id);
              },
              onDecrease: () {
                provider.decreaseItemQty(userItems.id);
              },
              onEdit: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddInvoiceItemScreen(
                  itemID: userItems.id,
                  isEditMode: true,
                )));
              },
              onDelete: () {
                // handle selected item to delete
                UserBillProductItem? checkItemIsInSelectedItem = provider
                    .states.selectedItems
                    .firstWhere((element) => element.id == userItems.id);
                Future.delayed(
                  const Duration(seconds: 0), () {
                    showCustomAlertDialog(
                      title: 'delete ${userItems.name}',
                      subTitle: 'Are you sure want to delete item',
                      context: context,
                      leftButtonText: 'yes',
                      rightButtonText: 'cancel',
                      onLeftButtonClicked: () {
                        Navigator.of(context).pop();
                        showSnackBar(
                          context: context,
                          text: 'please wait',
                        );
                        provider
                            .deleteItem(itemId: userItems.id)
                            .then((value) {
                          if (value) {
                            showSnackBar(
                              context: context,
                              text: 'delete item success',
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
                              text: 'Delete item error',
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

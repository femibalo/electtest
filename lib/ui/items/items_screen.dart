// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers

import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/buttons/filled_button.dart';
import 'package:mezink_app/material_components/buttons/text_button.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/material_components/text_field/form_text_field.dart';
import 'package:mezink_app/routes/app_routing.gr.dart';
import 'package:mezink_app/screens/invoices/api/invoice_api.dart';
import 'package:mezink_app/screens/invoices/api/item_api.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:collection/collection.dart';
import 'package:mezink_app/screens/invoices/ui/items/add_invoice_item_screen.dart';
import 'package:mezink_app/screens/invoices/ui/items/components/item_list.dart';
import 'package:mezink_app/screens/invoices/ui/items/components/price_detail.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:mezink_app/styles/progress_indicator.dart';

import '../../../../components/error_screens.dart';
import '../../../../generated/l10n.dart';
import '../../api/item_api.dart';
import '../../model/bill_product_item_model.dart';

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
        provider.getMore();
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
    AddInvoiceItemScreen.launchScreen(context);
  }

  // send selected items to add invoice screen
  saveSelectedItems() {
    if (provider.states.selectedItems.isEmpty) {
      showSnackBar(
        context: context,
        text: S.current.select_at_least_one_item,
        snackBarType: SnackBarType.error,
      );
    } else {
      widget.onSaveSelectedItems(provider.states.selectedItems.toList());
      context.router.pop();
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
        backgroundColor: context.backgroundColor,
        appBar: MAppBar(
          title: S.current.select_items,
          actions: [_buildSaveButton(provider.states)],
        ),
        bottomNavigationBar: _buildPriceDetailCard(provider.states),
        body: _getWidgetBasedOnState(provider.states),
      ),
    );
  }

  Widget _buildPriceDetailCard(InvoiceItemState state) {
    if (state.isNetworkError) {
      return SizedBox();
    }

    if (state.isError) {
      return SizedBox();
    }

    if (state.loading) {
      return Container(
        height: 82,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: context.disabledColor,
            ),
          ),
        ),
        child: Center(child: AdaptiveProgressIndicator()),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.disabledColor,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: S.current.subtotal,
                  value: NumberFormat("#,###").format(provider.states.subTotal),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: S.current.tax,
                  value: NumberFormat("#,###").format(provider.states.tax),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: S.current.discount,
                  value: NumberFormat("#,###").format(provider.states.discount),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 5,
                  bottom: 15,
                  left: 20,
                  right: 20,
                ),
                child: TotalItemsPriceDetail(
                  title: S.current.total,
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
      return SizedBox();
    }

    if (state.isError) {
      return SizedBox();
    }

    if (state.loading) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: MTextButton(
        isAppBarAction: true,
        onPressed: () {
          saveSelectedItems();
        },
        child: Text(S.current.save),
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
        if (provider.states.billProductItemModel.data.userItems.isEmpty &&
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
            labelText: S.current.search_items,
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
      // create new item button
      Builder(builder: (ctx) {
        if (provider.states.billProductItemModel.data.userItems.isEmpty &&
            provider.states.isAfterSearch == false) {
          return Container();
        }
        return UnconstrainedBox(
          child: MFilledButton(
            onPressed: () {
              addNewItem();
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
                  S.current.add_new_item,
                ),
              ],
            ),
          ),
        );
      }),
      // create new item button
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
                .states.billProductItemModel.data.userItems.isEmpty &&
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
                  text: S.current.no_items_added,
                  refreshButtonText: S.current.add_new_item,
                ),
              ],
            ),
          );
        } else if (provider
                .states.billProductItemModel.data.userItems.isEmpty &&
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
        }
        return ListView.builder(
          itemCount: provider.states.billProductItemModel.data.userItems.length,
          shrinkWrap: true,
          physics: customScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            var userItems =
                provider.states.billProductItemModel.data.userItems[index];
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
                context.router.push(AddInvoiceItemScreenRoute(
                  itemID: userItems.id,
                  isEditMode: true,
                ));
              },
              onDelete: () {
                // handle selected item to delete
                UserBillProductItem? checkItemIsInSelectedItem = provider
                    .states.selectedItems
                    .singleWhereOrNull((element) => element.id == userItems.id);
                if (checkItemIsInSelectedItem == null) {
                  int deletedItemId = userItems.id;
                  Future.delayed(
                    const Duration(seconds: 0),
                    () {
                      showCustomAlertDialog(
                        title: "${S.current.delete} ${userItems.name}",
                        subTitle: S.current.are_you_sure_want_to_delete_item,
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
                              .deleteItem(itemId: userItems.id)
                              .then((value) {
                            if (value) {
                              showSnackBar(
                                context: context,
                                text: S.current.delete_item_success,
                                snackBarType: SnackBarType.success,
                              );
                              Provider.of<InvoicesProvider>(
                                context,
                                listen: false,
                              ).removeBillProductItemWhere(deletedItemId);
                              Provider.of<InvoicesProvider>(
                                context,
                                listen: false,
                              ).calculate();
                            } else {
                              showSnackBar(
                                context: context,
                                text: S.current.delete_item_error,
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
                    text: S.current.delete_selected_item,
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
}

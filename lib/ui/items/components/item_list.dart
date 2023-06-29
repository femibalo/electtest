import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../model/bill_product_item_model.dart';
import '../../components/elevated_card.dart';

class ItemListInvoiceItem extends StatelessWidget {
  const ItemListInvoiceItem({
    Key? key,
    required this.model,
    required this.selectedItems,
    required this.onIncrease,
    required this.onDecrease,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final UserBillProductItem model;
  final List<UserBillProductItem> selectedItems;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    String price =
        "${model.currencyCode} ${NumberFormat('#,###').format(model.price)}";
    String tax = model.taxPercent == 0
        ? ""
        : " | tax ${model.taxPercent.toString()}%";
    String discount = model.discountPercent == 0
        ? ""
        : " | disc ${model.discountPercent.toString()}%";
    String subtitle = "$price$tax$discount";
    return ElevatedCard(
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        margin: const EdgeInsets.only(
          left: 15,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text.rich(
                  TextSpan(
                    text: model.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  subtitle),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildCircleBorderButton(
                    icons: Icons.remove,
                    onTap: model.isDeleted ? () {} : onDecrease,
                    context: context,
                  ),
                  Text(
                    selectedItems.any((element) => element.id == model.id)
                        ? selectedItems
                            .singleWhere((element) => element.id == model.id)
                            .qty
                            .toString()
                        : model.qty.toString(),
                  ),
                  buildCircleBorderButton(
                    icons: Icons.add,
                    onTap: model.isDeleted ? () {} : onIncrease,
                    context: context,
                  ),
                ],
              ),
            ),
            Container(
              width: 25,
              margin: const EdgeInsets.only(left: 10),
              child: PopupMenuButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  Icons.more_vert_rounded,
                ),
                itemBuilder: (context) {
                  if (!model.isDeleted) {
                    return [
                      PopupMenuItem(
                        value: 1,
                        onTap: onEdit,
                        child: const Text('edit'),
                      ),
                      PopupMenuItem(
                        value: 2,
                        onTap: onDelete,
                        child: const Text('delete'),
                      )
                    ];
                  }
                  return [];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircleBorderButton(
      {required IconData icons, required VoidCallback onTap, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 10.5,
        child: CircleAvatar(
          radius: 10,
          child: Icon(
            icons,
            size: 15,
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/cards/elevated_card.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:mezink_app/styles/color.dart';

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
        : " | ${S.current.tax} ${model.taxPercent.toString()}%";
    String discount = model.discountPercent == 0
        ? ""
        : " | ${S.current.discount.substring(0, 4)} ${model.discountPercent.toString()}%";
    String subtitle = "$price$tax$discount";
    return MElevatedCard(
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        margin: EdgeInsets.only(
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
                    text: model.name,
                    style: context.getTitleMediumTextStyle(model.isDeleted ? MColors.lightGrey3 : context.onSurfaceColor)

                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  subtitle,
                  style: context.getTitleSmallTextStyle(model.isDeleted ? MColors.lightGrey3 : MColors.lightGrey)
                ),
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
                    style: context.getTitleMediumTextStyle(context.onSurfaceColor),
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
              margin: EdgeInsets.only(left: 10),
              child: PopupMenuButton(
                padding: const EdgeInsets.all(0),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: model.isDeleted ? MColors.lightGrey3 : null,
                ),
                itemBuilder: (context) {
                  if (!model.isDeleted) {
                    return [
                      PopupMenuItem(
                        child: Text(
                          S.current.edit,
                        ),
                        value: 1,
                        onTap: onEdit,
                      ),
                      PopupMenuItem(
                        child: Text(
                          S.current.delete,
                        ),
                        value: 2,
                        onTap: onDelete,
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
        backgroundColor:
            model.isDeleted ? MColors.lightGrey3.withOpacity(0.2) : context.primaryColor,
        child: CircleAvatar(
          radius: 10,
          backgroundColor: MColors.transparent,
          child: Icon(
            icons,
            size: 15,
            color: model.isDeleted ? MColors.lightGrey3 : context.primaryContainerColor,
          ),
        ),
      ),
    );
  }
}

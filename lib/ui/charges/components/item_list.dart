// ignore_for_file: sort_child_properties_last, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/material_components/cards/elevated_card.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/screens/invoices/model/invoice_charge_model.dart';
import 'package:mezink_app/styles/color.dart';
import 'package:mezink_app/utils/common/api_keys.dart';

import '../../../../../generated/l10n.dart';

class ItemListChargesInvoice extends StatelessWidget {
  const ItemListChargesInvoice({
    Key? key,
    required this.model,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final InvoiceChargeModel model;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return MElevatedCard(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              contentPadding: EdgeInsets.only(left: 5),
              value: model.isSelected,
              activeColor: context.primaryColor,
              onChanged: (val) {
                onTap();
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: Text.rich(
                TextSpan(
                  text: model.name,
                  style: context.getTitleMediumTextStyle(context.onSurfaceColor)
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                model.operation == '-'
                    ? toBeginningOfSentenceCase(S.current.subtract)!
                    : toBeginningOfSentenceCase(S.current.add)!,
                  style: context.getLabelLargeTextStyle(MColors.lightGrey)
              ),
              secondary: Text(
                model.type == APIKeys.percent
                    ? "${model.value.toString()}%"
                    : NumberFormat('#,###').format(model.value).toString(),
                  style: context.getTitleMediumTextStyle(context.onSurfaceColor)
              ),
            ),
          ),
          Container(
            width: 40,
            child: PopupMenuButton(
              padding: const EdgeInsets.all(0),
              child: Icon(
                Icons.more_vert_rounded,
              ),
              itemBuilder: (context) => [
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

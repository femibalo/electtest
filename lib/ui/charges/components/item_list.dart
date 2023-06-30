import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../model/invoice_charge_model.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.only(left: 5),
              value: model.isSelected,
              activeColor: Colors.blue,
              onChanged: (val) {
                onTap();
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: Text.rich(
                TextSpan(
                  text: model.name,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                model.operation == '-'
                    ? toBeginningOfSentenceCase('subtract')!
                    : toBeginningOfSentenceCase('add')!,
              ),
              secondary: Text(
                  "${model.value.toString()}%"
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: PopupMenuButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                Icons.more_vert_rounded,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  onTap: onEdit,
                  child: const Text(
                    'edit',
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  onTap: onDelete,
                  child: const Text(
                   'delete',
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

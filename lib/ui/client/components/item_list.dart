import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../model/client_invoice_model.dart';

class ItemListClientInvoice extends StatelessWidget {
  const ItemListClientInvoice({
    super.key,
    required this.model,
    required this.groupValue,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final UserClientInvoice model;
  final UserClientInvoice groupValue;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: model.isDeleted ? 0.4 : 1,
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              contentPadding: EdgeInsets.zero,
              value: model,
              activeColor: Colors.blue,
              groupValue: groupValue,
              onChanged: (val) {
                if (!model.isDeleted) {
                  onTap();
                }
              },
              secondary: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                    "https://ui-avatars.com/api/?name=${model.displayName == '' ? model.name : model.displayName}&background=${model.isDeleted ? 'D3D3D3' : 'random'}"),
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              title: Text.rich(
                TextSpan(
                  text:
                      model.displayName == '' ? model.name : model.displayName,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
              itemBuilder: (context) => model.isDeleted
                  ? []
                  : [
                      PopupMenuItem(
                        value: 1,
                        onTap: () async {
                          await Future.delayed(Duration.zero);
                          onEdit();
                        },
                        child: Text(
                          'edit'.tr(),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        onTap: onDelete,
                        child: Text(
                          'delete'.tr(),
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

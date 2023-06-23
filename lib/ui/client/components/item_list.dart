// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/screens/invoices/model/client_invoice_model.dart';

class ItemListClientInvoice extends StatelessWidget {
  const ItemListClientInvoice({
    Key? key,
    required this.model,
    required this.groupValue,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final UserClientInvoice model;
  final UserClientInvoice groupValue;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: model.isDeleted ? 0.4 : 1,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: RadioListTile(
                contentPadding: EdgeInsets.zero,
                value: model,
                activeColor: context.primaryColor,
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
                    text: model.displayName == ''
                        ? model.name
                        : model.displayName,
                    style :context.getTitleMediumTextStyle(context.onSurfaceColor)
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                itemBuilder: (context) => model.isDeleted
                    ? []
                    : [
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
      ),
    );
  }
}

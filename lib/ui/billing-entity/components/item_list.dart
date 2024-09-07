import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../model/billing_entity_model.dart';

class ItemListBillingEntity extends StatelessWidget {
  const ItemListBillingEntity({
    super.key,
    required this.model,
    required this.groupValue,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final BillingEntityProfiles model;
  final BillingEntityProfiles groupValue;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            value: model,
            groupValue: groupValue,
            activeColor: Colors.blue,
            onChanged: (val) {
              onTap();
            },
            secondary: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: FileImage(File(model.logoURL)),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text.rich(
              TextSpan(
                text: model.name,
              ),
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
    );
  }
}

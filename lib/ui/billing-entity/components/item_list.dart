import 'package:flutter/material.dart';
import '../../../model/billing_entity_model.dart';

class ItemListBillingEntity extends StatelessWidget {
  const ItemListBillingEntity({
    Key? key,
    required this.model,
    required this.groupValue,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
              backgroundImage: NetworkImage(model.logoURL != ""
                  ? model.logoURL
                  : "https://ui-avatars.com/api/?name=${model.name}&background=${model.isDeleted ? 'D3D3D3' : 'random'}"),
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
    );
  }
}

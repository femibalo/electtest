// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/cards/elevated_card.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/screens/invoices/model/invoice_list_model.dart';
import 'package:mezink_app/styles/color.dart';
import 'package:mezink_app/utils/common/utils.dart';

class InvoiceItem extends StatelessWidget {
  const InvoiceItem({
    Key? key,
    required this.model,
    required this.onTap,
    required this.onEdit,
    required this.onViewInvoice,
    required this.onSendInvoice,
    required this.onMarkAsPaid,
  }) : super(key: key);

  final Invoices model;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewInvoice;
  final VoidCallback onSendInvoice;
  final VoidCallback onMarkAsPaid;
  @override
  Widget build(BuildContext context) {
    return MElevatedCard(
      child: Container(
        padding: EdgeInsets.only(
          bottom: 15,
          left: 15,
          top: 15,
          right: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          model.clientName,
                          style: context.getBodyMediumTextStyle(context.onSurfaceColor)
                        ),
                      ),
                      Expanded(
                        child: Text(
                          getDateddMMMyyyy(
                            DateFormat('yyyy-MM-dd').parse(model.invoiceDate),
                          ),
                          textAlign: TextAlign.right,
                          style: context.getBodySmallTextStyle(context.onSurfaceColor)
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${model.currencyCode.toUpperCase()} ${NumberFormat("#,###").format(model.finalPrice)}",
                            style: context.getBodyMediumTextStyle(context.onSurfaceColor)
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    width: 1,
                                    color: model.status != 4
                                        ? context.primaryColor
                                        : MColors.successColor,
                                  ),
                                ),
                                child: Text(
                                  model.status != 4
                                      ? S.current.pending.toLowerCase()
                                      : S.current.paid.toLowerCase(),
                                  textAlign: TextAlign.center,
                                  style: context.getBodySmallTextStyle(model.status != 4
                                        ? context.primaryColor
                                        : MColors.successColor)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              padding: const EdgeInsets.all(0),
              child: Icon(
                Icons.more_vert_rounded,
              ),
              itemBuilder: (context) {
                if (model.status != 4) {
                  return [
                    PopupMenuItem(
                      child: Text(S.current.view_invoice),
                      value: 1,
                      onTap: onViewInvoice,
                    ),
                    PopupMenuItem(
                      child: Text(S.current.edit),
                      value: 2,
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: Text(S.current.send_invoice),
                      value: 3,
                      onTap: onSendInvoice,
                    ),
                    PopupMenuItem(
                      child: Text(S.current.mark_as_paid),
                      value: 4,
                      onTap: onMarkAsPaid,
                    ),
                  ];
                }
                return [
                  PopupMenuItem(
                    child: Text(S.current.view_invoice),
                    value: 1,
                    onTap: onViewInvoice,
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

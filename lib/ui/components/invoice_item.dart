import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/invoice_list_model.dart';
import '../../utils/utils.dart';

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
    return Card(
      child: Container(
        padding: const EdgeInsets.only(
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
                        ),
                      ),
                      Expanded(
                        child: Text(
                          getDateddMMMyyyy(
                            DateFormat('yyyy-MM-dd').parse(model.invoiceDate),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${model.currencyCode.toUpperCase()} ${NumberFormat("#,###").format(model.finalPrice)}",
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.green,
                                  ),
                                ),
                                child: const Text(
                                  'paid',
                                  textAlign: TextAlign.center,
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
              child: const Icon(
                Icons.more_vert_rounded,
              ),
              itemBuilder: (context) {
                if (model.status != 4) {
                  return [
                    PopupMenuItem(
                      value: 1,
                      onTap: onViewInvoice,
                      child: const Text('view invoice'),
                    ),
                    PopupMenuItem(
                      value: 2,
                      onTap: onEdit,
                      child: const Text('edit'),
                    ),
                    PopupMenuItem(
                      value: 3,
                      onTap: onSendInvoice,
                      child: const Text('send invoice'),
                    ),
                    PopupMenuItem(
                      value: 4,
                      onTap: onMarkAsPaid,
                      child: const Text('mark as paid'),
                    ),
                  ];
                }
                return [
                  PopupMenuItem(
                    value: 1,
                    onTap: onViewInvoice,
                    child: const Text('view invoice'),
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

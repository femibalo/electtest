import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/invoice_list_model.dart';
import '../../utils/utils.dart';

class InvoiceItem extends StatelessWidget {
  const InvoiceItem(
      {Key? key,
      required this.model,
      required this.onTap,
      required this.onEdit,
      required this.onViewInvoice,
      required this.onDelete})
      : super(key: key);

  final Invoices model;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewInvoice;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
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
                            "${model.clientPhone}",
                          ),
                          //  child: Text(
                          //   "${model.currencyCode.toUpperCase()} ${NumberFormat("#,###").format(model.finalPrice)}",
                          // ),
                        ),
                        // Expanded(
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       Container(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 8,
                        //           vertical: 5,
                        //         ),
                        //         child: Text(
                        //           'paid'.tr(),
                        //           textAlign: TextAlign.center,
                        //           style: const TextStyle(color: Colors.green),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          onViewInvoice();
                        });
                      },
                      child: Text('View Register'.tr()),
                    ),
                    PopupMenuItem(
                      value: 2,
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          onEdit();
                        });
                      },
                      child: Text('Edit'.tr()),
                    ),
                    PopupMenuItem(
                      value: 4,
                      onTap: onDelete,
                      child: Text('Delete'.tr()),
                    ),
                  ];
                }
                return [
                  PopupMenuItem(
                    value: 1,
                    onTap: onViewInvoice,
                    child: Text('View Register'.tr()),
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

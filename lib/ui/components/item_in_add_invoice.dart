import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/bill_product_item_model.dart';

class ItemInAddInvoiceScreen extends StatefulWidget {
  const ItemInAddInvoiceScreen({
    super.key,
    required this.model,
  });
  final UserBillProductItem model;

  @override
  State<ItemInAddInvoiceScreen> createState() => _ItemInAddInvoiceScreenState();
}

class _ItemInAddInvoiceScreenState extends State<ItemInAddInvoiceScreen> {
  bool isDefault = true;

  changeDefaultToExpanded() {
    setState(() {
      isDefault = !isDefault;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isDefault ? buildDefaultItem() : buildExpandedItem();
  }

  Widget buildDefaultItem() {
    int subTotalPerItem = (widget.model.price * widget.model.qty);
    return GestureDetector(
      onTap: () {
        changeDefaultToExpanded();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget.model.name),
                  ),
                  // Expanded(
                  //   child: Text(
                  //     "${widget.model.currencyCode} ${NumberFormat('#,###').format(subTotalPerItem)}",
                  //     textAlign: TextAlign.right,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${widget.model.equipmentId}",
                    ),
                  ),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       changeDefaultToExpanded();
                  //     },
                  //     child: const Text(
                  //       "detail >",
                  //       textAlign: TextAlign.right,
                  //     ),
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpandedItem() {
    double nominalDiscount = (widget.model.discountPercent / 100) *
        (widget.model.qty * widget.model.price);
    double nominalTax = (widget.model.taxPercent / 100) *
        ((widget.model.qty * widget.model.price) - nominalDiscount);
    int subTotalPerItem = (widget.model.price * widget.model.qty);
    return GestureDetector(
      onTap: () {
        changeDefaultToExpanded();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.model.name,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.currencyCode} ${NumberFormat('#,###').format(subTotalPerItem)}",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'unit_price'.tr(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.currencyCode} ${NumberFormat('#,###').format(widget.model.price)}",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'quantity'.tr(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.qty}",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text("discount @ ${widget.model.discountPercent}%"),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format(nominalDiscount),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "tax @ ${widget.model.taxPercent}%",
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format(nominalTax),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        changeDefaultToExpanded();
                      },
                      child: Text(
                        'hide'.tr(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

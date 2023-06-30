import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/bill_product_item_model.dart';

class ItemInAddInvoiceScreen extends StatefulWidget {
  const ItemInAddInvoiceScreen({
    Key? key,
    required this.model,
  }) : super(key: key);
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
                      "${widget.model.qty} x ${widget.model.currencyCode.toUpperCase()} ${NumberFormat('#,###').format(widget.model.price)}",
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        changeDefaultToExpanded();
                      },
                      child: const Text(
                        "detail >",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
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
                    child: Text(widget.model.name,),
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
                  const Expanded(
                    child: Text('unit price',),
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
                  const Expanded(
                    child: Text(
                     'quantity',
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
                      child: const Text(
                        'hide',
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

// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mezink_app/material_components/cards/elevated_card.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/screens/invoices/model/bill_product_item_model.dart';
import 'package:mezink_app/styles/color.dart';

import '../../../../generated/l10n.dart';

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
      child: MElevatedCard(
        margin: EdgeInsets.only(bottom: 15),
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.model.name,
                      style: context.getTitleMediumTextStyle(context.onSurfaceColor)
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.currencyCode} ${NumberFormat('#,###').format(subTotalPerItem)}",
                      textAlign: TextAlign.right,
                      style: context.getTitleMediumTextStyle(context.onSurfaceColor)
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${widget.model.qty} x ${widget.model.currencyCode.toUpperCase()} ${NumberFormat('#,###').format(widget.model.price)}",
                      style: context.getTitleSmallTextStyle(MColors.grey)
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        changeDefaultToExpanded();
                      },
                      child: Text(
                        "${S.current.detail} >",
                        textAlign: TextAlign.right,
                        style: context.getLabelMediumTextStyle(MColors.primaryBlue)
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
      child: MElevatedCard(
        margin: EdgeInsets.only(bottom: 15),
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.model.name,
                      style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.currencyCode} ${NumberFormat('#,###').format(subTotalPerItem)}",
                      textAlign: TextAlign.right,
                      style: context.getTitleMediumTextStyle(context.onSurfaceColor),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      S.current.unit_price,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.currencyCode} ${NumberFormat('#,###').format(widget.model.price)}",
                      textAlign: TextAlign.right,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      S.current.quantity,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.model.qty}",
                      textAlign: TextAlign.right,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${S.current.discount} @ ${widget.model.discountPercent}%",
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${NumberFormat('#,###').format(nominalDiscount)}",
                      textAlign: TextAlign.right,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${S.current.tax} @ ${widget.model.taxPercent}%",
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${NumberFormat('#,###').format(nominalTax)}",
                      textAlign: TextAlign.right,
                      style: context.getBodyMediumTextStyle(MColors.lightGrey),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        changeDefaultToExpanded();
                      },
                      child: Text(
                        S.current.hide,
                        textAlign: TextAlign.right,
                        style: context.getLabelMediumTextStyle(MColors.primaryBlue),
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

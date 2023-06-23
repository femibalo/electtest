// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';

class TotalItemsPriceDetail extends StatelessWidget {
  const TotalItemsPriceDetail({
    Key? key,
    required this.title,
    required this.value,
    this.isBold = false,
  }) : super(key: key);
  final String title;
  final String value;
  final bool isBold;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            child: Text(
              title.toString(),
              style: context.getTitleMediumTextStyle(context.onSurfaceColor)?.copyWith(
                fontSize: isBold ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.getTitleMediumTextStyle(context.onSurfaceColor)?.copyWith(
                fontSize: isBold ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

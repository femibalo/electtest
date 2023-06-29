import 'package:flutter/material.dart';

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
          child: Text(
            title.toString(),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

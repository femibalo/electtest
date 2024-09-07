import 'package:flutter/material.dart';

class TotalItemsPriceDetail extends StatelessWidget {
  const TotalItemsPriceDetail({
    super.key,
    required this.title,
    required this.value,
    this.isBold = false,
  });
  final String title;
  final String value;
  final bool isBold;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title.toString(),
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

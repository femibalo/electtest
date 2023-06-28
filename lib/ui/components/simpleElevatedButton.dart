import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SimpleElevatedButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool expanded;

  const SimpleElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.expanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: AutoSizeText(text,
          maxLines: 4),
      onPressed: () {
        onPressed();
      },
    );
  }
}

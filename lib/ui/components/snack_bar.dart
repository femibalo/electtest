import 'package:flutter/material.dart';

enum SnackBarType { error, success, general, warning }


void showSnackBar(
    {required BuildContext context,
    required String text,
    SnackBarType snackBarType = SnackBarType.general, Duration? duration}) {
  Color contentColor;
  IconData icon;
  if (snackBarType == SnackBarType.error) {
    contentColor = Colors.red;
    icon = Icons.error;
  } else if (snackBarType == SnackBarType.success) {
    contentColor = Colors.green;
    icon = Icons.check_circle_rounded;
  } else if (snackBarType == SnackBarType.general) {
    contentColor = Colors.white;
    icon = Icons.info;
  } else if (snackBarType == SnackBarType.warning) {
    contentColor = Colors.red;
    icon = Icons.warning;
  } else {
    contentColor = Colors.white;
    icon = Icons.info;
  }

  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    elevation: 4,
    duration: duration ?? const Duration(milliseconds: 4000),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: const BorderSide(
        width: 1,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    content: Row(children: [
      Icon(
        icon,
        color: contentColor,
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Text(text))
    ]),
  ));
}

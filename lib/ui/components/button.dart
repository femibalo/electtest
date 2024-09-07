import 'package:flutter/material.dart';

MaterialButton roundedButtonAddInvoice({
  Color? buttonColor = Colors.blue,
  Color? textColor = Colors.white,
  required VoidCallback onPressed,
  required String text,
  bool isOutlineButton = false,
}) {
  return MaterialButton(
    shape: RoundedRectangleBorder(
      side: isOutlineButton
          ? const BorderSide(width: 1, color: Colors.blue)
          : BorderSide.none,
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 0,
    color: isOutlineButton ? Colors.transparent : buttonColor,
    onPressed: onPressed,
    child: Text(
      text,
    ),
  );
}

class ButtonInvoiceDetail extends StatelessWidget {
  const ButtonInvoiceDetail({
    super.key,
    required this.onTap,
    required this.iconAsset,
    required this.textButton,
  });
  final VoidCallback onTap;
  final String iconAsset;
  final String textButton;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              width: 20,
              height: 20,
              color: Colors.blue,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(textButton),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/styles/color.dart';
import 'package:mezink_app/styles/font.dart';

MaterialButton roundedButtonAddInvoice({
  Color? buttonColor = MColors.primaryBlue,
  Color? textColor = MColors.white,
  required VoidCallback onPressed,
  required String text,
  bool isOutlineButton = false,
}) {
  return MaterialButton(
    shape: RoundedRectangleBorder(
      side: isOutlineButton
          ? BorderSide(width: 1, color: MColors.primaryBlue)
          : BorderSide.none,
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 0,
    color: isOutlineButton ? Colors.transparent : buttonColor,
    textColor: isOutlineButton ? MColors.primaryBlue : textColor,
    onPressed: onPressed,
    child: Text(
      text,
      // style: Fonts.dmSans400With12PX.copyWith(
      //   fontWeight: FontWeight.w500,
      //   fontSize: 16,
      // ),
    ),
  );
}

class ButtonInvoiceDetail extends StatelessWidget {
  const ButtonInvoiceDetail({
    Key? key,
    required this.onTap,
    required this.iconAsset,
    required this.textButton,
  }) : super(key: key);
  final VoidCallback onTap;
  final String iconAsset;
  final String textButton;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
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
                color: context.primaryColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                textButton,
                style: context.getTitleMediumTextStyle(context.onSurfaceColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


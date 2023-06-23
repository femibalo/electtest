import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future showCustomAlertDialog(
    {required String title,
      String subTitle = "",
      required BuildContext context,
      String leftButtonText = "",
      Function? onLeftButtonClicked,
      required String rightButtonText,
      required Function onRightButtonClicked,
      bool disableBackButton = false}) {
  Widget leftButton = ElevatedButton(
    child: Text(leftButtonText),
    onPressed: () {
      if (onLeftButtonClicked != null) {
        onLeftButtonClicked();
      }
    },
  );

  Widget rightButton = ElevatedButton(
    child: Text(rightButtonText),
    onPressed: () {
      onRightButtonClicked();
    },
  );

  // set up the AlertDialog
  var alert = AlertDialog(
    title: Text(
      title,
    ),
    content: Text(
      subTitle,
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0))),
    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
    contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    actions: [
      if (leftButtonText.isNotEmpty) leftButton,
      if (rightButtonText.isNotEmpty) rightButton
    ],
  );

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      if (disableBackButton) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      }
      return alert;
    },
  );
}

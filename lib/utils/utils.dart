import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';


String getDate(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd', 'en')
      .format(dateTime)
      .toString();
}

String getDateddMMMyyyy(DateTime dateTime) {
  return DateFormat('dd MMM yyyy', 'en')
      .format(dateTime)
      .toString();
}

String getTimeAmPm(DateTime dateTime) {
  return DateFormat('hh:mm a', 'en').format(dateTime).toString();
}

ScrollPhysics customScrollPhysics({
  bool alwaysScroll = false,
  bool neverScroll = false,
}) {
  ScrollPhysics scrollPhysics = (Platform.isAndroid)
      ? const ClampingScrollPhysics()
      : const BouncingScrollPhysics();
  if (alwaysScroll) {
    return AlwaysScrollableScrollPhysics(parent: scrollPhysics);
  }
  if (neverScroll) {
    return const NeverScrollableScrollPhysics();
  }
  return scrollPhysics;
}
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

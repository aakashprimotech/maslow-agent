import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedTime(int seconds, int nanoseconds) {
    int milliseconds = seconds * 1000 + (nanoseconds ~/ 1000000);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat.jm().format(dateTime);
  }
}

extension ReadableFormat on DateTime {
  String toReadableFormat() {
    return DateFormat('MM-dd-yyyy').format(this);
  }
}
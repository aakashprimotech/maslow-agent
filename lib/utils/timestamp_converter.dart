import 'package:cloud_firestore/cloud_firestore.dart';
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

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();  // Convert Firebase Timestamp to Dart DateTime
  // Format date and time using intl package
  String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  return formattedDate;
}
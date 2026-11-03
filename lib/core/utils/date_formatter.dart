import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _readableDate = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) => _readableDate.format(date);
  static String formatDateTime(DateTime dateTime) => _dateTime.format(dateTime);
  static String formatTime(DateTime time) => _timeOnly.format(time);
  static String formatIso(DateTime date) => _isoDate.format(date);

  static DateTime parseIso(String isoString) => DateTime.parse(isoString);
}


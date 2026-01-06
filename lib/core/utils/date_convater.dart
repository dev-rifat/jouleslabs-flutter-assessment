import 'package:intl/intl.dart';

class DateFormatHelper {
  /// Formats a given date string into the specified format.
  /// Defaults to "dd MMM yy" if no format is provided.
  /// Returns an empty string if the input date is invalid.

  static String formatDate({required String date, String? format}) {
    if (date.isEmpty) return "";
    final String dateFormat = format ?? "dd MMMM yy";
    try {
      // Parse the input string to a DateTime object
      DateTime dateTime = DateTime.parse(date);
      // Format the DateTime object to the desired format
      return DateFormat(dateFormat).format(dateTime);
    } catch (e) {
      return "";
    }
  }
}

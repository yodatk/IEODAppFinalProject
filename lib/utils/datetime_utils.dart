import 'package:intl/intl.dart';

///
/// Format pattern for date only
///
const dateFormat = "dd/MM/yy";

///
/// Format pattern for both date and time only
///
const dateTimeFormat = "HH:mm dd.MM.yyyy";

///
/// Formatter for date only
///
final dateFormatter = DateFormat(dateFormat);

///
/// Formatter for date only
///
final dateTimeFormatter = DateFormat(dateTimeFormat);

///
/// Formatter for time only
///
final hourFormatter = DateFormat.Hm();

///
/// Convert given [dateTime] to string as date only
///
String dateToString(DateTime dateTime) => dateFormatter.format(dateTime);

///
/// Convert given [dateTime] to String as Time only
///
String dateToHourString(DateTime dateTime) => hourFormatter.format(dateTime);

///
/// Convert given [dateTime] to String as Time only
///
String dateToDateTimeString(DateTime dateTime) =>
    dateTimeFormatter.format(dateTime);

///
/// <<DEPRECATED>>
/// convert the given [toParse] date-as-String to an easier format
///
String convertVisualDateToParseDate(String toParse) {
  List<String> dateElements = toParse.split("/");
  return "20${dateElements[2]}-${dateElements[1]}-${dateElements[0]}";
}

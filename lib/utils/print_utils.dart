import '../constants/constants.dart' as Constants;

///
/// Printing given [list] with ',' delimiters between elements
///
String listToString(Iterable list) {
  return list.join(Constants.LIST_DELIMITER);
}

///
/// Converts the given [value] to [String].
/// if the give [value] is an [Iterable], will print with ',' between items
///
String toString(dynamic value) {
  return value is Iterable ? listToString(value) : value.toString();
}

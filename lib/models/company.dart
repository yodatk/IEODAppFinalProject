import 'package:flutter/foundation.dart';

///
/// All project in the app are belonging to one of two companies
///
enum Company { IMAG, IEOD }

///
/// convert a given string to a Company Enum if possible
///
Company convertStringToCompany(String toConvert) {
  return Company.values.firstWhere((e) => describeEnum(e) == toConvert,
      orElse: () => Company.IMAG);
}

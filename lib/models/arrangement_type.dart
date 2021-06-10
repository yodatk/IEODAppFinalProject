import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;

///
/// Determines the Type of arrangement
///
enum ArrangementType { DRIVE, WORK }

///
/// Converts given [toConvert] to mathing [ArrangmentType]
///
ArrangementType convertStringToStripJobType(String toConvert) {
  return ArrangementType.values.firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// Converts this given [ArrangmentType] to matching String
///
String enumToString(ArrangementType stage) {
  if (stage == ArrangementType.DRIVE) {
    return Constants.ARRANGEMENT_TYPE_DRIVE;
  } else {
    return Constants.ARRANGEMENT_TYPE_WORK;
  }
}

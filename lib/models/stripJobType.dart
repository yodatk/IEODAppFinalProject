import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;

///
/// determines the Type of hand de-mining of a [Strip]
///
enum StripJobType { UPEX, REGULAR }

///
/// Converts given [toConvert] to mathing [StripJobType]
///
StripJobType convertStringToStripJobType(String toConvert) {
  return StripJobType.values.firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// Converts this given [StripJobType] to matching String
///
String enumToString(StripJobType stage) {
  if (stage == StripJobType.UPEX) {
    return Constants.STRIP_JOB_TYPE_UPEX;
  } else {
    return Constants.STRIP_JOB_TYPE_REGULAR;
  }
}

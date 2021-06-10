import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;

///
/// Enum to describe all the available process stages a [Strip] can be in
///
enum StripStatus {
  ///
  /// No [Employee] ever worked on the [Strip]
  ///
  NONE,

  ///
  /// Some [Employee] is working currently on the first action of the [Strip]
  ///
  IN_FIRST,

  ///
  /// First action is done on the [Strip]
  ///
  FIRST_DONE,

  ///
  /// Some [Employee] is working currently on the second action of the [Strip]
  ///
  IN_SECOND,

  ///
  /// Second action is done on the [Strip]
  ///
  SECOND_DONE,

  ///
  /// Some [Employee] is working currently on the review action of the [Strip]
  ///
  IN_REVIEW,

  ///
  /// The [Strip] has been scanned three times(first, second, and review) successfully
  ///
  FINISHED
}

///
/// Converting given [toConvert] to matching [StripStatus]
///
StripStatus convertStringToStripJobStatus(String toConvert) {
  if (toConvert == null || toConvert.isEmpty) {
    return StripStatus.NONE;
  }
  return StripStatus.values.firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// Generate [String] title from given [toConvert]
///
String generateTitleFromStripStatus(StripStatus toConvert) {
  switch (toConvert) {
    case StripStatus.NONE:
      return "טרם התחיל";
    case StripStatus.IN_FIRST:
      return "בפעולה ראשונה";
    case StripStatus.FIRST_DONE:
      return "אחרי ראשונה";
    case StripStatus.IN_SECOND:
      return "בפעולה שנייה";
    case StripStatus.SECOND_DONE:
      return "אחרי שנייה";
    case StripStatus.IN_REVIEW:
      return "בתהליך ביקורת";
    case StripStatus.FINISHED:
      return "גמורים";
  }
  return "לפני ראשונה";
}

///
/// Convert given [stage] to [String]
///
String enumToString(StripStatus stage) {
  if (stage == StripStatus.NONE) {
    return Constants.STRIP_STATUS_NONE;
  } else if (stage == StripStatus.IN_FIRST) {
    return Constants.STRIP_STATUS_FIRST;
  } else if (stage == StripStatus.FIRST_DONE) {
    return Constants.STRIP_STATUS_FIRST_DONE;
  } else if (stage == StripStatus.IN_SECOND) {
    return Constants.STRIP_STATUS_SECOND;
  } else if (stage == StripStatus.SECOND_DONE) {
    return Constants.STRIP_STATUS_SECOND_DONE;
  } else if (stage == StripStatus.IN_REVIEW) {
    return Constants.STRIP_STATUS_IN_REVIEW;
  } else {
    return Constants.STRIP_STATUS_FINISHED;
  }
}

///
/// Converts a given status to an [IconData] to show
///
IconData convertStatusToIcon(StripStatus status) {
  switch (status) {
    case StripStatus.NONE:
      return Icons.do_not_step_rounded;
    case StripStatus.IN_FIRST:
      return Icons.looks_one_outlined;
    case StripStatus.FIRST_DONE:
      return Icons.looks_one;
    case StripStatus.IN_SECOND:
      return Icons.looks_two_outlined;
    case StripStatus.SECOND_DONE:
      return Icons.looks_two;
    case StripStatus.IN_REVIEW:
      return Icons.preview;
    case StripStatus.FINISHED:
      return Icons.done;

    default:
      Logger.error("should not Happen!!!");
      return Icons.do_not_step_rounded;
  }
}

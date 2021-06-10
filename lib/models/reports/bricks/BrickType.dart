import 'package:flutter/foundation.dart';

import '../../../logger.dart' as Logger;

///
/// All Available Types Of [TemplateBrick]
///
enum BrickTypeEnum {
  TEXT_BRICK,
  DATETIME_BRICK,
  ROW_BRICK,
  COLUMN_BRICK,
  TABLE_BRICK,
  CHOICE_CHIP_BRICK,
  TITLE_BRICK,
  READ_ONLY_TEXT_BRICK,
  SLIDER_BRICK,
  DROPDOWN_BRICK,
  PAGE_BRICK,
  EMPTY_BRICK,
  FUNCTION_DROPDOWN_BRICK,
}

///
/// converts given String to a [BrickTypeEnum]
///
BrickTypeEnum convertStringToBrickType(String toConvert) {
  return BrickTypeEnum.values.firstWhere((e) => describeEnum(e) == toConvert,
      orElse: () {
    Logger.error("couldn't find the given brick : $toConvert");
    return null;
  });
}

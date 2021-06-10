import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] for Text in Reports
///
class TextBrick extends TemplateBrick {
  int maxLen;
  int minLen;
  bool isRequired;
  int lines;
  bool isNumber;
  int lineLimit; // how many characters to write until separate by newline

  TextBrick(
      {String attribute,
      String decoration,
      this.maxLen,
      this.lines,
      this.minLen = 0,
      this.isNumber = false,
      this.isRequired = false,
      this.lineLimit = Constants.TEXT_DEFAULT_ROW_LIMIT,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            brickType: BrickTypeEnum.TEXT_BRICK,
            decoration: decoration,
            permissionCanEdit: permissionCanEdit) {
    if (this.lineLimit == null) {
      this.lineLimit = Constants.TEXT_DEFAULT_ROW_LIMIT;
    }
  }

  @override
  Widget acceptForm(
          {BuildContext context,
          TemplateFormBuilder builder,
          String suffix = ""}) =>
      builder.buildTextBrick(context, this, suffix);

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildTextBrick(this, "", values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_TEXT_MIN_LEN: this.minLen,
      Constants.BRICK_TEXT_MAX_LEN: this.maxLen,
      Constants.BRICK_IS_REQ: this.isRequired,
      Constants.BRICK_TEXT_LINES: this.lines,
      Constants.BRICK_TEXT_IS_INPUT_TYPE_NUMBER: this.isNumber,
      Constants.BRICK_TEXT_LINE_LIMIT: this.lineLimit,
    };
  }

  @override
  TextBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.minLen = data[Constants.BRICK_TEXT_MIN_LEN] as int ?? 0;
    this.maxLen = data[Constants.BRICK_TEXT_MAX_LEN] as int;
    this.isRequired = data[Constants.BRICK_IS_REQ] as bool ?? false;
    this.lines = data[Constants.BRICK_TEXT_LINES] as int;
    this.isNumber =
        data[Constants.BRICK_TEXT_IS_INPUT_TYPE_NUMBER] as bool ?? false;
    this.lineLimit = (data[Constants.BRICK_TEXT_LINE_LIMIT] ??
        Constants.TEXT_DEFAULT_ROW_LIMIT) as int;
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return builder.getTextStringValue(values, this, suffix,
        rowLimit: this.lineLimit);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import '../templates/FunctionResolver.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to build a read only value in a report in a dynamic way
///
class ReadOnlyTextBrick extends TemplateBrick {
  int maxLen;

  String text;
  SingleResolvedEntityEnum singleEntityEnum;
  String fieldName;

  ReadOnlyTextBrick({
    String attribute,
    String decoration,
    this.singleEntityEnum,
    this.fieldName,
    this.text,
    this.maxLen = 240,
  }) : super(
            attribute: attribute,
            brickType: BrickTypeEnum.READ_ONLY_TEXT_BRICK,
            decoration: decoration,
            permissionCanEdit: Permission.REGULAR);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix = ""}) {
    return builder.buildReadOnlyTextBrick(context, this, suffix);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildReadOnlyTextBrick(this, suffix, values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_TEXT_MAX_LEN: this.maxLen,
      Constants.BRICK_READ_ONLY_TEXT: this.text,
      Constants.ENTITY_SOURCE_ENUM: describeEnum(this.singleEntityEnum),
      Constants.FIELD_NAME: this.fieldName,
      Constants.PERMISSION_CAN_EDIT: describeEnum(this.permissionCanEdit),
    };
  }

  @override
  ReadOnlyTextBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.maxLen = data[Constants.BRICK_TEXT_MAX_LEN] as int ?? 240;
    this.text = data[Constants.BRICK_READ_ONLY_TEXT] as String ?? "";
    this.singleEntityEnum = convertSingleResolvedEntityEnum(
        data[Constants.ENTITY_SOURCE_ENUM] as String);
    this.fieldName = data[Constants.FIELD_NAME] as String ?? "";
    this.permissionCanEdit = convertStringToPermission(
        data[Constants.PERMISSION_CAN_EDIT] as String);
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return builder.getTextStringValue(
      values,
      this,
      suffix,
      rowLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
    );
  }
}

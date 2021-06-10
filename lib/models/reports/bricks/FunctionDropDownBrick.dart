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
/// [TemplateBrick] to add multiple choice dynamically to a report according to a given [ResolvedEntityListEnum]
///
class FunctionDropDownBrick extends TemplateBrick {
  List<String> choices;
  bool isRequired;
  ResolvedEntityListEnum listEntityEnum;
  String fieldName;

  FunctionDropDownBrick({
    String attribute,
    String decoration,
    this.listEntityEnum,
    this.fieldName,
    this.isRequired = false,
    Permission permissionCanEdit = Permission.REGULAR,
  }) : super(
            attribute: attribute,
            brickType: BrickTypeEnum.FUNCTION_DROPDOWN_BRICK,
            decoration: decoration,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix = ""}) {
    return builder.buildFunctionDropDownBrick(context, this, suffix);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildFunctionDropDownBrick(this, "", values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_IS_REQ: this.isRequired,
      Constants.PERMISSION_CAN_EDIT: describeEnum(this.permissionCanEdit),
      Constants.DROPDOWN_ENTITY_SOURCE_ENUM: describeEnum(this.listEntityEnum),
      Constants.DROPDOWN_FIELD_NAME: this.fieldName,
    };
  }

  @override
  FunctionDropDownBrick.fromJson(Map<String, dynamic> data)
      : super.fromMap(data) {
    this.listEntityEnum = convertResolvedEntityListEnum(
        data[Constants.DROPDOWN_ENTITY_SOURCE_ENUM] as String);
    this.fieldName = data[Constants.DROPDOWN_FIELD_NAME] as String ?? "";
    this.isRequired = data[Constants.BRICK_IS_REQ] as bool ?? false;
    this.permissionCanEdit = convertStringToPermission(
            data[Constants.PERMISSION_CAN_EDIT] as String) ??
        Permission.REGULAR;
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

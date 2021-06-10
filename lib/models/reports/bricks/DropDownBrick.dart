import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] with finite  and known number of options to choose from in a template
///
class DropDownBrick extends TemplateBrick {
  List<String> choices;
  bool isRequired;

  DropDownBrick({
    String attribute,
    String decoration,
    this.choices,
    this.isRequired = false,
    Permission permissionCanEdit = Permission.REGULAR,
  }) : super(
            attribute: attribute,
            brickType: BrickTypeEnum.DROPDOWN_BRICK,
            decoration: decoration,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix = ""}) {
    return builder.buildDropDownBrick(context, this, suffix);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildDropDownBrick(this, "", values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_DROPDOWN_CHOICES: this.choices,
      Constants.BRICK_IS_REQ: this.isRequired,
      Constants.PERMISSION_CAN_EDIT: describeEnum(this.permissionCanEdit),
    };
  }

  @override
  DropDownBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    if (data[Constants.BRICK_DROPDOWN_CHOICES] == null) {
      this.choices = [];
    } else {
      final temp = data[Constants.BRICK_DROPDOWN_CHOICES] as List<dynamic> ??
          <dynamic>[];
      this.choices = temp.cast<String>();
    }

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
    return builder.getTextStringValue(values, this, suffix,
        rowLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT);
  }
}

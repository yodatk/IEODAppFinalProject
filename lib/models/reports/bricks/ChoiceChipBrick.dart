import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to get input by choosing chips. good for finite and known options
///
class ChoiceChipBrick extends TemplateBrick {
  List<String> choices;
  bool isRequired;

  ChoiceChipBrick({
    String attribute,
    String decoration,
    this.choices,
    this.isRequired = false,
    Permission permissionCanEdit = Permission.REGULAR,
  }) : super(
            attribute: attribute,
            brickType: BrickTypeEnum.CHOICE_CHIP_BRICK,
            decoration: decoration,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix = ""}) {
    return builder.buildChoiceChipBrick(context, this, suffix);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildChoiceChipBrick(this, suffix, values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_CHIP_CHOICES: this.choices,
      Constants.BRICK_IS_REQ: this.isRequired,
    };
  }

  @override
  ChoiceChipBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.choices = data[Constants.BRICK_CHIP_CHOICES] == null
        ? <String>[]
        : (data[Constants.BRICK_CHIP_CHOICES].cast<String>() as List<String>);
    this.isRequired = data[Constants.BRICK_IS_REQ] as bool ?? false;
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return builder.getListStringValue(values, this, suffix);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// Enum for Title Size
///
enum TitleSizeEnum {
  HEADLINE_1,
  HEADLINE_2,
  HEADLINE_3,
  HEADLINE_4,
  HEADLINE_5,
  HEADLINE_6,
}

///
/// converts a given string to a [TitleSizeEnum]
///
TitleSizeEnum convertStringToTitleSize(String toConvert) {
  return TitleSizeEnum.values.firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// [TemplateBrick] for title in reports
///
class TitleBrick extends TemplateBrick {
  String text;
  TitleSizeEnum titleSize;

  TitleBrick(
      {String attribute,
      this.text,
      this.titleSize = TitleSizeEnum.HEADLINE_3,
      children,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            brickType: BrickTypeEnum.TITLE_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
          {BuildContext context, TemplateFormBuilder builder, String suffix}) =>
      builder.buildTitleBrick(context, this);

  @override
  dynamic acceptOutput(
          {OutputBuilder builder,
          Map<String, dynamic> values,
          String suffix = ""}) =>
      builder.buildTitleBrick(this);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.TITLE_BRICK_TEXT: this.text,
      Constants.TITLE_BRICK_SIZE: describeEnum(this.titleSize),
    };
  }

  @override
  TitleBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.text = data[Constants.TITLE_BRICK_TEXT] as String ?? '';
    this.titleSize =
        convertStringToTitleSize(data[Constants.TITLE_BRICK_SIZE] as String) ??
            TitleSizeEnum.HEADLINE_6;
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return builder.getTitleStringValue(values, this, suffix);
  }
}

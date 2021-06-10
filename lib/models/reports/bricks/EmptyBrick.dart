import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// Empty Brick to add between other [TemplateBrick] in Templates
///
class EmptyBrick extends TemplateBrick {
  double height;

  EmptyBrick(
      {String attribute,
      this.height = 20.0,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            brickType: BrickTypeEnum.EMPTY_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
          {BuildContext context, TemplateFormBuilder builder, String suffix}) =>
      builder.buildEmptyBrick(context, this);

  @override
  dynamic acceptOutput(
          {OutputBuilder builder,
          Map<String, dynamic> values,
          String suffix = ""}) =>
      builder.buildEmptyBrick(this);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.EMPTY_BRICK_LINES: this.height,
    };
  }

  @override
  EmptyBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.height = data[Constants.EMPTY_BRICK_LINES] != null
        ? (data[Constants.EMPTY_BRICK_LINES] as num).toDouble()
        : 20.0;
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    throw UnimplementedError();
  }
}

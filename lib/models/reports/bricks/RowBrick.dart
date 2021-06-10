import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'parentBrick.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to build a row layout in a Report
///
class RowBrick extends ParentBrick {
  RowBrick(
      {String attribute,
      List<TemplateBrick> children,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            children: children,
            brickType: BrickTypeEnum.ROW_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
          {BuildContext context, TemplateFormBuilder builder, String suffix}) =>
      builder.buildRowBrick(context, this);

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildRowBrick(this, values);

  @override
  RowBrick.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return children
        .map((e) =>
            e.getStringValue(values: values, builder: builder, suffix: suffix))
        .join(Constants.LIST_DELIMITER);
  }
}

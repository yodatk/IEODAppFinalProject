import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'parentBrick.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to order other [TemplateBrick] in vertical way
///
class ColumnBrick extends ParentBrick {
  ColumnBrick(
      {String attribute,
      List<TemplateBrick> children,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            children: children,
            brickType: BrickTypeEnum.COLUMN_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix}) {
    return builder.buildColumnBrick(context, this);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildColumnBrick(this, values);

  ColumnBrick.fromJson(Map<String, dynamic> data) : super.fromJson(data);

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

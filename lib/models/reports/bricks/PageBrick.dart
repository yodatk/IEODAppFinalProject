import 'package:flutter/widgets.dart';

import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// Special Brick to add a page break in Reports
///
class PageBrick extends TemplateBrick {
  PageBrick(
      {String attribute,
      List<TemplateBrick> children,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            brickType: BrickTypeEnum.PAGE_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix}) {
    return builder.buildPageBrick(context, this);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildPageBrick(this, values);

  @override
  PageBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data);

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    throw UnimplementedError();
  }
}

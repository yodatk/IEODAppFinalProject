import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../exceptions/illegal_call_exception.dart';
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'parentBrick.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to build a Table in a Report
///
class TableBrick extends ParentBrick {
  int rowCount;
  bool showColumnNames;

  TableBrick(
      {String attribute,
      this.rowCount = 5,
      this.showColumnNames = true,
      List<TemplateBrick> children,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            children: children,
            brickType: BrickTypeEnum.TABLE_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix}) {
    return builder.buildTableBrick(context, this);
  }

  @override
  dynamic acceptOutput(
          {OutputBuilder builder,
          Map<String, dynamic> values,
          String suffix = ""}) =>
      builder.buildTableBrick(this, values);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.TABLE_BRICK_ROW_COUNT: this.rowCount,
      Constants.TABLE_BRICK_SHOW_COLUMNS: this.showColumnNames,
    };
  }

  TableBrick clone() {
    return TableBrick(
        attribute: this.attribute,
        rowCount: this.rowCount,
        showColumnNames: this.showColumnNames,
        children: this.children,
        permissionCanEdit: this.permissionCanEdit);
  }

  @override
  TableBrick.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    this.rowCount = data[Constants.TABLE_BRICK_ROW_COUNT] as int ?? 5;
    this.showColumnNames =
        data[Constants.TABLE_BRICK_SHOW_COLUMNS] as bool ?? true;
  }

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    throw IllegalCallException("TableBrick.getStringValue");
  }
}

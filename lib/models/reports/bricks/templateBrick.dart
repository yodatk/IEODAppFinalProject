import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/acceptFormBuilders.dart';
import '../builders/acceptOutputBuilders.dart';
import 'BrickType.dart';
import 'ChoiceChipBrick.dart';
import 'ColumnBrick.dart';
import 'DateTimeBrick.dart';
import 'DropDownBrick.dart';
import 'EmptyBrick.dart';
import 'FunctionDropDownBrick.dart';
import 'PageBrick.dart';
import 'ReadOnlyTextBrick.dart';
import 'RowBrick.dart';
import 'TableBrick.dart';
import 'TextBrick.dart';
import 'TitleBrick.dart';

///
/// Part of the "BRICK WALL" pattern - a single brick to build a [Template] from
///
abstract class TemplateBrick
    implements AcceptFormBuilders, AcceptOutputBuilders {
  String attribute;
  String decoration;
  BrickTypeEnum brickType;
  Permission permissionCanEdit;

  TemplateBrick(
      {this.attribute,
      this.brickType,
      this.decoration,
      this.permissionCanEdit = Permission.REGULAR}) {
    this.decoration = this.decoration ?? this.attribute;
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.TEMPLATE_BRICK_ATTR: this.attribute,
      Constants.TEMPLATE_BRICK_TYPE: describeEnum(this.brickType),
      Constants.TEMPLATE_BRICK_DECORATION: this.decoration,
      Constants.PERMISSION_CAN_EDIT: describeEnum(this.permissionCanEdit)
    };
  }

  factory TemplateBrick.fromJson(Map<String, dynamic> data) {
    BrickTypeEnum type =
        convertStringToBrickType(data[Constants.TEMPLATE_BRICK_TYPE] as String);
    switch (type) {
      case BrickTypeEnum.TEXT_BRICK:
        return TextBrick.fromJson(data);
      case BrickTypeEnum.DATETIME_BRICK:
        return DateTimeBrick.fromJson(data);
      case BrickTypeEnum.ROW_BRICK:
        return RowBrick.fromJson(data);
      case BrickTypeEnum.COLUMN_BRICK:
        return ColumnBrick.fromJson(data);
      case BrickTypeEnum.TABLE_BRICK:
        return TableBrick.fromJson(data);
      case BrickTypeEnum.CHOICE_CHIP_BRICK:
        return ChoiceChipBrick.fromJson(data);
      case BrickTypeEnum.TITLE_BRICK:
        return TitleBrick.fromJson(data);
      case BrickTypeEnum.READ_ONLY_TEXT_BRICK:
        return ReadOnlyTextBrick.fromJson(data);
      case BrickTypeEnum.DROPDOWN_BRICK:
        return DropDownBrick.fromJson(data);
      case BrickTypeEnum.PAGE_BRICK:
        return PageBrick.fromJson(data);
      case BrickTypeEnum.EMPTY_BRICK:
        return EmptyBrick.fromJson(data);
      case BrickTypeEnum.FUNCTION_DROPDOWN_BRICK:
        return FunctionDropDownBrick.fromJson(data);
      default:
        return null;
    }
  }

  TemplateBrick.fromMap(Map<String, dynamic> data) {
    this.attribute = data[Constants.TEMPLATE_BRICK_ATTR] as String ?? "";
    this.decoration = data[Constants.TEMPLATE_BRICK_DECORATION] as String ?? "";
    this.brickType = convertStringToBrickType(
        data[Constants.TEMPLATE_BRICK_TYPE]
            as String); //Checked before that not null
    this.permissionCanEdit = convertStringToPermission(
            data[Constants.PERMISSION_CAN_EDIT] as String) ??
        Permission.REGULAR;
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/outputBuilder.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// [TemplateBrick] to collect DateTime data in a Report
///
class DateTimeBrick extends TemplateBrick {
  DateTime maxDateTime;
  DateTime minDateTime;
  InputType input;
  bool isRequired;
  double width;

  DateTimeBrick(
      {String attribute,
      String decoration,
      Permission permissionCanEdit = Permission.REGULAR,
      this.maxDateTime,
      this.minDateTime,
      this.input = InputType.both,
      this.width = 5.0,
      this.isRequired = false})
      : super(
            attribute: attribute,
            decoration: decoration,
            brickType: BrickTypeEnum.DATETIME_BRICK,
            permissionCanEdit: permissionCanEdit);

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix = ""}) {
    return builder.buildDateBrick(context, this, suffix);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.buildDateBrick(values, this, suffix);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.BRICK_MIN_DATETIME: this.minDateTime == null
          ? this.minDateTime
          : this.minDateTime.millisecondsSinceEpoch,
      Constants.BRICK_MAX_DATETIME: this.maxDateTime == null
          ? this.maxDateTime
          : this.maxDateTime.millisecondsSinceEpoch,
      Constants.BRICK_DATETIME_INPUT_TYPE: this.input.toString(),
      Constants.BRICK_IS_REQ: this.isRequired,
      Constants.DATE_TIME_WIDTH: this.width,
    };
  }

  @override
  DateTimeBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.minDateTime = data[Constants.BRICK_MIN_DATETIME] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            data[Constants.BRICK_MIN_DATETIME] as int)
        : null;
    this.maxDateTime = data[Constants.BRICK_MAX_DATETIME] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            data[Constants.BRICK_MAX_DATETIME] as int)
        : null;
    this.isRequired = data[Constants.BRICK_IS_REQ] as bool ?? false;
    this.width = data[Constants.DATE_TIME_WIDTH] != null
        ? (data[Constants.DATE_TIME_WIDTH] as num).toDouble()
        : 5.0;
    if (data[Constants.BRICK_DATETIME_INPUT_TYPE] != null)
      this.input = convertStringToInputType(
          data[Constants.BRICK_DATETIME_INPUT_TYPE] as String);
    else
      this.input = InputType.both;
  }

  InputType convertStringToInputType(String toConvert) {
    switch (toConvert) {
      case "InputType.time":
        return InputType.time;
      case "InputType.date":
        return InputType.date;
      case "InputType.both":
        return InputType.both;
      default:
        return null;
    }
    // TODO: change to describeEnum
    // return InputType.values.firstWhere((e) => describeEnum(e) == toConvert,
    //                                    orElse: null);
  }

  // TODO: change to describeEnum
  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return builder.getMilliDateStringValue(values, this, suffix);
  }
}

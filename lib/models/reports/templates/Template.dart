import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/constants.dart' as Constants;
import '../../entity.dart';
import '../bricks/templateBrick.dart';
import '../builders/TemplateFormBuilder.dart';
import '../builders/acceptFormBuilders.dart';

///
/// enum to represents all the possible report types in a project
///
enum TemplateTypeEnum {
  Mechanical, // deprecated for now
  GeneralMechanical,
  QualityControlForMechanical,
  QualityControlForManual,
  EmergencyPracticeDocumentation,
  BunkersClearance,
  DailyClearance,
  DeepTarget,
} // Must be identical to firebase constants

///
/// converts given [toConvert] to matching [TemplateTypeEnum] enum.
///
TemplateTypeEnum convertStringToTemplateTypeEnum(String toConvert) {
  return TemplateTypeEnum.values
      .firstWhere((e) => describeEnum(e) == toConvert);
}

class Template extends Entity implements AcceptFormBuilders {
  String name;
  TemplateTypeEnum templateType;
  List<TemplateBrick> templateBricks;

  Template(
      {String id = "", this.name = "", this.templateType, this.templateBricks})
      : super(
            id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  @override
  Widget acceptForm(
      {BuildContext context, TemplateFormBuilder builder, String suffix}) {
    return builder.buildForm(context, this);
  }

  @override
  String toString() {
    return name;
  }

  Template.copy(Template other) : super.copy(other) {
    this.name = other.name;
    this.templateBricks = other.templateBricks;
  }

  Template.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.TEMPLATE_NAME] as String ?? "";
    if (data[Constants.TEMPLATE_BRICKS] == null) {
      this.templateBricks = new List<TemplateBrick>();
    } else {
      this.templateBricks = <TemplateBrick>[];
      for (dynamic brickData
          in (data[Constants.TEMPLATE_BRICKS] as List<dynamic>)) {
        this
            .templateBricks
            .add(TemplateBrick.fromJson(brickData as Map<String, dynamic>));
      }
    }
    this.templateType = data[Constants.TEMPLATE_TYPE] != null
        ? convertStringToTemplateType(data[Constants.TEMPLATE_TYPE] as String)
        : null;
  }

  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.TEMPLATE_NAME: this.name,
      Constants.TEMPLATE_TYPE: describeEnum(this.templateType),
      Constants.TEMPLATE_BRICKS:
          this.templateBricks.map((brick) => brick.toMap()).toList(),
    };
  }

  @override
  Entity clone() {
    return Template.copy(this);
  }

  TemplateTypeEnum convertStringToTemplateType(String toConvert) {
    return TemplateTypeEnum.values
        .firstWhere((e) => describeEnum(e) == toConvert);
  }

  @override
  bool validateMustFields() =>
      name != null &&
      name.isNotEmpty &&
      templateType != null &&
      templateBricks != null;
}

import 'package:IEODApp/constants/ExampleTemplates.dart';
import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/reports/templates/Template.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

import '../utils/ReportTemplateUtils.dart';
import '../utils/entityUtils.dart';

void main() {
  runTemplateTests();
}

void runTemplateTests() {
  group('Template test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = buildMechTemplate();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.name, json[Constants.TEMPLATE_NAME]);
      expect(toCheck.templateBricks.map((e) => e.toMap()).toList(),
          json[Constants.TEMPLATE_BRICKS]);
      expect(describeEnum(toCheck.templateType), json[Constants.TEMPLATE_TYPE]);
    });

    // /// checks that the object is created properly from valid dictionary
    // test('fromJson', () {
    //   final json = buildMechTemplate().toJson();
    //   Template toCheck = Template.fromJson(id: faker.guid.guid(), data: json);
    //   toJsonEntityCheck(json, toCheck);
    //
    //   expect(toCheck.name, json[Constants.TEMPLATE_NAME]);
    //   expect(toCheck.templateBricks.map((e) => e.toMap()).toList(),
    //       json[Constants.TEMPLATE_BRICKS]);
    //   expect(describeEnum(toCheck.templateType), json[Constants.TEMPLATE_TYPE]);
    // }, skip: "need to check null fields in templates");

    test('clone', () {
      final toCheck = buildMechTemplate();
      final cloned = toCheck.clone() as Template;
      compareTwoTemplates(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = buildMechTemplate();
      final cloned = Template.copy(toCheck);
      compareTwoTemplates(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = buildMechTemplate();
      expect(toCheck.validateMustFields(), true);
      toCheck.templateBricks = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.templateBricks = buildMechTemplate().templateBricks;
      expect(toCheck.validateMustFields(), true);
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "hey";
      expect(toCheck.validateMustFields(), true);
    });
  });
}

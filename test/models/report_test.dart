import 'package:IEODApp/constants/ExampleTemplates.dart';
import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/reports/Report.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/ReportTemplateUtils.dart';
import '../utils/employeeUtils.dart';
import '../utils/entityUtils.dart';

void main() {
  runReportTests();
}

void runReportTests() {
  group('Report test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomReport();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.name, json[Constants.REPORT_NAME]);
      expect(toCheck.template, json[Constants.REPORT_TEMPLATE]);
      expect(toCheck.creator.toJson(), json[Constants.REPORT_CREATOR]);
      expect(toCheck.lastEditor.toJson(), json[Constants.REPORT_LAST_EDITOR]);
      expect(toCheck.attributeValues, json[Constants.REPORT_ATTR]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final json = {
        Constants.REPORT_NAME: faker.guid.guid(),
        Constants.REPORT_TEMPLATE: buildMechTemplate(),
        Constants.REPORT_CREATOR: generateLastEditor().toJson(),
        Constants.REPORT_LAST_EDITOR: generateLastEditor().toJson(),
        Constants.REPORT_ATTR: Map<String, dynamic>(),
        ...toJsonEntity(),
      };
      Report toCheck = Report.fromJson(id: faker.guid.guid(), data: json);
      toJsonEntityCheck(json, toCheck);
      expect(toCheck.name, json[Constants.REPORT_NAME]);
      expect(toCheck.template, json[Constants.REPORT_TEMPLATE]);
      expect(toCheck.creator.toJson(), json[Constants.REPORT_CREATOR]);
      expect(toCheck.lastEditor.toJson(), json[Constants.REPORT_LAST_EDITOR]);
      expect(toCheck.attributeValues, json[Constants.REPORT_ATTR]);
    });

    test('clone', () {
      final toCheck = generateRandomReport();
      final cloned = toCheck.clone() as Report;
      compareTwoReports(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomReport();
      final cloned = Report.copy(toCheck);
      compareTwoReports(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomReport();
      expect(toCheck.validateMustFields(), true);
      toCheck.attributeValues = null;
      expect(toCheck.validateMustFields(), false);
    });
  });
}

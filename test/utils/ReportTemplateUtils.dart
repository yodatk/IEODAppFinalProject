import 'dart:math';

import 'package:IEODApp/constants/ExampleTemplates.dart';
import 'package:IEODApp/models/reports/Report.dart';
import 'package:IEODApp/models/reports/templates/Template.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'employeeUtils.dart';
import 'entityUtils.dart';

const MECH_TEMP_ID = "aVuiDSJQSxVLc6sllA1C";

final rnd = Random();

Report generateRandomReport() {
  Template t = buildGeneralMechTemplate();
  final toCheck = Report(
    id: faker.guid.guid(),
    name: faker.company.name(),
    template: t,
    creator: generateLastEditor(),
    lastEditor: generateLastEditor(),
  );
  toCheck.template.id = MECH_TEMP_ID;
  return toCheck;
}

void compareTwoTemplates(Template a, Template b) {
  expect(a.name, b.name);
  compareTwoEntities(a, b);
}

void compareTwoReports(Report a, Report b) {
  expect(a.name, b.name);
  expect(
      DeepCollectionEquality.unordered()
          .equals(a.attributeValues, b.attributeValues),
      true);
  expect(a.lastEditor, b.lastEditor);
  expect(a.creator, b.creator);
  compareTwoEntities(a, b);
}

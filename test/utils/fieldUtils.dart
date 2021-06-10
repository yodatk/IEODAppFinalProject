import 'dart:math';

import 'package:IEODApp/models/all_models.dart';
import 'package:IEODApp/models/plot.dart';
import 'package:IEODApp/models/site.dart';
import 'package:IEODApp/models/strip.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'entityUtils.dart';

final rnd = Random();

Site generateRandomSite() =>
    Site(id: faker.guid.guid(), name: faker.company.name());

Plot generateRandomPlot() => Plot(
    id: faker.guid.guid(),
    name: faker.company.name(),
    siteId: faker.guid.guid());

Strip generateRandomStrip({
  String plotId,
  EmployeeForDocs emp1,
  EmployeeForDocs emp2,
  EmployeeForDocs emp3,
}) {
  final strip = Strip(
    id: faker.guid.guid(),
    name: faker.person.firstName(),
    plotId: plotId ?? faker.guid.guid(),
    mineCount: rnd.nextInt(10),
    depthTargetCount: rnd.nextInt(10),
    notes: faker.lorem.sentence(),
  );
  if (rnd.nextBool()) {
    strip.first = StripJob(
        employeeId: emp1?.id ?? faker.guid.guid(),
        employeeName: emp1?.name ?? faker.person.name(),
        lastModifiedDate: DateTime.now());
    if (rnd.nextBool()) {
      strip.first.isDone = true;
      if (rnd.nextBool()) {
        strip.second = StripJob(
            employeeId: emp2?.id ?? faker.guid.guid(),
            employeeName: emp2?.name ?? faker.person.name(),
            lastModifiedDate: DateTime.now());
        if (rnd.nextBool()) {
          strip.second.isDone = true;
          if (rnd.nextBool()) {
            strip.third = StripJob(
                employeeId: emp2?.id ?? faker.guid.guid(),
                employeeName: emp2?.name ?? faker.person.name(),
                lastModifiedDate: DateTime.now());
            if (rnd.nextBool()) {
              strip.third.isDone = true;
            }
          }
        }
      }
    }
  }
  return strip;
}

void compareTwoStrips(Strip a, Strip b) {
  expect(a.first, b.first);
  expect(a.second, b.second);
  expect(a.third, b.third);
  expect(a.name, b.name);
  expect(a.plotId, b.plotId);
  expect(a.depthTargetCount, b.depthTargetCount);
  expect(a.mineCount, b.mineCount);
  expect(a.notes, b.notes);
  compareTwoEntities(a, b);
}

void compareTwoSites(Site a, Site b) {
  expect(a.name, b.name);
  compareTwoEntities(a, b);
}

void compareTwoPlot(Plot a, Plot b) {
  expect(a.name, b.name);
  expect(a.siteId, b.siteId);
  compareTwoEntities(a, b);
}

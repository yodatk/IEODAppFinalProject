import 'dart:math';

import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/arrangement.dart';
import 'package:IEODApp/models/drive_arrangement.dart';
import 'package:IEODApp/models/vehicle.dart';
import 'package:IEODApp/models/work_arrangement.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'entityUtils.dart';

final rnd = Random();

Vehicle generateRandomVehicle() => Vehicle(
        id: faker.guid.guid(),
        model: faker.company.name(),
        driver: faker.person.name(),
        destination: faker.address.city(),
        passengers: [
          faker.person.name(),
          faker.person.name(),
          faker.person.name(),
        ]);

Map<String, Vehicle> generateRandomVehicles() {
  final vh = [
    generateRandomVehicle(),
    generateRandomVehicle(),
    generateRandomVehicle(),
  ];
  final vehicles = Map<String, Vehicle>();
  vh.forEach((element) {
    vehicles[element.model] = element;
  });
  return vehicles;
}

DriveArrangement generateRandomDriveArrangement() {
  return DriveArrangement(
    id: faker.guid.guid(),
    date: DateTime.now(),
    freeTextInfo: faker.lorem.sentence(),
    lastEditor: EmployeeForDocs(faker.person.name(), faker.guid.guid()),
  );
}

WorkArrangement generateRandomWorkArrangement() => WorkArrangement(
      id: faker.guid.guid(),
      date: DateTime.now(),
      freeTextInfo: faker.lorem.sentence(),
      lastEditor: EmployeeForDocs(faker.person.name(), faker.guid.guid()),
    );

void compareTwoArrangements(Arrangement a, Arrangement b) {
  expect(a.date, b.date);
  expect(a.lastEditor, b.lastEditor);
  expect(a.freeTextInfo, b.freeTextInfo);
  compareTwoEntities(a, b);
}

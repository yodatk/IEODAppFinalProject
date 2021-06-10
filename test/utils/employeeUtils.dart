import 'dart:math';

import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/permission.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/init_tests.dart';

final rnd = Random();

Employee generateRandomEmployee() => Employee(
    id: faker.guid.guid(),
    email: faker.internet.email(),
    name: faker.person.name(),
    phoneNumber: randomPhoneNumber(),
    permission: randomPermission(),
    isHandWorker: rnd.nextBool());

EmployeeForDocs generateLastEditor() =>
    EmployeeForDocs(faker.person.name(), faker.guid.guid());

void compareTwoEmployees(Employee a, Employee b) {
  expect(a.projects.containsAll(b.projects), true);
  expect(b.projects.containsAll(a.projects), true);

  expect(a.email, b.email);
  expect(a.name, b.name);
  expect(a.timeCreated, b.timeCreated);
  expect(a.timeModified, b.timeModified);
  expect(a.phoneNumber, b.phoneNumber);
  expect(a.permission, b.permission);
  expect(a.imageUrl, b.imageUrl);
  expect(a.isHandWorker, b.isHandWorker);
  expect(a.id, b.id);
}

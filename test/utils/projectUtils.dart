import 'dart:math';

import 'package:IEODApp/models/project.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

final rnd = Random();
const PROJECTS_NAMES = ["test_project","test_project2","test_project3"];
Project generateRandomProject() {
  final managerId = faker.person.name();
  return Project(
    id: faker.guid.guid(),
    name: faker.company.name(),
    isActive: rnd.nextBool(),
    employees: {managerId, faker.person.name()},
    projectManagerId: managerId,
  );
}

void compareTwoProjects(Project a, Project b) {
  expect(a.name, b.name);
  expect(a.timeCreated, b.timeCreated);
  expect(a.timeModified, b.timeModified);
  expect(a.employees.containsAll(b.employees), true);
  expect(b.employees.containsAll(a.employees), true);
  expect(a.isActive, b.isActive);
  expect(a.projectManagerId, b.projectManagerId);
  expect(a.imageUrl, b.imageUrl);
  expect(a.employer, b.employer);
  expect(a.id, b.id);
}

String getRandomProjectName() => PROJECTS_NAMES[rnd.nextInt(PROJECTS_NAMES.length)];

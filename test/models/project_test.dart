import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/company.dart' as company;
import 'package:IEODApp/models/project.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

import '../utils/entityUtils.dart';
import '../utils/projectUtils.dart';

void main() {
  runProjectTests();
}

void runProjectTests() {
  group('Project test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomProject();
      final json = toCheck.toJson();
      expect(json.keys.length, 8);
      expect(json[Constants.PROJECT_NAME], toCheck.name);
      expect(json[Constants.PROJECT_EMPLOYER], describeEnum(toCheck.employer));
      expect(json[Constants.PROJECT_MANAGER_ID], toCheck.projectManagerId);
      expect(json[Constants.PROJECT_IS_ACTIVE], toCheck.isActive);
      expect(json[Constants.PROJECT_IMAGE_URL], toCheck.imageUrl);

      expect(
          (json[Constants.PROJECT_EMPLOYEES] as List<String>)
              .toSet()
              .containsAll(toCheck.employees),
          true);
      expect(
          toCheck.employees.containsAll(
              (json[Constants.PROJECT_EMPLOYEES] as List<String>).toSet()),
          true);
      toJsonEntityCheck(json, toCheck);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final now = DateTime.now();
      final manager = faker.person.name();
      final json = {
        Constants.PROJECT_MANAGER_ID: manager,
        Constants.PROJECT_NAME: faker.company.name(),
        Constants.PROJECT_IMAGE_URL: 'url',
        Constants.PROJECT_IS_ACTIVE: rnd.nextBool(),
        Constants.PROJECT_EMPLOYEES: [manager, faker.person.name()],
        Constants.ENTITY_CREATED: now.millisecondsSinceEpoch,
        Constants.ENTITY_MODIFIED: now.millisecondsSinceEpoch,
        Constants.PROJECT_EMPLOYER: describeEnum(company.Company.IMAG),
      };
      final toCheck = Project.fromJson(id: "", data: json);
      expect(toCheck.name, json[Constants.PROJECT_NAME]);
      expect(toCheck.projectManagerId, json[Constants.PROJECT_MANAGER_ID]);
      expect(toCheck.isActive, json[Constants.PROJECT_IS_ACTIVE]);
      expect(toCheck.imageUrl, json[Constants.PROJECT_IMAGE_URL]);
      expect(describeEnum(toCheck.employer), json[Constants.PROJECT_EMPLOYER]);

      expect(
          (json[Constants.PROJECT_EMPLOYEES] as List<String>)
              .toSet()
              .containsAll(toCheck.employees),
          true);
      expect(
          toCheck.employees.containsAll(
              (json[Constants.PROJECT_EMPLOYEES] as List<String>).toSet()),
          true);

      fromJsonEntityCheck(json, toCheck);
    });

    test('clone', () {
      final toCheck = generateRandomProject();
      final cloned = toCheck.clone() as Project;
      compareTwoProjects(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomProject();

      final cloned = Project.copy(toCheck);
      compareTwoProjects(toCheck, cloned);
    });

    test('isWithImage', () {
      final toCheck = generateRandomProject();
      toCheck.imageUrl = null;
      expect(toCheck.isWithImage(), false);
      toCheck.imageUrl = "";
      expect(toCheck.isWithImage(), false);
      toCheck.imageUrl = "hey";
      expect(toCheck.isWithImage(), true);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomProject();
      expect(toCheck.validateMustFields(), true);
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "hey";
      final managerHolder = toCheck.projectManagerId;
      toCheck.projectManagerId = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.projectManagerId = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.projectManagerId = "you";
      expect(toCheck.validateMustFields(), false);
      toCheck.projectManagerId = managerHolder;
      toCheck.employees = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.employees = Set<String>();
      expect(toCheck.validateMustFields(), false);
      toCheck.employees.add("dude");
      expect(toCheck.validateMustFields(), false);
      toCheck.employees.remove("dude");
      toCheck.employees.add(managerHolder);
      expect(toCheck.validateMustFields(), true);
      toCheck.isActive = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.isActive = true;
      expect(toCheck.validateMustFields(), true);
    });
  });
}

import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/all_models.dart';
import 'package:IEODApp/models/permission.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

import '../utils/employeeUtils.dart';
import '../utils/entityUtils.dart';
import '../utils/init_tests.dart';

void main() {
  runEmployeeTests();
}

void runEmployeeTests() {
  group('Employee test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomEmployee();
      final json = toCheck.toJson();
      expect(json.keys.length, 9);

      expect(json[Constants.EMPLOYEE_EMAIL], toCheck.email);
      expect(json[Constants.EMPLOYEE_NAME], toCheck.name);
      expect(json[Constants.EMPLOYEE_PERMISSION],
          describeEnum(toCheck.permission));
      expect(json[Constants.EMPLOYEE_IS_HAND_WORKER], toCheck.isHandWorker);
      expect(json[Constants.EMPLOYEE_PHONE_NUMBER], toCheck.phoneNumber);
      expect((json[Constants.EMPLOYEE_PROJECTS] as List).length, 0);
      expect(json[Constants.EMPLOYEE_IMAGE_URL], toCheck.imageUrl);
      toJsonEntityCheck(json, toCheck);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final now = DateTime.now();
      final json = {
        Constants.EMPLOYEE_EMAIL: faker.internet.email(),
        Constants.EMPLOYEE_NAME: faker.person.name(),
        Constants.EMPLOYEE_PERMISSION: describeEnum(randomPermission()),
        Constants.EMPLOYEE_PHONE_NUMBER: randomPhoneNumber(),
        Constants.EMPLOYEE_IMAGE_PATH: 'path',
        Constants.EMPLOYEE_IMAGE_URL: 'url',
        Constants.EMPLOYEE_IS_HAND_WORKER: rnd.nextBool(),
        Constants.ENTITY_CREATED: now.millisecondsSinceEpoch,
        Constants.ENTITY_MODIFIED: now.millisecondsSinceEpoch,
        Constants.EMPLOYEE_PROJECTS: ['test_project'],
      };
      Employee toCheck = Employee.fromJson(id: faker.guid.guid(), data: json);
      expect(toCheck.email, json[Constants.EMPLOYEE_EMAIL]);
      expect(toCheck.name, json[Constants.EMPLOYEE_NAME]);
      expect(
          toCheck.permission,
          convertStringToPermission(
              json[Constants.EMPLOYEE_PERMISSION] as String));
      expect(toCheck.isHandWorker, json[Constants.EMPLOYEE_IS_HAND_WORKER]);
      expect(toCheck.phoneNumber, json[Constants.EMPLOYEE_PHONE_NUMBER]);
      expect(toCheck.projects, isNotNull);
      expect(toCheck.projects, isNotEmpty);
      expect(toCheck.projects.contains("test_project"), true);
      expect(toCheck.imageUrl, json[Constants.EMPLOYEE_IMAGE_URL]);
      fromJsonEntityCheck(json, toCheck);
    });

    test('clone', () {
      final toCheck = generateRandomEmployee();
      toCheck.projects.add("test_project");
      final cloned = toCheck.clone() as Employee;
      compareTwoEmployees(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomEmployee();
      toCheck.projects.add("test_project");
      final cloned = Employee.copy(toCheck);
      compareTwoEmployees(toCheck, cloned);
    });

    test('isWithImage', () {
      final toCheck = generateRandomEmployee();
      toCheck.imageUrl = null;
      expect(toCheck.isWithImage(), false);
      toCheck.imageUrl = "";
      expect(toCheck.isWithImage(), false);
      toCheck.imageUrl = "hey";
      expect(toCheck.isWithImage(), true);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomEmployee();
      expect(toCheck.validateMustFields(), true);
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "aa";
      toCheck.email = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.email = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.email = faker.internet.email();
      toCheck.isHandWorker = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.isHandWorker = true;
      toCheck.permission = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.permission = randomPermission();
      toCheck.projects = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.projects = Set<String>();
      expect(toCheck.validateMustFields(), true);
    });

    test('isPermissionOk', () {
      final toCheck = generateRandomEmployee();

      toCheck.permission = null;
      expect(toCheck.isPermissionOk(null), false);
      expect(toCheck.isPermissionOk(Permission.ADMIN), false);
      expect(toCheck.isPermissionOk(Permission.MANAGER), false);
      expect(toCheck.isPermissionOk(Permission.REGULAR), false);

      toCheck.permission = Permission.REGULAR;
      expect(toCheck.isPermissionOk(null), false);
      expect(toCheck.isPermissionOk(Permission.ADMIN), false);
      expect(toCheck.isPermissionOk(Permission.MANAGER), false);
      expect(toCheck.isPermissionOk(Permission.REGULAR), true);

      toCheck.permission = Permission.MANAGER;
      expect(toCheck.isPermissionOk(null), false);
      expect(toCheck.isPermissionOk(Permission.ADMIN), false);
      expect(toCheck.isPermissionOk(Permission.MANAGER), true);
      expect(toCheck.isPermissionOk(Permission.REGULAR), true);

      toCheck.permission = Permission.ADMIN;
      expect(toCheck.isPermissionOk(null), true);
      expect(toCheck.isPermissionOk(Permission.ADMIN), true);
      expect(toCheck.isPermissionOk(Permission.MANAGER), true);
      expect(toCheck.isPermissionOk(Permission.REGULAR), true);
    });
  });
}

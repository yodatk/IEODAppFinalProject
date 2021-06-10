import 'dart:math';

import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/permission.dart';
import 'package:faker/faker.dart';

/// register tests
const REGISTER_TEST_SUCCESS = "registerTest_success";
const REGISTER_TEST_SHORT_PASS = "registerTest_shortPassword";
const REGISTER_TEST_NULL_HAND_WORKER = "registerTest_nullHandWorker";
const REGISTER_TEST_NULL_PERMISSION = "registerTest_nullPermission";
const REGISTER_TEST_NULL_NAME = "registerTest_nullName";
const REGISTER_TEST_EMPTY_NAME = "registerTest_emptyName";
const REGISTER_TEST_NULL_PASS = "registerTest_nullPassword";
const REGISTER_TEST_ID = "registerTestID";

const EDIT_EMP_TEST_SUCCESS = 'editEmployeeTest_success';
const EDIT_EMP_TEST_MISSING_PERM = 'editEmployee_missingPermission';
const EDIT_EMP_TEST_MISSING_NAME = 'editEmployee_missingName';
const EDIT_EMP_TEST_EMPTY_NAME = 'editEmployee_emptyName';
const EDIT_EMP_TEST_MISSING_EMAIL = 'editEmployee_missingEmail';
const EDIT_EMP_TEST_EMPTY_EMAIL = 'editEmployee_emptyEmail';
const EDIT_EMP_TEST_MISSING_PROJECTS = 'editEmployee_missingProjects';
const EDIT_EMP_TEST_MISSING_EMPLOYEE = 'editEmployee_missingEmployee';
const EDIT_EMP_TEST_MISSING_IS_HAND_WORKER = 'editEmployee_missingIsHandWorker';

const DELETE_EMP_TEST_MISSING_EMPLOYEE = 'deleteEmployee_missingEmployee';
const DELETE_EMP_TEST_CURRENT_EMPLOYEE = 'deleteEmployee_currentEmployee';
const DELETE_EMP_TEST_MISSING_ID = 'deleteEmployee_missingId';
const DELETE_EMP_TEST_SUCCESS = 'deleteEmployee_success';

const ALL_EMPLOYEES_SUCCESS = 'allEmployees_success';
const ALL_EMPLOYEES_WITH_SAME_NAME_SUCCESS = 'allEmployeesWithSameName_success';
const ALL_EMPLOYEES_OF_CURRENT_PROJECT_SUCCESS =
    'allEmployeesOfCurrentProject_success';
const ALL_HAND_WORK_EMPLOYEES_SUCCESS = 'allHandWorkers_success';
const ALL_ADMINS_SUCCESS = 'allAdmins_success';

final Map<String, String> registerTestEmails = {
  REGISTER_TEST_SUCCESS: faker.internet.email(),
  //"test_test_test@gmail.com",
  REGISTER_TEST_ID: "",
  // faker.internet.email(), // todo uncomment randomEmail when delete employee works
  REGISTER_TEST_SHORT_PASS: faker.internet.email(),

  REGISTER_TEST_NULL_HAND_WORKER: faker.internet.email(),
  REGISTER_TEST_NULL_PERMISSION: faker.internet.email(),
  REGISTER_TEST_NULL_NAME: faker.internet.email(),
  REGISTER_TEST_EMPTY_NAME: faker.internet.email(),
  REGISTER_TEST_NULL_PASS: faker.internet.email(),
};

String randomPhoneNumber() {
  final rnd = Random();
  String output = "054";
  for (int i = 0; i < 7; i++) {
    output += rnd.nextInt(10).toString();
  }
  return output;
}

Employee generateRandomEmployeeToRegister(String testName) {
  final randomEmail = registerTestEmails[testName];
  // overrideEmail == null
  //     ? "test_test_test@gmail.com" // faker.internet.email(); // todo uncomment randomEmail when delete employee works
  //     : overrideEmail;
  final randomName = faker.person.name();
  final phone = randomPhoneNumber();
  final permission = randomPermission();
  final isHandWorker = Random().nextBool();
  return Employee(
      email: randomEmail,
      name: randomName,
      phoneNumber: phone,
      permission: permission,
      isHandWorker: isHandWorker);
}

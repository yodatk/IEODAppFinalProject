import 'dart:math';

import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/edit_image_case.dart';
import 'package:IEODApp/models/permission.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dataForTest.dart';

Future<void> registerTests(String currentProject) async {
  final validEmp = generateRandomEmployeeToRegister("registerTest_success");
  await runRegisterTest(
    testName: "registerTest_success",
    toRegister: validEmp,
    password: faker.internet.password(),
    isSuccessful: true,
  );

  await runRegisterTest(
    testName: "registerTest_existingEmployee",
    toRegister: validEmp,
    password: faker.internet.password(),
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_nullEmployee",
    toRegister: null,
    password: faker.internet.email(),
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_shortPassword",
    toRegister: generateRandomEmployeeToRegister("registerTest_shortPassword"),
    password: "12",
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_nullPassword",
    toRegister: generateRandomEmployeeToRegister("registerTest_nullPassword"),
    password: null,
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_nullEmail",
    toRegister: Employee(
      email: null,
      name: faker.person.name(),
      phoneNumber: randomPhoneNumber(),
      permission: randomPermission(),
      isHandWorker: Random().nextBool(),
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_emptyEmail",
    toRegister: Employee(
      email: "",
      name: faker.person.name(),
      phoneNumber: randomPhoneNumber(),
      permission: randomPermission(),
      isHandWorker: Random().nextBool(),
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_emptyName",
    toRegister: Employee(
      email: registerTestEmails["registerTest_emptyName"],
      name: "",
      phoneNumber: randomPhoneNumber(),
      permission: randomPermission(),
      isHandWorker: Random().nextBool(),
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );

  await runRegisterTest(
    testName: "registerTest_nullName",
    toRegister: Employee(
      email: registerTestEmails["registerTest_nullName"],
      name: null,
      phoneNumber: randomPhoneNumber(),
      permission: randomPermission(),
      isHandWorker: Random().nextBool(),
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );
  await runRegisterTest(
    testName: "registerTest_nullPermission",
    toRegister: Employee(
      email: registerTestEmails["registerTest_nullPermission"],
      name: faker.person.name(),
      phoneNumber: randomPhoneNumber(),
      permission: null,
      isHandWorker: Random().nextBool(),
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );
  await runRegisterTest(
    testName: "registerTest_nullHandWorker",
    toRegister: Employee(
      email: registerTestEmails["registerTest_nullHandWorker"],
      name: faker.person.name(),
      phoneNumber: randomPhoneNumber(),
      permission: randomPermission(),
      isHandWorker: null,
    ),
    password: faker.internet.password(),
    isSuccessful: false,
  );
}

///
/// run a single Register case test of the given [testName]
/// trying to register the given Employee [toRegister]
/// if the [isSuccessful] flag is true, check all assertions in the assumption that all details are valid
/// otherwise, treat all given fields as invalid an make the matching assertion
///
Future<void> runRegisterTest({
  @required String testName,
  @required Employee toRegister,
  @required String password,
  @required bool isSuccessful,
}) async {
  testWidgets(testName, (WidgetTester tester) async {
    String msg = await EmployeeHandler()
        .register(toRegister, password, null, EditImageCase.NO_CHANGE);
    expect(msg, isSuccessful ? "" : isNotEmpty);
    if (toRegister != null && msg != Constants.EMPLOYEE_EXISTS_MSG) {
      final justRegistered =
          await EmployeeHandler().getEmployeeWithGivenEmail(toRegister.email);

      expect(justRegistered != null ? justRegistered.email : null,
          isSuccessful ? toRegister.email : isNull);
      if (testName == REGISTER_TEST_SUCCESS) {
        registerTestEmails[REGISTER_TEST_ID] = justRegistered.id;
        await Future.delayed(Duration(seconds: 2));
      }
    }
  });
}

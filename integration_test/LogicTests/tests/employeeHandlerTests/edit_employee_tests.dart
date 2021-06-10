import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/models/all_models.dart';
import 'package:IEODApp/models/edit_image_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dataForTest.dart';

final validEmp = Employee(
  id: registerTestEmails[REGISTER_TEST_ID],
  email: registerTestEmails[REGISTER_TEST_SUCCESS],
  name: faker.person.name(),
  phoneNumber: randomPhoneNumber(),
  permission: randomPermission(),
  isHandWorker: false,
);

Future<void> editDeleteEmployeeTests(String currentProject) async {
  testWidgets(EDIT_EMP_TEST_SUCCESS, (WidgetTester tester) async {
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: true,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_PERM, (WidgetTester tester) async {
    validEmp.permission = null;
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_NAME, (WidgetTester tester) async {
    validEmp.permission = randomPermission();
    validEmp.name = null;
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_EMPTY_NAME, (WidgetTester tester) async {
    validEmp.name = "";
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_EMAIL, (WidgetTester tester) async {
    validEmp.name = "hey";
    validEmp.email = null;
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_EMPTY_EMAIL, (WidgetTester tester) async {
    validEmp.email = "";
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_PROJECTS, (WidgetTester tester) async {
    validEmp.email = faker.internet.email();
    validEmp.projects = null;
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_IS_HAND_WORKER,
      (WidgetTester tester) async {
    validEmp.projects = Set<String>();
    validEmp.isHandWorker = null;
    await runEditEmployeeTest(
      toEdit: validEmp,
      isSuccessful: false,
    );
  });

  testWidgets(EDIT_EMP_TEST_MISSING_EMPLOYEE, (WidgetTester tester) async {
    validEmp.isHandWorker = false;
    await runEditEmployeeTest(
      toEdit: null,
      isSuccessful: false,
    );
  });

  testWidgets(DELETE_EMP_TEST_MISSING_EMPLOYEE, (WidgetTester tester) async {
    await runDeleteEmployeeTest(
        testName: DELETE_EMP_TEST_MISSING_EMPLOYEE,
        toDelete: null,
        isSuccessful: false);
  });

  testWidgets(DELETE_EMP_TEST_SUCCESS, (WidgetTester tester) async {
    await runDeleteEmployeeTest(
        testName: DELETE_EMP_TEST_SUCCESS,
        toDelete: validEmp,
        isSuccessful: true);
  });
}

///
/// trying to edit the [Employee] with the same ID as [toEdit]
/// if the [isSuccessful] flag is true, check all assertions in the assumption that all details are valid
/// otherwise, treat all given fields as invalid an make the matching assertion
///
Future<void> runEditEmployeeTest({
  @required Employee toEdit,
  @required bool isSuccessful,
}) async {
  final data = toEdit?.toJson() ??
      {Constants.ENTITY_MODIFIED: DateTime.now().millisecondsSinceEpoch};

  String msg = await EmployeeHandler()
      .editEmployee(toEdit, data, null, EditImageCase.NO_CHANGE);
  expect(msg, isSuccessful ? "" : isNotEmpty);
}

///
/// run a single delete employee case test of the given [testName]
/// trying to delete the [Employee] with the same ID as [toDelete]
/// if the [isSuccessful] flag is true, check all assertions in the assumption that all details are valid
/// otherwise, treat all given fields as invalid an make the matching assertion
///
Future<void> runDeleteEmployeeTest({
  @required String testName,
  @required Employee toDelete,
  @required bool isSuccessful,
}) async {
  print(EmployeeHandler().readCurrentEmployee()?.name);

  String msg = await EmployeeHandler().deleteEmployee(toDelete);
  print("msg: $msg");
  expect(msg, isSuccessful ? "" : isNotEmpty);

  if (toDelete != null && testName == DELETE_EMP_TEST_SUCCESS) {
    final justRegistered =
        await EmployeeHandler().getEmployeeWithGivenEmail(toDelete.email);
    expect(justRegistered, isNull);
  }
}

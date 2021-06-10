import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/Constants.dart' as TestConstants;

///
/// Run all test cases of login
///
Future<void> loginTests(String adminPassword) async {
  await runLoginTest(
    testName: "loginTest_success",
    email: TestConstants.ADMIN_EMAIL,
    password: adminPassword,
    isSuccessful: true,
  );

  await runLoginTest(
    testName: "loginTest_wrong_email",
    email: "error@error.com",
    password: adminPassword,
    isSuccessful: false,
  );

  await runLoginTest(
    testName: "loginTest_wrong_password",
    email: TestConstants.ADMIN_EMAIL,
    password: "errorerror",
    isSuccessful: false,
  );

  await runLoginTest(
    testName: "loginTest_empty_fields",
    email: "",
    password: "",
    isSuccessful: false,
  );

  await runLoginTest(
    testName: "loginTest_null_fields",
    email: null,
    password: null,
    isSuccessful: false,
  );
}

///
/// run a single login case test of the given [testName]
/// trying to login a user with the given [email] and [password]
/// if the [isSuccessful] flag is true, check all assertions in the assumption that all details are valid
/// otherwise, treat all given fields as invalid an make the matching assertion
///
Future<void> runLoginTest({
  @required String testName,
  @required String email,
  @required String password,
  @required bool isSuccessful,
}) async {
  testWidgets(testName, (WidgetTester tester) async {
    String msg =
        await EmployeeHandler().login(email: email, password: password);

    expect(msg, isSuccessful ? "" : isNotEmpty);
    final currentEmployee = EmployeeHandler().readCurrentEmployee();
    if (isSuccessful) {
      expect(currentEmployee, isNotNull);
      expect(currentEmployee.email, email);
    } else {
      expect(currentEmployee, null);
    }
    await EmployeeHandler().logout();
  });
}

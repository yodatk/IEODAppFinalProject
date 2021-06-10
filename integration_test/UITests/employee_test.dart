import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/constants/constants.dart' as Constants;
import '../../lib/logger.dart' as Logger;
import '../utils/general_utils.dart' as GeneralUtils;
import '../utils/registration_utils.dart' as RegistrationUtils;
import '../integration_test_suite.dart';
import '../LogicTests/utils/Constants.dart' as TestConstants;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();

  tearDownAll(() {
    SystemNavigator.pop();
  });

  await EmployeeTests().runTests();
}

class EmployeeTests extends IntegrationTestSuite {
  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();

    await registerEmployee(args[TestConstants.PASSWORD]);

    await registerEmployeeWithLowPermission(args[TestConstants.PASSWORD]);

    await registerWithShortPassword(args[TestConstants.PASSWORD]);

    await registerEmployeeWhoAlreadyExists(args[TestConstants.PASSWORD]);

    await editExistingEmployee(args[TestConstants.PASSWORD]);
    await editExistingEmployeeWithEmptyName(args[TestConstants.PASSWORD]);
    await deleteExistingEmployee(args[TestConstants.PASSWORD]);
  }

  ///
  /// Trying to add employee that already exists. EXPECTED: fail
  ///
  Future<void> registerEmployeeWhoAlreadyExists(String password) async {
    testWidgets("Try to register regular employee, but he already exists",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await RegistrationUtils.enterAddEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.registerNewEmployee(tester: tester);

      await tester.pumpAndSettle();

      await tester.tap(RegistrationUtils.cancelAddSameEmployee);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();

      Logger.info("Add Employee Fail - EMPLOYEE ALREADY EXISTS, as expected");
    });
  }

  ///
  /// Trying to add employee with a short password. EXPECTED: fail
  ///
  Future registerWithShortPassword(String password) async {
    testWidgets("Try to register regular employee, but password is too short",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await RegistrationUtils.enterAddEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.registerNewEmployee(tester: tester, pass: '12');
      await tester.pumpAndSettle();
      expect(find.text(Constants.MIN_PASS_LENGTH_MSG), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Add Employee Fail - SHORT PASSWORD,as Expected");
    });
  }

  ///
  /// Trying to add employee with an employee with permission which is not admin. EXPECTED: fail
  ///
  Future registerEmployeeWithLowPermission(String password) async {
    testWidgets("try to register new employee from manager user",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(tester: tester, email: 'shan@shan.com', password: password);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('inOptionsHomePage')), findsOneWidget);
      expect(find.byKey(Key("employeesPage")), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(GeneralUtils.employeesPageNavigator);
      await tester.pumpAndSettle();
      expect(find.byKey(Key("addNewEmployeeBtn")), findsNothing);
      expect(find.byKey(Key("edit_${RegistrationUtils.TEST_EMPLOYEE_EMAIL}")),
          findsNothing);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Add Employee Fail - MANAGER USER, as expected");
    });
  }

  ///
  /// Trying to add employee with proper details. EXPECTED: succeed
  ///
  Future registerEmployee(String password) async {
    testWidgets("Register regular employee", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      print("logged in");
      await tester.pumpAndSettle();
      await RegistrationUtils.enterAddEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.registerNewEmployee(tester: tester);

      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));
      expect(find.text(RegistrationUtils.TEST_EMPLOYEE_NAME), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Add Employee Successfully");
    });
  }

  ///
  /// Trying to edit employee with proper details. EXPECTED: succeed
  ///
  Future editExistingEmployee(String password) async {
    testWidgets("edit existing employee", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await RegistrationUtils.enterEditEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.editExistingEmployee(tester: tester);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.text(RegistrationUtils.EDIT_EMPLOYEE_NAME), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Edit Employee Successfully");
    });
  }

  ///
  /// Trying to edit employee with proper details. EXPECTED: succeed
  ///
  Future editExistingEmployeeWithEmptyName(String password) async {
    testWidgets("edit existing employee with empty name",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();
      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await RegistrationUtils.enterEditEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.editExistingEmployee(
          tester: tester, employeeName: "");
      await tester.pumpAndSettle();
      expect(find.text(Constants.REGISTER_REQUIRED), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Failed to edit employee with empty name , as expected");
    });
  }

  ///
  /// Trying to edit employee with proper details. EXPECTED: succeed
  ///
  Future deleteExistingEmployee(String password) async {
    testWidgets("delete existing employee", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await RegistrationUtils.enterEditEmpPage(tester);
      await tester.pumpAndSettle();
      await RegistrationUtils.deleteExistingEmployee(tester: tester);
      await tester.pumpAndSettle();
      expect(find.text(RegistrationUtils.EDIT_EMPLOYEE_NAME), findsNothing);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Delete Employee Successfully");
    });
  }
}

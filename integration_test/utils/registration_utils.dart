library registration_utils;

import 'package:IEODApp/screens/employee_management/employee_edit_screen/widgets/edit_employee_form.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/permission.dart';
import '../../lib/screens/constants/keys.dart' as GeneralKeys;
import '../../lib/screens/employee_management/constants/keys.dart'
    as EmployeeScreensKeys;
import '../LogicTests/tests/employeeHandlerTests/dataForTest.dart';
import 'general_utils.dart' as GeneralUtils;

///
/// Name of the employee to add
///
final TEST_EMPLOYEE_NAME = '${faker.person.firstName()}';

///
/// Name of the employee to edit
///
final EDIT_EMPLOYEE_NAME = '${faker.person.firstName()}';

///
/// Phone of employee to add
///
final TEST_EMPLOYEE_PHONE = randomPhoneNumber();

///
/// Email address of employee to add
///
final TEST_EMPLOYEE_EMAIL = faker.internet.email();

///
/// Password of employee to add
///
final TEST_EMPLOYEE_PASS = faker.internet.password();

///
/// Finder to the email field in the login Page
///
final Finder loginInEmailField = find.byKey(Key(GeneralKeys.LOGIN_EMAIL));

///
/// Finder to the password field in the login page
///
final Finder loginInPasswordField = find.byKey(Key(GeneralKeys.LOGIN_PASS));

///
/// Finder to the button in the login page
///
final Finder loginInSubmitBtn = find.byKey(Key(GeneralKeys.LOGIN_BTN));

///
/// Finder for the Full name text field in registration screen
///
final Finder registerInFullNameField =
    find.byKey(Key(EmployeeScreensKeys.FULL_NAME));

///
/// Finder for the phone text field in registration screen
///
final Finder registerInPhoneField =
    find.byKey(Key(EmployeeScreensKeys.PHONE_NUMBER));

///
/// Finder for the email text field in registration screen
///
final Finder registerInEmailField = find.byKey(Key(EmployeeScreensKeys.EMAIL));

///
/// Finder for the password text field in registration screen
///
final Finder registerInPasswordField =
    find.byKey(Key(EmployeeScreensKeys.PASS1));

///
/// Finder for the confirm text field in registration screen
///
final Finder registerInConfirmPasswordField =
    find.byKey(Key(EmployeeScreensKeys.PASS2));

///
/// Finder for the regular permission field in registration screen
///
final Finder registerInPermissionFieldRegular =
    find.byKey(Key(describeEnum(Permission.REGULAR)));

///
/// Finder for the manager permission field in registration screen
///
final Finder registerInPermissionFieldManager =
    find.byKey(Key(describeEnum(Permission.MANAGER)));

///
/// Finder for the admin permission field in registration screen
///
final Finder registerInPermissionFieldAdmin =
    find.byKey(Key(describeEnum(Permission.ADMIN)));

///
/// Finder for the add button in registration screen
///
final Finder registerInAddEmpButton =
    find.byKey(Key(EmployeeScreensKeys.ADD_EMPLOYEE_BTN));

///
/// Finder for the edit button in edit user screen
///
final Finder editEmpButton = find.byKey(
  Key(EmployeeScreensKeys.EDIT_EMPLOYEE_BTN),
);

///
/// Finder for the delete button in edit user screen
///
final Finder deleteEmpButton =
    find.byKey(Key(EmployeeScreensKeys.DELETE_EMPLOYEE_BTN));

///
/// Finder for the add Button in the all employees screen
///
final Finder addNewEmployeeBtn =
    find.byKey(Key(EmployeeScreensKeys.ADD_NEW_EMPLOYEE_BTN));

///
/// Finder for the cancel button in the same name for employee button
///
final Finder cancelAddSameEmployee =
    find.byKey(Key(EmployeeScreensKeys.CANCEL_ADD_SAME_EMPLOYEE));

const ADMIN_EMAIL = "test_test_ad@ieod.com";
const ADMIN_NAME = "חביבי סופרים";

const MANAGER_EMAIL = "shan@shan.com";
const MANAGER_NAME = "שני סמסון";

const REGULAR_EMAIL = "avi@avi.com";
const REGULAR_NAME = "אבי";

const TEST_PROJECT_NAME = 'פרויקט זמני';

///
/// Use [tester] login user to the app with given [email]
///
Future<void> loginUser({WidgetTester tester, String email, String password}) async {
  // set up finders for login
  await tester.tap(find.byKey(Key('loginInEmailField')));
  await tester.pumpAndSettle();
  await tester.enterText(loginInEmailField, email);
  await tester.pumpAndSettle(); //.pump(const Duration(seconds: 1));
  await tester.tap(loginInPasswordField);
  await tester.pumpAndSettle();
  await tester.enterText(loginInPasswordField, password);
  await tester.pumpAndSettle(); //.pump(const Duration(seconds: 1));
  await tester.tap(loginInSubmitBtn);
  await tester.pumpAndSettle();
  // temp tap for tests to run
  final Finder currentProject = find.text(TEST_PROJECT_NAME);
  if (currentProject.evaluate().isNotEmpty) {
    await tester.tap(currentProject);
    await tester.pumpAndSettle();
  }
}

///
/// Use [tester] to register user with details of:
///  1. name: [employeeName]
///  2. phone: [phone]
///  3. email: [email]
///  4. password: [pass]
///
Future<void> registerNewEmployee({
  WidgetTester tester,
  String employeeName,
  String phone,
  String email,
  String pass,
  Permission perm = Permission.REGULAR,
}) async {
  if (employeeName == null) {
    employeeName = TEST_EMPLOYEE_NAME;
  }
  if (phone == null) {
    phone = TEST_EMPLOYEE_PHONE;
  }
  if (email == null) {
    email = TEST_EMPLOYEE_EMAIL;
  }
  if (pass == null) {
    pass = TEST_EMPLOYEE_PASS;
  }
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.FULL_NAME)));
  await tester.enterText(registerInFullNameField, employeeName);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.PHONE_NUMBER)));
  await tester.enterText(registerInPhoneField, phone);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.EMAIL)));
  await tester.enterText(registerInEmailField, email);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.PASS1)));
  await tester.enterText(registerInPasswordField, pass);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.PASS2)));
  await tester.enterText(registerInConfirmPasswordField, pass);
  await tester.pumpAndSettle();
  await tester.tap(getRightPermissionButton(perm));
  await tester.pumpAndSettle();
  await tester.ensureVisible(registerInAddEmpButton);
  await tester.tap(registerInAddEmpButton);
  await tester.pumpAndSettle();
}

///
/// Gets the matching [Finder] to the given [Permission] perm
///
Finder getRightPermissionButton(Permission perm) {
  Finder permissionFinder;
  switch (perm) {
    case Permission.REGULAR:
      permissionFinder = registerInPermissionFieldRegular;
      break;
    case Permission.MANAGER:
      permissionFinder = registerInPermissionFieldManager;
      break;
    case Permission.ADMIN:
      permissionFinder = registerInPermissionFieldAdmin;
      break;
    default:
      permissionFinder = registerInPermissionFieldRegular;
      break;
  }
  return permissionFinder;
}

///
/// Use [tester] to edit user in [EditEmployeeForm] with details of:
///  1. name: [employeeName]
///  2. phone: [phone]
///
Future<void> editExistingEmployee({
  WidgetTester tester,
  String employeeName,
  String phone,
  Permission perm,
  bool doPermission = false,
}) async {
  if (employeeName == null) {
    employeeName = EDIT_EMPLOYEE_NAME;
  }
  if (perm == null) {
    perm = randomPermission();
  }
  if (phone == null) {
    phone = TEST_EMPLOYEE_PHONE;
  }

  await tester.tap(find.byKey(Key(EmployeeScreensKeys.FULL_NAME)));
  await tester.enterText(registerInFullNameField, employeeName);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(EmployeeScreensKeys.PHONE_NUMBER)));
  await tester.enterText(registerInPhoneField, phone);
  await tester.pumpAndSettle();
  if (doPermission) {
    await tester.tap(getRightPermissionButton(perm));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(editEmpButton);
  await tester.tap(editEmpButton);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to delete user in [EditEmployeeForm] with details of:
///
Future<void> deleteExistingEmployee({
  WidgetTester tester,
}) async {
  await tester.ensureVisible(deleteEmpButton);
  await tester.tap(deleteEmpButton);
  await tester.pumpAndSettle();
  final Finder sureDeleteBtn =
      find.byKey(Key(EmployeeScreensKeys.SURE_DELETE_OK_BUTTON_KEY));
  await tester.tap(sureDeleteBtn);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to enter to add employee page
///
Future<void> enterAddEmpPage(WidgetTester tester) async {
  await GeneralUtils.enterEmployeeManagementPageFromAdminMenu(tester);
  expect(find.byKey(Key("addNewEmployeeBtn")), findsOneWidget);
  await tester.pumpAndSettle();
  await tester.tap(addNewEmployeeBtn);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to enter to edit employee page of given [employeeEmail]
///
Future<void> enterEditEmpPage(WidgetTester tester,
    {String employeeEmail}) async {
  if (employeeEmail == null) {
    employeeEmail = TEST_EMPLOYEE_EMAIL;
  }
  await GeneralUtils.enterEmployeeManagementPageFromAdminMenu(tester);
  final Finder testEmployeeEditButton = find.byKey(Key("edit_$employeeEmail"));
  await tester.tap(testEmployeeEditButton);
  await tester.pumpAndSettle();
}

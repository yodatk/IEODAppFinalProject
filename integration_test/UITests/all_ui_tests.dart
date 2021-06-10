import 'package:IEODApp/logger.dart' as Logger;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../LogicTests/tests/employeeHandlerTests/dataForTest.dart';
import '../integration_test_suite.dart';
import 'employee_test.dart';
import 'daily_info_test.dart';
import 'project_tests.dart';
import 'reports_tests.dart';
import 'site_and_plot_test.dart';
import '../LogicTests/utils/Constants.dart' as TestConstants;
void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();
  Logger.info(
      "register success email: ${registerTestEmails[REGISTER_TEST_SUCCESS]}");
  tearDown(() async {
    try {
      await EmployeeHandler().logout();
    } catch (ignored) {}
  });
  tearDownAll(() async {
    SystemNavigator.pop();
  });
  const String password = String.fromEnvironment(TestConstants.PASSWORD);
  await AllUITests().runTests(args: {TestConstants.PASSWORD: password});
}

class AllUITests extends IntegrationTestSuite {
  final _testsSuites = <IntegrationTestSuite>[
    EmployeeTests(),
    ReportsTests(),
    SitesAndPlotsTests(),
    DailyInfoTests(),
    ProjectsTests(),
  ];

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();
    for (int i = 0; i < _testsSuites.length; i++) {
      final suite = _testsSuites[i];
      await suite.runTests(args: args);
    }
  }
}
// flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/all_ui_tests.dart

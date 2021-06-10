import 'package:IEODApp/logger.dart' as Logger;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/dailyInfoHandler.dart';
import 'package:IEODApp/logic/fieldHandler.dart';
import 'package:IEODApp/logic/initializer.dart';
import 'package:IEODApp/logic/reportHandler.dart';
import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../integration_test_suite.dart';
import 'tests/ReportHandlerTests/reportHandler_test.dart';
import 'tests/dailyInfoHandlerTests/dailyInfoHandler_test.dart';
import 'tests/employeeHandlerTests/dataForTest.dart';
import 'tests/employeeHandlerTests/employeeHandlerTest.dart';
import 'tests/fieldHandlerTests/fieldHandler_test.dart';
import 'tests/projectHandlerTests/projectHandler_test.dart';
import '../../test/utils/projectUtils.dart';
import '../LogicTests/utils/Constants.dart' as TestConstants;

final randomProjectName = getRandomProjectName();

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();
  Logger.info(
      "register success email: ${registerTestEmails[REGISTER_TEST_SUCCESS]}");

  setUpAll(() async {
    await Initializer().init(null, isTest: true);
  });
  const String password = String.fromEnvironment(TestConstants.PASSWORD);
  await AllLogicTests().runTests(args: {TestConstants.PASSWORD: password});
  tearDownAll(() async {
    await FieldHandler().resetForTests(projectId: randomProjectName);
    await DailyInfoHandler().resetForTests(projectId: randomProjectName);
    await ReportHandler().resetForTests(projectId: randomProjectName);
    await EmployeeHandler().logout();
    try {
      SystemNavigator.pop();
    } catch (ignored) {}
  });
}

class AllLogicTests extends IntegrationTestSuite {
  final _testsSuites = <IntegrationTestSuite>[
    EmployeeHandlerTest(randomProjectName),
    ProjectHandlerTest(),
    DailyInfoTest(randomProjectName),
    FieldHandlerTests(randomProjectName),
    ReportHandlerTests(randomProjectName),
  ];

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();
    for (IntegrationTestSuite suite in _testsSuites) {
      await suite.runTests(args: args);
    }
  }
}

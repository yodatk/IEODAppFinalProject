import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../integration_test_suite.dart';
import '../../utils/Constants.dart' as TestConstants;
import 'login_test.dart';
import 'register_test.dart';
import 'edit_employee_tests.dart';
import 'allEmployeesQueriesTest.dart';

class EmployeeHandlerTest extends IntegrationTestSuite {

  String currentProjectName;

  EmployeeHandlerTest(this.currentProjectName);

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    if (args == null || !args.containsKey(TestConstants.PASSWORD)){
      throw Exception("Test not run since password not provided");
    }
    else{
      super.runTests();
      await loginTests(args[TestConstants.PASSWORD]);

      // // login for the rest of the tests
      testWidgets('settingUP logging in admin', (WidgetTester tester) async {
        String msg = await EmployeeHandler().login(
          email: TestConstants.ADMIN_EMAIL,
          password: args[TestConstants.PASSWORD],
        );

        expect(msg, "");
      });
      await registerTests(currentProjectName);
      await editDeleteEmployeeTests(currentProjectName);
      await queryTests(currentProjectName);
    }
  }
}

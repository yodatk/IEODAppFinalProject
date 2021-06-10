import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:IEODApp/models/edit_image_case.dart';
import 'package:IEODApp/models/project.dart';
import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../utils/general_utils.dart' as GeneralUtils;
import '../utils/registration_utils.dart' as RegistrationUtils;
import 'package:IEODApp/logger.dart' as Logger;
import '../utils/projects_utils.dart' as ProjectUtils;
import '../LogicTests/utils/Constants.dart' as TestConstants;
import '../integration_test_suite.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();
  tearDownAll(() {
    SystemNavigator.pop();
  });

  await ProjectsTests().runTests();
}

const PROJECT_ORIGINAL_NAME = 'פרויקט בדיקה';
const PROJECT_NEW_NAME = 'פרויקט בדיקה חדש';

final Map<String, String> employees = {
  RegistrationUtils.ADMIN_NAME: RegistrationUtils.ADMIN_EMAIL,
};

const ADMIN_ID = "2lO3UzC1j8UWqpqmNAOK3P8818Z2";

class ProjectsTests extends IntegrationTestSuite {
  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();

    await addProject(args[TestConstants.PASSWORD]);

    await editProject(args[TestConstants.PASSWORD]);

    await deleteProject(args[TestConstants.PASSWORD]);
  }

  Future<void> addProject(String password) async {
    testWidgets("add Project", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      String result = await ProjectHandler().addProject(
          Project(
            name: PROJECT_ORIGINAL_NAME,
            projectManagerId: ADMIN_ID,
            employees: <String>[ADMIN_ID].toSet(),
            isActive: true,
          ),
          null,
          EditImageCase.NO_CHANGE);
      if (result != "") {
        fail("something wrong with adding project: $result");
      }
      await ProjectUtils.navigateToProjectMenu(tester: tester);

      await tester.pumpAndSettle();
      expect(find.text(PROJECT_ORIGINAL_NAME), findsOneWidget);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      await Logger.info("added project successfully");
    });
  }

  Future<void> editProject(String password) async {
    testWidgets("edit Project", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await ProjectUtils.navigateToProjectMenu(tester: tester);
      await tester.pumpAndSettle();
      await ProjectUtils.editProject(
        tester: tester,
        oldName: PROJECT_ORIGINAL_NAME,
        newName: PROJECT_NEW_NAME,
      );
      await tester.pumpAndSettle();
      expect(find.text(PROJECT_ORIGINAL_NAME), findsNothing);
      expect(find.text(PROJECT_NEW_NAME), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited project successfully");
    });
  }

  Future<void> deleteProject(String password) async {
    testWidgets("delete Project", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await ProjectUtils.navigateToProjectMenu(tester: tester);
      await tester.pumpAndSettle();
      await ProjectUtils.deleteProject(
          tester: tester, projectName: PROJECT_NEW_NAME);
      await tester.pumpAndSettle();
      expect(find.text(PROJECT_NEW_NAME), findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted project successfully");
    });
  }
}

import 'package:IEODApp/logger.dart' as Logger;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:IEODApp/models/edit_image_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test/utils/projectUtils.dart';
import '../../../integration_test_suite.dart';
import 'dataForTest.dart';
import '../../utils/Constants.dart' as TestConstants;

final randomProjectName = faker.company.name();
var newProjectId = "";

class ProjectHandlerTest extends IntegrationTestSuite {
  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    if (args == null || !args.containsKey(TestConstants.PASSWORD)){
      throw Exception("Test not run since password not provided");
    }
    else{
      super.runTests();

      testWidgets("setUpForProjectTests", (WidgetTester tester) async {
        await EmployeeHandler().logout();
        await EmployeeHandler()
            .login(email: ADMIN_EMAIL, password: args[TestConstants.PASSWORD]);
      });
      // chooseCurrentProject test
      testWidgets(CHOOSE_PROJECT_TEST, (WidgetTester tester) async {
        await ProjectHandler().chooseProject(null);
        await Future.delayed(Duration(seconds: 2));
        final nullProject = ProjectHandler().readCurrentProject();
        final name1 = ProjectHandler().getCurrentProjectName();
        final id1 = ProjectHandler().getCurrentProjectId();
        expect(nullProject, null);
        expect(name1, null);
        expect(id1, null);

        await ProjectHandler().chooseProject("test_project");
        await Future.delayed(Duration(seconds: 2));
        final current = ProjectHandler().readCurrentProject();
        final name2 = ProjectHandler().getCurrentProjectName();
        final id2 = ProjectHandler().getCurrentProjectId();
        expect(current, isNotNull);
        expect(name2, "פרויקט זמני");
        expect(id2, "test_project");
        Logger.info("$CHOOSE_PROJECT_TEST PASSED");
      });

      // add project
      testWidgets(ADD_NULL_PROJECT_TEST, (WidgetTester tester) async {
        final msg = await ProjectHandler()
            .addProject(null, null, EditImageCase.NO_CHANGE);
        expect(msg, isNotEmpty);
        Logger.info("$ADD_NULL_PROJECT_TEST PASSED");
      });

      testWidgets(ADD_PROJECT_TEST, (WidgetTester tester) async {
        final project = generateRandomProject();
        final manager = EmployeeHandler().readCurrentEmployee();
        project.isActive = false;
        project.name = randomProjectName;
        project.projectManagerId = manager.id;
        project.employees.clear();
        project.employees.add(manager.id);
        final msg = await ProjectHandler()
            .addProject(project, null, EditImageCase.NO_CHANGE);
        expect(msg, isEmpty);
        Logger.info("$ADD_PROJECT_TEST PASSED");
      });

      // getAllProjectTest
      testWidgets(GET_ALL_PROJECTS_TEST, (WidgetTester tester) async {
        final realProjects = {
          ...PROJECTS_NAMES,
          randomProjectName,
        };
        final allProject = ProjectHandler().getAllProjects();
        allProject.listen(expectAsync1((event) {
          final converted = event.map((e) => e.name).toSet();
          if (converted.contains(randomProjectName)) {
            final p =
            event.firstWhere((element) => element.name == randomProjectName);
            newProjectId = p.id;
          }
          expect(converted.length, realProjects.length);
          print("current: $converted");
          expect(realProjects.containsAll(converted), true);
        }, max: 0));
        Logger.info("$GET_ALL_PROJECTS_TEST PASSED");
      });

      // getProjectById
      testWidgets(GET_PROJECT_BY_ID, (WidgetTester tester) async {
        final projectById =
        ProjectHandler().getCurrentProjectById("test_project");
        projectById.listen(expectAsync1((event) {
          expect(event, isNotNull);
          expect(event.name, "פרויקט זמני");
          expect(event.id, "test_project");
        }, max: 0));
        Logger.info("$GET_PROJECT_BY_ID PASSED");
      });

      // get all Active Project
      testWidgets(ADD_PROJECT_TEST, (WidgetTester tester) async {
        final realProjects = {...PROJECTS_NAMES};
        final allProject = ProjectHandler().getAllActiveProjects();
        allProject.listen(expectAsync1((event) {
          final converted = event.map((e) => e.name).toSet();
          expect(converted.length, realProjects.length);
          print("current: $converted");
          expect(realProjects.containsAll(converted), true);
        }, max: 0));
      });

      // edit project
      testWidgets(EDIT_NULL_PROJECT_TEST, (WidgetTester tester) async {
        final msg = await ProjectHandler().editProject(
            updatedProject: null,
            image: null,
            currentCase: EditImageCase.NO_CHANGE,
            employeesToAdd: <String>[],
            employeesToRemove: <String>[]);
        expect(msg, isNotEmpty);
        Logger.info("$EDIT_NULL_PROJECT_TEST PASSED");
      });

      testWidgets(EDIT_PROJECT_TEST, (WidgetTester tester) async {
        final project = generateRandomProject();
        final manager = EmployeeHandler().readCurrentEmployee();
        project.id = newProjectId;
        project.isActive = true;
        project.name = randomProjectName;
        project.projectManagerId = manager.id;
        project.employees.clear();
        project.employees.add(manager.id);
        final msg = await ProjectHandler().editProject(
            updatedProject: project,
            image: null,
            currentCase: EditImageCase.NO_CHANGE,
            employeesToAdd: <String>[],
            employeesToRemove: <String>[]);
        expect(msg, isEmpty);

        Logger.info("$EDIT_PROJECT_TEST PASSED");
      });

      // delete project

      testWidgets(DELETE_NULL_PROJECT, (WidgetTester tester) async {
        final msg = await ProjectHandler().deleteProject(null);
        expect(msg, isNotEmpty);
        Logger.info("$DELETE_NULL_PROJECT PASSED");
      });

      testWidgets(DELETE_PROJECT, (WidgetTester tester) async {
        final toDelete =
        await ProjectHandler().getCurrentProjectByIdFuture(newProjectId);
        final msg = await ProjectHandler().deleteProject(toDelete);
        expect(msg, isEmpty);
        Logger.info("$DELETE_PROJECT PASSED");
      });
    }
  }
}

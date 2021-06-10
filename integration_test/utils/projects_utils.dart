library project_utils;

import 'package:IEODApp/constants/general_keys.dart' as GeneralKeys;
import 'package:IEODApp/models/Employee.dart';
import 'package:IEODApp/screens/projects_menu_screens/constants/keys.dart'
    as ProjectsKeys;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

///
/// Tooltip of the  main AppDrawer
///
const APP_DRAWER = 'פתיחה של תפריט הניווט';

///
/// Use [tester] to navigate to projects menu
///
Future<void> navigateToProjectMenu({
  @required WidgetTester tester,
}) async {
  final Finder drawer = find.byTooltip(APP_DRAWER);
  await tester.tap(drawer);
  await tester.pumpAndSettle();
  final Finder chooseProjectBtn = find.byKey(Key(GeneralKeys.ADMIN_SETTINGS));
  await tester.tap(chooseProjectBtn);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(GeneralKeys.PROJECTS)));
  await tester.pumpAndSettle();
}

///
/// Use [tester] to go to the add Project page
///
Future<void> goToAddProject({
  @required WidgetTester tester,
}) async {
  await tester.tap(find.byKey(Key(ProjectsKeys.ADD_PROJECT_BTN)));
  await tester.pumpAndSettle();
}

///
/// In the edit project form, use [tester] to enter all [employees] to the form in the given [field]
///
Future<void> _enterAllEmployees(
    WidgetTester tester, Map<String, String> employees, Finder field) async {
  for (String employeeName in employees.keys) {
    final email = employees[employeeName];
    final Finder currentEmp = find.byKey(Key(email));
    await tester.tap(field);
    await tester.pumpAndSettle();
    //todo fails here
    await tester.enterText(field, employeeName);
    await tester.pumpAndSettle();
    await tester.ensureVisible(currentEmp);
    await tester.pumpAndSettle();
    await tester.tap(currentEmp);
    await tester.pumpAndSettle();
  }
}

///
/// Use [tester] to add project in project form using the given parameters
///
Future<void> addProject({
  @required WidgetTester tester,
  @required String projectName,
  @required Map<String, String> employees,
  @required Map<String, String> manager,
}) async {
  await goToAddProject(tester: tester);
  await tester.pumpAndSettle();
  final Finder projectNameField =
      find.byKey(Key(ProjectsKeys.PROJECT_NAME_FIELD));
  final Finder employeesField = find.byElementPredicate((element) =>
      element.widget.key == Key(ProjectsKeys.EMPLOYEES_FIELD) &&
      element.widget is FormBuilderChipsInput<
          Employee>); //find.byKey(Key(ProjectsKeys.EMPLOYEES_FIELD));
  final Finder managerField = find.byElementPredicate((element) =>
      element.widget.key == Key(ProjectsKeys.MANAGER_FIELD) &&
      element.widget is FormBuilderChipsInput<
          Employee>); //find.byKey(Key(ProjectsKeys.MANAGER_FIELD));
  await tester.tap(projectNameField);
  await tester.pumpAndSettle();
  await tester.enterText(projectNameField, projectName);
  await tester.pumpAndSettle();


  await _enterAllEmployees(tester, employees, employeesField);
  await tester.pumpAndSettle();
  await _enterAllEmployees(tester, manager, managerField.first);
  await tester.pumpAndSettle();
  final Finder submit = find.byKey(Key(ProjectsKeys.SUBMIT_PROJECT_BTN));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to tap on the Project tile with the given [projectName]
///
Future<void> tapSpecificProject({
  @required WidgetTester tester,
  @required String projectName,
}) async {
  await tester.tap(find.text(projectName));
  await tester.pumpAndSettle();
}

///
/// Use [tester] to enter to edit mode
///
Future<void> enterEditProject({
  @required WidgetTester tester,
  @required String projectName,
}) async {
  await tapSpecificProject(tester: tester, projectName: projectName);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();
}

///
/// Use [tester] to popUp the delete project with the given [projectName] dialog
///
Future<void> enterDeleteProject({
  @required WidgetTester tester,
  @required String projectName,
}) async {
  await tapSpecificProject(tester: tester, projectName: projectName);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.delete));
  await tester.pumpAndSettle();
}

///
/// Use [tester] with given [oldName] and edit it with given [newName]
///
Future<void> editProject({
  @required WidgetTester tester,
  @required String oldName,
  @required String newName,
}) async {
  await enterEditProject(tester: tester, projectName: oldName);
  await tester.pumpAndSettle();
  final Finder projectNameField =
      find.byKey(Key(ProjectsKeys.PROJECT_NAME_FIELD));
  await tester.tap(projectNameField);
  await tester.pumpAndSettle();
  await tester.enterText(projectNameField, newName);
  await tester.pumpAndSettle();
  final Finder submit = find.byKey(Key(ProjectsKeys.SUBMIT_PROJECT_BTN));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to delete project with the given [projectName]
///
Future<void> deleteProject({
  @required WidgetTester tester,
  @required String projectName,
}) async {
  await enterDeleteProject(tester: tester, projectName: projectName);
  await tester.pumpAndSettle();
  final Finder projectNameField =
      find.byKey(Key(ProjectsKeys.PROJECT_NAME_FIELD));
  await tester.tap(projectNameField);
  await tester.pumpAndSettle();
  await tester.enterText(projectNameField, projectName);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(ProjectsKeys.SURE_TO_DELETE_PROJECT)));
  await tester.pumpAndSettle();
}

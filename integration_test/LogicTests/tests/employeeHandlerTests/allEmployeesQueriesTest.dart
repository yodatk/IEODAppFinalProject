import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dataForTest.dart';

Future<void> queryTests(String currentProject) async {
  testWidgets(ALL_EMPLOYEES_SUCCESS, (WidgetTester tester) async {
    Set<String> emails = [
      "adminieod@ieod.com",
      "test_test_ad@ieod.com",
      "shan@shan.com",
      "avi@avi.com",
    ].toSet();
    final all = EmployeeHandler().getAllEmployeesAsStream();
    all.listen(expectAsync1((event) {
      final converted = event.map((e) => e.email).toSet();
      expect(converted.length, emails.length);
      print("current: $converted");
      expect(emails.containsAll(converted), true);
    }, max:0));
    print("$ALL_EMPLOYEES_SUCCESS PASSED");
  });

  testWidgets(ALL_EMPLOYEES_OF_CURRENT_PROJECT_SUCCESS,
      (WidgetTester tester) async {
    await ProjectHandler().chooseProject(currentProject);
    await Future.delayed(Duration(seconds: 2));
    Set<String> emails = [
      "adminieod@ieod.com",
      "test_test_ad@ieod.com",
      "shan@shan.com",
      "avi@avi.com",
    ].toSet();
    final all = EmployeeHandler().getAllEmployeesFromCurrentProject();
    all.listen(expectAsync1((event) {
      final converted = event.map((e) => e.email).toSet();
      expect(converted.length, emails.length);
      print("current: $converted");
      expect(emails.containsAll(converted), true);
    }, max: 0));
    print("$ALL_EMPLOYEES_OF_CURRENT_PROJECT_SUCCESS PASSED");
  });

  testWidgets(ALL_HAND_WORK_EMPLOYEES_SUCCESS, (WidgetTester tester) async {
    await ProjectHandler().chooseProject(currentProject);
    await Future.delayed(Duration(seconds: 2));
    final allHandEmployeesOfProject =
        await EmployeeHandler().getAllHandWorkEmployees();
    final allHandWorkers = [
      "shan@shan.com",
      "avi@avi.com",
    ].toSet();
    final actualEmails = allHandEmployeesOfProject.map((e) => e.email).toSet();
    print("allHandWorkers: $allHandWorkers");
    print("actualEmails: $actualEmails");
    expect(allHandWorkers.containsAll(actualEmails), true);
    expect(actualEmails.containsAll(allHandWorkers), true);
    print("$ALL_HAND_WORK_EMPLOYEES_SUCCESS PASSED");
  });

  testWidgets(ALL_ADMINS_SUCCESS, (WidgetTester tester) async {
    final allEmployeesOfProject = EmployeeHandler().getAllAdmins();
    final allEmails = [
      "adminieod@ieod.com",
      "test_test_ad@ieod.com",
    ].toSet();
    allEmployeesOfProject.listen(expectAsync1((event) {
      final converted = event.map((e) => e.email).toSet();
      expect(converted.length, allEmails.length);
      print("current: $converted");
      expect(allEmails.containsAll(converted), true);
    }, max: 0));
    print("$ALL_ADMINS_SUCCESS PASSED");
  });
}

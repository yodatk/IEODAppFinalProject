import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:IEODApp/logic/dailyInfoHandler.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test/utils/arrangementUtils.dart';
import '../../../../test/utils/imageFolderUtils.dart';
import '../../../integration_test_suite.dart';
import '../projectHandlerTests/dataForTest.dart';
import 'dataForTests.dart';
import '../../../LogicTests/utils/Constants.dart' as TestConstants;



class DailyInfoTest extends IntegrationTestSuite {

  String currentProjectName;

  DailyInfoTest(this.currentProjectName);

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    if(args == null || !args.containsKey(TestConstants.PASSWORD)){
      throw Exception("Test not run since password not provided");
    }
    else{
      super.runTests();

      testWidgets("setUpForDailyInfoTests", (WidgetTester tester) async {
        await EmployeeHandler().logout();
        await EmployeeHandler()
            .login(email: ADMIN_EMAIL, password: args[TestConstants.PASSWORD]);
        await ProjectHandler().chooseProject(this.currentProjectName);
        await Future.delayed(Duration(seconds: 2));
      });

      testWidgets(ADD_WORK_ARR_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomWorkArrangement();
        final msg = await DailyInfoHandler().addOrOverrideWorkArrangement(toAdd);
        expect(msg, isEmpty);
        newWorkArrId = toAdd.id;
      });
      testWidgets(ADD_WORK_ARR_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().addOrOverrideWorkArrangement(null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_WORK_ARR_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomWorkArrangement();
        toAdd.freeTextInfo = null;
        final msg1 = await DailyInfoHandler().addOrOverrideWorkArrangement(toAdd);
        expect(msg1, isNotEmpty);
        toAdd.freeTextInfo = faker.lorem.sentence();
        toAdd.date = null;
        final msg2 = await DailyInfoHandler().addOrOverrideWorkArrangement(toAdd);
        expect(msg2, isNotEmpty);
      });

      testWidgets(ADD_DRIVE_ARR_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomDriveArrangement();
        final msg = await DailyInfoHandler().addOrOverrideDriveArrangement(toAdd);
        expect(msg, isEmpty);
        newDriveArrId = toAdd.id;
      });

      testWidgets(ADD_DRIVE_ARR_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().addOrOverrideDriveArrangement(null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_DRIVE_ARR_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomDriveArrangement();
        toAdd.freeTextInfo = null;
        final msg1 =
        await DailyInfoHandler().addOrOverrideDriveArrangement(toAdd);
        expect(msg1, isNotEmpty);
        toAdd.freeTextInfo = faker.lorem.sentence();
        toAdd.date = null;
        final msg2 =
        await DailyInfoHandler().addOrOverrideDriveArrangement(toAdd);
        expect(msg2, isNotEmpty);
      });

      testWidgets(ADD_FOLDER_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomImageFolder();
        final msg = await DailyInfoHandler().addOrOverrideMapFolder(toAdd);
        expect(msg, isEmpty);
        newImageFolderId = toAdd.id;
      });

      testWidgets(ADD_FOLDER_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().addOrOverrideMapFolder(null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_FOLDER_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomImageFolder();
        toAdd.date = null;
        final msg1 = await DailyInfoHandler().addOrOverrideMapFolder(toAdd);
        expect(msg1, isNotEmpty);
      });

      testWidgets(UPDATE_FOLDER, (WidgetTester tester) async {
        final toEdit = await DailyInfoHandler().getFolderByID(newImageFolderId);
        toEdit.date = DateTime.now();
        final msg = await DailyInfoHandler().updateFolderName(toEdit);
        expect(msg, isEmpty);
      });

      testWidgets(UPDATE_FOLDER_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().updateFolderName(null);
        expect(msg, isNotEmpty);
      });

      testWidgets(UPDATE_FOLDER_INVALID, (WidgetTester tester) async {
        final toEdit = await DailyInfoHandler().getFolderByID(newImageFolderId);
        toEdit.date = null;
        final msg = await DailyInfoHandler().updateFolderName(toEdit);
        expect(msg, isNotEmpty);
      });

      testWidgets(ALL_WORK_ARR, (WidgetTester tester) async {
        final all = await DailyInfoHandler()
            .allWorkArrangementsFromProjectAsItems(
            ProjectHandler().getCurrentProjectId());
        expect(all.length, 1);
        expect(all[0].id, newWorkArrId);
      });

      testWidgets(ALL_DRIVE_ARR, (WidgetTester tester) async {
        final all = await DailyInfoHandler()
            .allDriveArrangementsFromProjectAsItems(
            ProjectHandler().getCurrentProjectId());
        expect(all.length, 1);
        expect(all[0].id, newDriveArrId);
      });

      testWidgets(ALL_FOLDERS, (WidgetTester tester) async {
        final all = await DailyInfoHandler().allMapFoldersFromProjectAsItems(
            ProjectHandler().getCurrentProjectId());
        expect(all.length, 1);
        expect(all[0].id, newImageFolderId);
      });

      testWidgets(DELETE_WORK_ARR_SUCCESS, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().deleteWorkArrangement(newWorkArrId);
        expect(msg, isEmpty);
      });

      testWidgets(DELETE_WORK_ARR_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().deleteWorkArrangement(null);
        expect(msg, isNotEmpty);
        final msg1 = await DailyInfoHandler().deleteWorkArrangement("");
        expect(msg1, isNotEmpty);
      });

      testWidgets(DELETE_DRIVE_ARR_SUCCESS, (WidgetTester tester) async {
        final msg =
        await DailyInfoHandler().deleteDriveArrangement(newDriveArrId);
        expect(msg, isEmpty);
      });

      testWidgets(DELETE_DRIVE_ARR_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().deleteDriveArrangement(null);
        expect(msg, isNotEmpty);
        final msg1 = await DailyInfoHandler().deleteDriveArrangement("");
        expect(msg1, isNotEmpty);
      });

      testWidgets(DELETE_FOLDER_SUCCESS, (WidgetTester tester) async {
        final toEdit = await DailyInfoHandler().getFolderByID(newImageFolderId);
        final msg = await DailyInfoHandler().deleteMapFolders(toEdit);
        expect(msg, isEmpty);
      });

      testWidgets(DELETE_FOLDER_NULL, (WidgetTester tester) async {
        final msg = await DailyInfoHandler().deleteMapFolders(null);
        expect(msg, isNotEmpty);
      });
    }
  }
}

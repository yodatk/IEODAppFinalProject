import 'dart:math';

import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/constants/style_constants.dart' as StyleConstants;
import '../../lib/logger.dart' as Logger;
import '../../lib/logic/dailyInfoHandler.dart';
import '../../lib/models/image_folder.dart';
import '../../lib/models/image_reference.dart';
import '../../lib/screens/dailyInfo/constants/keys.dart' as DailyInfoKeys;
import '../../lib/utils/datetime_utils.dart';
import '../integration_test_suite.dart';
import '../utils/daily_info_utils.dart' as DailyInfoUtils;
import '../utils/general_utils.dart' as GeneralUtils;
import '../utils/registration_utils.dart' as RegistrationUtils;
import '../LogicTests/utils/Constants.dart' as TestConstants;

const siteName = "אתר לבדיקת דוחות";
const plotName = "חלקה לבדיקת דוחות";

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();
  tearDownAll(() {
    SystemNavigator.pop();
  });

  await DailyInfoTests().runTests();
}

final Map<String, dynamic> dailyEmergencyPractice = {
  "תיאור פעילות באתר": "תרגול באירוע חירום",
};

final Map<String, dynamic> dailyClearance = {
  "כלים באתר": "באגר",
};

const FIRST_IMAGE_NAME = "תמונה ראשונה בדיקה";
const SECOND_IMAGE_NAME = "תמונה ערוכה בדיקה";

class DailyInfoTests extends IntegrationTestSuite {
  String pickRandomDateInMonth({String first}) {
    final availableDates = [
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20",
      "21",
      "22",
      "23",
      "24",
      "25",
      "26",
      "27",
      "28"
    ];
    // generates a new Random object
    final _random = new Random();
    String day = availableDates[_random.nextInt(availableDates.length)];
    while (first != null && day == first.substring(0, 2)) {
      day = availableDates[_random.nextInt(availableDates.length)];
    }
    DateTime dt = DateTime.now().toLocal();
    if (dt.day == 31) {
      dt = dt.add(Duration(days: 1));
    }
    var date = dateToString(dt);
    date = day + date.substring(2);
    return date;
  }

  final String firstWorkArrangementInfo = faker.lorem.sentence();
  final String secondWorkArrangementInfo = faker.lorem.sentence();
  final String firstDriveArrangementInfo = faker.lorem.sentence();
  final String secondDriveArrangementInfo = faker.lorem.sentence();
  String firstDate;
  String secondDate;

  DailyInfoTests() {
    this.firstDate = pickRandomDateInMonth();
    this.secondDate = pickRandomDateInMonth(first: this.firstDate);
    Logger.info("first $firstDate");
    Logger.info("second $secondDate");
  }

  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();

    await workArrangementsTests(args[TestConstants.PASSWORD]);

    await driveArrangementsTests(args[TestConstants.PASSWORD]);

    await imageFolderTests(args[TestConstants.PASSWORD]);

    await dailyReportsTests(args[TestConstants.PASSWORD]);
  }

  Future<void> dailyReportsTests(String password) async {
    await addEmergencyPracticeDocumentation(password);

    await editEmergencyPracticeDocumentation(password);

    await deleteEmergencyPracticeDocumentation(password);

    await addDailyClearance(password);

    await editDailyClearance(password);

    await deleteDailyClearance(password);
  }

  Future<void> imageFolderTests(String password) async {
    await addImagesFolder(password);
    await renameFolder(password);
    //
    // // todo check if can be replaced
    // /// NEED TO UPLOAD MENUALY "IEOD_LOGO.jpeg" TO FIREBASE STORAGE BEFORE RUNNNING TESTS FOR THIS TO WORK
    // await insertingImageCheat();
    // // await insertImageToFolder();
    // // todo check if can be replaced
    //
    // await renameImage();
    // await fromRegularEmployeeMapFolder();
    // await deleteImage();
    await deleteFolder(password);
  }

  Future<void> driveArrangementsTests(String password) async {
    await addDriveArrangement(password);

    await editDriveArrangement(password);

    await fromRegularEmployeeDriveArrangement(password);

    await deleteDriveArrangement(password);
  }

  Future<void> workArrangementsTests(String password) async {
    await addWorkArrangement(password);

    await editWorkArrangement(password);

    await fromRegularEmployeeWorkArrangement(password);

    await deleteWorkArrangement(password);
  }

  Future<void> insertingImageCheat(String password) async {
    testWidgets("cheat insert Image", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      ImageFolder folder = await DailyInfoHandler().getFolderByDate(
          DateTime.parse(convertVisualDateToParseDate(secondDate)));
      if (folder == null) {
        throw Exception("folder was null");
      }
      ImageReference toAdd = ImageReference(
          name: FIRST_IMAGE_NAME,
          fullPath: "IEOD_LOGO.jpeg",
          // TODO UPDATE URL HERE EACH RUN
          imageUrl:
              "https://firebasestorage.googleapis.com/v0/b/ieodapp.appspot.com/o/IEOD_LOGO.jpeg?alt=media&token=8ab20b0d-fbf0-46ac-8790-06b4bdae6f66",
          timeModified: DateTime.now().toLocal());
      final msg = await DailyInfoHandler()
          .addingSingleReference(folder: folder, refToUpdate: toAdd);
      Logger.info("msg : $msg");
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
    });
  }

  Future<void> addDailyReport(WidgetTester tester, String reportType, String password) async {
    await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToDailyReportsPage(tester: tester);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToSpecificDailyReportsPage(
        tester: tester, key: reportType);
    await tester.pumpAndSettle();
    final Finder addBtn =
        find.byKey(Key(DailyInfoKeys.ADD_DAILY_REPORT)); // add report button
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    await DailyInfoUtils.submitReport(tester: tester);
    await tester.pumpAndSettle();
    expect(
        find.text(
            "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
        findsOneWidget);
    await GeneralUtils.logoutFromAnyPage(tester);
    await tester.pumpAndSettle();
  }

  Future<void> addEmergencyPracticeDocumentation(String password) async {
    testWidgets("Add Emergency Practice Documentation",
        (WidgetTester tester) async {
      await addDailyReport(
          tester, DailyInfoKeys.EMERGENCY_PRACTICE_DOCUMENTATION_BTN, password);
      Logger.info("added Emergency Practice Documentation successfully");
    });
  }

  Future<void> addDailyClearance(String password) async {
    testWidgets("Add Daily Clearance Report", (WidgetTester tester) async {
      await addDailyReport(tester, DailyInfoKeys.DAILY_CLEARANCE_BTN, password);
      Logger.info("added Daily Clearance Report successfully");
    });
  }

  Future<void> editDailyReport(
      {WidgetTester tester,
      String reportType, String password,
      Map<String, dynamic> report}) async {
    await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToDailyReportsPage(tester: tester);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToSpecificDailyReportsPage(
        tester: tester, key: reportType);
    await tester.pumpAndSettle();
    await DailyInfoUtils.tapSpecificReport(
        tester: tester,
        timeOfReport: dateToString(DateTime.now().toLocal()),
        editor: RegistrationUtils.ADMIN_NAME);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterEditReportMode(tester: tester);
    await tester.pumpAndSettle();
    await DailyInfoUtils.fillReport(tester: tester, report: report);
    await tester.pumpAndSettle();
    await DailyInfoUtils.submitReport(tester: tester);
    await tester.pumpAndSettle();
    expect(
        find.text(
            "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
        findsOneWidget);

    await DailyInfoUtils.tapSpecificReport(
        tester: tester,
        timeOfReport: dateToString(DateTime.now().toLocal()),
        editor: RegistrationUtils.ADMIN_NAME);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterEditReportMode(tester: tester);
    await tester.pumpAndSettle();
    report.values.forEach((element) {
      expect(find.text(element as String), findsOneWidget);
    });

    await GeneralUtils.logoutFromAnyPage(tester);
    await tester.pumpAndSettle();
  }

  Future<void> editEmergencyPracticeDocumentation(String password) async {
    testWidgets("Edit Emergency Practice Documentation",
        (WidgetTester tester) async {
      await editDailyReport(
          tester: tester,
          password: password,
          report: dailyEmergencyPractice,
          reportType: DailyInfoKeys.EMERGENCY_PRACTICE_DOCUMENTATION_BTN);
      Logger.info("edited Emergency Practice Documentation successfully");
    });
  }

  Future<void> editDailyClearance(String password) async {
    testWidgets("Edit Daily Clearance Report", (WidgetTester tester) async {
      await editDailyReport(
          tester: tester,
          password: password,
          report: dailyClearance,
          reportType: DailyInfoKeys.DAILY_CLEARANCE_BTN);
      Logger.info("edited Daily Clearance Report successfully");
    });
  }

  Future<void> deleteDailyReport(WidgetTester tester, String reportType, String password) async {
    await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToDailyReportsPage(tester: tester);
    await tester.pumpAndSettle();
    await DailyInfoUtils.enterToSpecificDailyReportsPage(
        tester: tester, key: reportType);
    await tester.pumpAndSettle();
    await DailyInfoUtils.deleteSpecificReport(
        tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
    await tester.pumpAndSettle();
    expect(
        find.text(
            "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
        findsNothing);
    await GeneralUtils.logoutFromAnyPage(tester);
    await tester.pumpAndSettle();
  }

  Future<void> deleteEmergencyPracticeDocumentation(String password) async {
    testWidgets("delete Emergency Practice Documentation",
        (WidgetTester tester) async {
      await deleteDailyReport(
          tester, DailyInfoKeys.EMERGENCY_PRACTICE_DOCUMENTATION_BTN, password);
      Logger.info("deleted Emergency Practice Documentation successfully");
    });
  }

  Future<void> deleteDailyClearance(String password) async {
    testWidgets("delete Daily Clearance Report", (WidgetTester tester) async {
      await deleteDailyReport(tester, DailyInfoKeys.DAILY_CLEARANCE_BTN, password);
      Logger.info("deleted Daily Clearance Report successfully");
    });
  }

  ///
  /// Trying to add new work arrangement. EXPECTED: succeed
  ///
  Future<void> addWorkArrangement(String password) async {
    testWidgets("Add Work Arrangement", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToWorkArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterAddArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.fillArrangement(
          tester: tester,
          dateKey: DailyInfoKeys.DATE_PICKER_WORK_ARRANGEMENT,
          infoKey: DailyInfoKeys.INFO_WORK_ARRANGEMENT,
          info: firstWorkArrangementInfo,
          date: DateTime.parse(convertVisualDateToParseDate(
            firstDate,
          )));
      await tester.pumpAndSettle();
      await DailyInfoUtils.submitArrangementForm(
          tester: tester,
          keySubmit: DailyInfoKeys.SUBMIT_WORK_ARRANGEMENT_EDIT);
      await tester.pumpAndSettle();
      expect(find.text(firstDate), findsOneWidget);
      await DailyInfoUtils.tapAndEnterEditModeWorkArrangement(
        tester: tester,
        dateAsString: firstDate,
        editor: RegistrationUtils.ADMIN_NAME,
      );
      await tester.pumpAndSettle();
      expect(find.text(firstWorkArrangementInfo), findsOneWidget);

      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Added Work Arrangement Successfully");
    });
  }

  ///
  /// Trying to edit an existing work arrangement. EXPECTED: succeed
  ///
  Future editWorkArrangement(String password) async {
    testWidgets(
      "Edit Work Arrangement",
      (WidgetTester tester) async {
        await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
        await tester.pumpAndSettle();

        await DailyInfoUtils.enterToWorkArrangementPage(tester: tester);
        await tester.pumpAndSettle();

        await DailyInfoUtils.tapAndEnterEditModeWorkArrangement(
          tester: tester,
          dateAsString: firstDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.text(firstWorkArrangementInfo), findsOneWidget);
        await DailyInfoUtils.fillArrangement(
            tester: tester,
            dateKey: DailyInfoKeys.DATE_PICKER_WORK_ARRANGEMENT,
            infoKey: DailyInfoKeys.INFO_WORK_ARRANGEMENT,
            info: secondWorkArrangementInfo,
            date: DateTime.parse(convertVisualDateToParseDate(secondDate)));
        await tester.pumpAndSettle();
        await DailyInfoUtils.submitArrangementForm(
            tester: tester,
            keySubmit: DailyInfoKeys.SUBMIT_WORK_ARRANGEMENT_EDIT);
        await tester.pumpAndSettle();
        expect(find.text(secondDate), findsOneWidget);
        await DailyInfoUtils.tapAndEnterEditModeWorkArrangement(
          tester: tester,
          dateAsString: secondDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.text(secondWorkArrangementInfo), findsOneWidget);
        await GeneralUtils.logoutFromAnyPage(tester);
        await tester.pumpAndSettle();
        Logger.info("Edited Work Arrangement Successfully");
      },
    );
  }

  ///
  /// checking regular user can't edit or delete arrangement, but can watch it
  ///
  Future fromRegularEmployeeWorkArrangement(String password) async {
    testWidgets(
      "Regular Employee Work Arrangement",
      (WidgetTester tester) async {
        await startTestInDailyInfoScreen(
            tester, RegistrationUtils.REGULAR_EMAIL, password);
        await tester.pumpAndSettle();
        await DailyInfoUtils.enterToWorkArrangementPage(tester: tester);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.add), findsNothing);

        await DailyInfoUtils.tapSpecificArrangementTile(
          tester: tester,
          dateAsString: secondDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        final Finder watchBtn =
            find.byIcon(StyleConstants.ICON_WORK_ARRANGEMENT);
        await tester.tap(watchBtn);
        await tester.pumpAndSettle();
        expect(find.text(secondWorkArrangementInfo), findsOneWidget);

        await GeneralUtils.logoutFromAnyPage(tester);
        await tester.pumpAndSettle();
        Logger.info("Watch Work Arrangement as Regular Employee Successfully");
      },
    );
  }

  ///
  /// Trying to delete work arrangement
  ///
  Future deleteWorkArrangement(String password) async {
    testWidgets("Delete Work Arrangement", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToWorkArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.tapAndDeleteArrangement(
        tester: tester,
        dateAsString: secondDate,
        editor: RegistrationUtils.ADMIN_NAME,
      );
      await tester.pumpAndSettle();
      expect(find.text(secondDate), findsNothing);

      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Deleted Work Arrangement Successfully");
    });
  }

  ///
  /// Trying to add new drive arrangement. EXPECTED: succeed
  ///
  Future addDriveArrangement(String password) async {
    testWidgets("Add Drive Arrangement", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToDriveArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterAddArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.fillArrangement(
          tester: tester,
          dateKey: DailyInfoKeys.DATE_PICKER_DRIVE_ARRANGEMENT,
          infoKey: DailyInfoKeys.INFO_DRIVE_ARRANGEMENT,
          info: firstDriveArrangementInfo,
          date: DateTime.parse(convertVisualDateToParseDate(
            firstDate,
          )));
      await tester.pumpAndSettle();
      await DailyInfoUtils.submitArrangementForm(
          tester: tester,
          keySubmit: DailyInfoKeys.SUBMIT_DRIVE_ARRANGEMENT_EDIT);
      await tester.pumpAndSettle();
      expect(find.text(firstDate), findsOneWidget);
      await DailyInfoUtils.tapAndEnterEditModeDriveArrangement(
        tester: tester,
        dateAsString: firstDate,
        editor: RegistrationUtils.ADMIN_NAME,
      );
      await tester.pumpAndSettle();
      expect(find.text(firstDriveArrangementInfo), findsOneWidget);

      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Added Drive Arrangement Successfully");
    });
  }

  ///
  /// Trying to edit an existing drive arrangement. EXPECTED: succeed
  ///
  Future editDriveArrangement(String password) async {
    testWidgets(
      "Edit Drive Arrangement",
      (WidgetTester tester) async {
        await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
        await tester.pumpAndSettle();

        await DailyInfoUtils.enterToDriveArrangementPage(tester: tester);
        await tester.pumpAndSettle();

        await DailyInfoUtils.tapAndEnterEditModeDriveArrangement(
          tester: tester,
          dateAsString: firstDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.text(firstDriveArrangementInfo), findsOneWidget);
        await DailyInfoUtils.fillArrangement(
            tester: tester,
            dateKey: DailyInfoKeys.DATE_PICKER_DRIVE_ARRANGEMENT,
            infoKey: DailyInfoKeys.INFO_DRIVE_ARRANGEMENT,
            info: secondDriveArrangementInfo,
            date: DateTime.parse(convertVisualDateToParseDate(secondDate)));
        await tester.pumpAndSettle();
        await DailyInfoUtils.submitArrangementForm(
            tester: tester,
            keySubmit: DailyInfoKeys.SUBMIT_DRIVE_ARRANGEMENT_EDIT);
        await tester.pumpAndSettle();
        expect(find.text(secondDate), findsOneWidget);
        await DailyInfoUtils.tapAndEnterEditModeDriveArrangement(
          tester: tester,
          dateAsString: secondDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.text(secondDriveArrangementInfo), findsOneWidget);
        await GeneralUtils.logoutFromAnyPage(tester);
        await tester.pumpAndSettle();
        Logger.info("Edited Drive Arrangement Successfully");
      },
    );
  }

  ///
  /// checking regular user can't edit or delete arrangement, but can watch it
  ///
  Future fromRegularEmployeeDriveArrangement(String password) async {
    testWidgets(
      "Regular Employee Drive Arrangement",
      (WidgetTester tester) async {
        await startTestInDailyInfoScreen(
            tester, RegistrationUtils.REGULAR_EMAIL, password);
        await tester.pumpAndSettle();
        await DailyInfoUtils.enterToDriveArrangementPage(tester: tester);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.add), findsNothing);

        await DailyInfoUtils.tapSpecificArrangementTile(
          tester: tester,
          dateAsString: secondDate,
          editor: RegistrationUtils.ADMIN_NAME,
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        final Finder watchBtn =
            find.byIcon(StyleConstants.ICON_DRIVE_ARRANGEMENT);
        await tester.tap(watchBtn);
        await tester.pumpAndSettle();
        expect(find.text(secondDriveArrangementInfo), findsOneWidget);

        await GeneralUtils.logoutFromAnyPage(tester);
        await tester.pumpAndSettle();
        Logger.info("Watch Drive Arrangement as Regular Employee Successfully");
      },
    );
  }

  ///
  /// Trying to delete drive arrangement. Expected: succeed
  ///
  Future deleteDriveArrangement(String password) async {
    testWidgets("Delete Drive Arrangement", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToDriveArrangementPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.tapAndDeleteArrangement(
          tester: tester,
          dateAsString: secondDate,
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(find.text(secondDate), findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Deleted Drive Arrangement Successfully");
    });
  }

  ///
  /// Using [tester] to enter to the daily info menu, with the [Employee] which have the [employeeEmail]
  ///
  Future<void> startTestInDailyInfoScreen(
      WidgetTester tester, String employeeEmail, String password) async {
    await tester.pumpWidget(GeneralUtils.getMainWidget());
    await tester.pumpAndSettle();
    await RegistrationUtils.loginUser(tester: tester, email: employeeEmail, password: password);
    await tester.pumpAndSettle();
    await GeneralUtils.enterDailyInfoScreen(tester);
    await tester.pumpAndSettle();
  }

  ///
  /// Using [tester] to add an image folder to Project
  ///
  Future<void> addImagesFolder(String password) async {
    testWidgets("Add Image Folder", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.addImageFolder(
          tester: tester,
          date: DateTime.parse(convertVisualDateToParseDate(firstDate)));
      await tester.pumpAndSettle();
      expect(find.text(firstDate), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Added Image Folder Successfully ");
    });
  }

  ///
  /// Using [tester] to rename an image folder of Project
  ///
  Future<void> renameFolder(String password) async {
    testWidgets("Rename Image Folder", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.editNameOfImageFolder(
          tester: tester,
          oldDateAsString: firstDate,
          newDate: DateTime.parse(convertVisualDateToParseDate(secondDate)));
      expect(find.text(secondDate), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Rename Image Folder Successfully ");
    });
  }

  ///
  /// Using [tester] to add an image to a Image Folder to Project
  ///
  Future<void> insertImageToFolder(String password) async {
    testWidgets("Insert Image To Folder", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();

      await DailyInfoUtils.addImageToFolderWithCamera(
        tester: tester,
        dateAsString: secondDate,
        imageName: FIRST_IMAGE_NAME,
      );
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.text(FIRST_IMAGE_NAME), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Insert Image Folder Successfully ");
    });
  }

  ///
  /// Using [tester] to rename an image in an image folder
  ///
  Future<void> renameImage(String password) async {
    testWidgets("Rename Image", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterSpecificFolderPage(
          tester: tester, dateAsString: secondDate);
      await tester.pumpAndSettle();
      await DailyInfoUtils.editNameOfImage(
          tester: tester, newName: SECOND_IMAGE_NAME);
      await tester.pumpAndSettle();
      expect(find.text(SECOND_IMAGE_NAME), findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Rename Image Successfully ");
    });
  }

  ///
  /// Using [tester] to check that all buttons appear or disappear to a Regular Employee properly
  ///
  Future<void> fromRegularEmployeeMapFolder(String password) async {
    testWidgets("From Regular User Test", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.REGULAR_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      expect(find.text(secondDate), findsOneWidget);
      await DailyInfoUtils.tapSpecificImageFolderTile(
          tester: tester, dateAsString: secondDate);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      await tester.tap(find.byIcon(StyleConstants.ICON_DAILY_IMAGES));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("From Regular User Test Finished Successfully ");
    });
  }

  ///
  /// Using [tester] to delete an image from an image Folder
  ///
  Future<void> deleteImage(String password) async {
    testWidgets("Delete Image", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterSpecificFolderPage(
          tester: tester, dateAsString: secondDate);
      await tester.pumpAndSettle();
      await DailyInfoUtils.deleteImage(
          tester: tester, imageName: SECOND_IMAGE_NAME);
      await tester.pumpAndSettle();
      expect(find.text(SECOND_IMAGE_NAME), findsNothing);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Delete Image Successfully ");
    });
  }

  ///
  /// Using [tester] to delete an image folder from project
  ///
  Future<void> deleteFolder(String password) async {
    testWidgets("Delete Image Folder", (WidgetTester tester) async {
      await startTestInDailyInfoScreen(tester, RegistrationUtils.ADMIN_EMAIL, password);
      await tester.pumpAndSettle();
      await DailyInfoUtils.enterToImagesFolderPage(tester: tester);
      await tester.pumpAndSettle();
      await DailyInfoUtils.deleteImageFolder(
          tester: tester, dateAsString: secondDate);
      await tester.pumpAndSettle();
      expect(find.text(secondDate), findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Delete Image Folder Successfully ");
    });
  }
}

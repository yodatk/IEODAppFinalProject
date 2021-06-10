import 'package:IEODApp/screens/managesSiteAndPlots/constants/keys.dart';
import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/logger.dart' as Logger;
import '../../lib/utils/datetime_utils.dart';
import '../integration_test_suite.dart';
import '../utils/general_utils.dart' as GeneralUtils;
import '../utils/registration_utils.dart' as RegistrationUtils;
import '../utils/site_and_plot_utils.dart' as PlotAndSitesUtils;
import '../LogicTests/utils/Constants.dart' as TestConstants;

const siteName = "אתר לבדיקת דוחות";
const plotName = "חלקה לבדיקת דוחות";

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FireStoreDataService().changeEnvironmentForTesting();
  tearDownAll(() {
    SystemNavigator.pop();
  });

  await ReportsTests().runTests();
}

class ReportsTests extends IntegrationTestSuite {
  final Map<String, dynamic> reportMechanical = {
    "כלים": "טרקטור",
    "משימות": "לחפור מלא",
  };

  Map<String, dynamic> reportQualityMechanical = {
    "פעולות": "הוצאת גדר",
    "שם המפעיל": "חמודי קטן",
  };

  Map<String, dynamic> reportQualityManual = {
    "פעולות": "הוצאת גדר",
  };

  Map<String, dynamic> reportBunkersClearance = {
    "חתימת מנהל קבוצה": "חתימה",
  };

  Map<String, dynamic> reportDeepTargets = {
    "חתימת מנהל קבוצה": "חתימה",
  };

  Map<String, dynamic> reportGeneralMechanical = {
    "שם מנהל": "אמיר",
    "תפקיד": "מנהל",
  };

  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();
    // await addMechanicalReport();
    //
    // await editMechanicalReport();
    //
    // await deleteMechanicalReport();

    await addGeneralMechanicalReport(args[TestConstants.PASSWORD]);

    await editGeneralMechanicalReport(args[TestConstants.PASSWORD]);

    await deleteGeneralMechanicalReport(args[TestConstants.PASSWORD]);

    await addManualQualControl(args[TestConstants.PASSWORD]);

    await editManualQualControl(args[TestConstants.PASSWORD]);

    await deleteQualityManualReport(args[TestConstants.PASSWORD]);

    await addBunkersClearanceReport(args[TestConstants.PASSWORD]);

    await editBunkersClearanceReport(args[TestConstants.PASSWORD]);

    await deleteBunkersClearanceReport(args[TestConstants.PASSWORD]);

    await addDeepTargets(args[TestConstants.PASSWORD]);

    await editDeepTargets(args[TestConstants.PASSWORD]);

    await deleteDeepTargets(args[TestConstants.PASSWORD]);

    await addQualityMechanicalReport(args[TestConstants.PASSWORD]);

    await editQualityMechanicalReport(args[TestConstants.PASSWORD]);

    await deleteQualityMechanicalReport(args[TestConstants.PASSWORD]);
  }

  ///
  /// Trying to add new mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future addMechanicalReport(String password) async {
    testWidgets("add Mechanical Report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.addSite(tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.addPlotInSpecificSite(
          tester: tester, plotName: plotName, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added mechanical reports successfully");
    });
  }

  ///
  /// Trying to edit existing mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future editMechanicalReport(String password) async {
    testWidgets(
      "edit Mechanical Report",
      (WidgetTester tester) async {
        await tester.pumpWidget(GeneralUtils.getMainWidget());

        await tester.pumpAndSettle();

        await RegistrationUtils.loginUser(
            tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
        await tester.pumpAndSettle();
        await GeneralUtils.enterPlotsAndSiteScreen(tester);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.tapSpecificSite(
            tester: tester, siteName: siteName);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.tapSpecificPlot(
            tester: tester, plotName: plotName);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.enterPlotsReport(
          tester: tester,
          plotName: plotName,
        );
        await PlotAndSitesUtils.enterToMechanicalReports(tester: tester);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.tapSpecificReport(
            tester: tester,
            timeOfReport: dateToString(DateTime.now()),
            editor: RegistrationUtils.ADMIN_NAME);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.enterEditReportMode(tester: tester);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.fillReport(
            tester: tester, report: reportMechanical);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.submitReport(tester: tester);
        await tester.pumpAndSettle();
        expect(
            find.text(
                "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
            findsOneWidget);

        await PlotAndSitesUtils.tapSpecificReport(
            tester: tester,
            timeOfReport: dateToString(DateTime.now()),
            editor: RegistrationUtils.ADMIN_NAME);
        await tester.pumpAndSettle();
        await PlotAndSitesUtils.enterEditReportMode(tester: tester);
        await tester.pumpAndSettle();
        reportMechanical.values.forEach((element) {
          expect(find.text(element as String), findsOneWidget);
        });

        await GeneralUtils.logoutFromAnyPage(tester);
        await tester.pumpAndSettle();
        Logger.info("edited mechanical reports successfully");
      },
    );
  }

  ///
  /// Trying to delete mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future deleteMechanicalReport(String password) async {
    testWidgets("delete Mechanical Report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);

      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted mechanical reports successfully");
    });
  }

  ///
  /// Trying to add new general mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future addGeneralMechanicalReport(String password) async {
    testWidgets("add general mechanical report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.addSite(tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.addPlotInSpecificSite(
          tester: tester, plotName: plotName, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToGeneralMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added general mechanical reports successfully");
    });
  }

  ///
  /// Trying to edit existing general mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future editGeneralMechanicalReport(String password) async {
    testWidgets("edit general mechanical report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToGeneralMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.fillReport(
          tester: tester, report: reportGeneralMechanical);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);

      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();
      reportGeneralMechanical.values.forEach((element) {
        expect(find.text(element as String), findsOneWidget);
      });
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited general mechanical reports successfully");
    });
  }

  ///
  /// Trying to delete existing general mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future deleteGeneralMechanicalReport(String password) async {
    testWidgets("delete general mechanical report",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToGeneralMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted general mechanical reports successfully");
    });
  }

  ///
  /// Trying to add new manual quality control report to a certain plot. EXPECTED: succeed
  ///
  Future addManualQualControl(String password) async {
    testWidgets("add quality manual report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityManualReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added quality manual reports successfully");
    });
  }

  ///
  /// Trying to edit existing quality manual report to a certain plot. EXPECTED: succeed
  ///
  Future editManualQualControl(String password) async {
    testWidgets("edit quality manual report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityManualReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.fillReport(
          tester: tester, report: reportQualityManual);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);

      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();
      reportQualityManual.values.forEach((element) {
        expect(find.text(element as String), findsOneWidget);
      });
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited quality manual reports successfully");
    });
  }

  ///
  /// Trying to delete  existing quality mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future deleteQualityManualReport(String password) async {
    testWidgets("delete quality manual report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityManualReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted  quality manual reports successfully");
    });
  }

  ///
  /// Trying to add new bunkers clearance report to a certain plot. EXPECTED: succeed
  ///
  Future addBunkersClearanceReport(String password) async {
    testWidgets("add bunkers clearance report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToBunkersClearanceReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added bunkers clearance report successfully");
    });
  }

  ///
  /// Trying to edit existing bunkers clearance report to a certain plot. EXPECTED: succeed
  ///
  Future editBunkersClearanceReport(String password) async {
    testWidgets("edit bunkers clearance report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToBunkersClearanceReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.fillTableReport(
          tester: tester, report: reportBunkersClearance);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitTableReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited  bunkers clearance report successfully");
    });
  }

  ///
  /// Trying to delete  existing bunkers clearance report to a certain plot. EXPECTED: succeed
  ///
  Future deleteBunkersClearanceReport(String password) async {
    testWidgets("delete bunkers clearance report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToBunkersClearanceReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted bunkers clearance report successfully");
    });
  }

  ///
  /// Trying to add new deep targets report to a certain plot. EXPECTED: succeed
  ///
  Future addDeepTargets(String password) async {
    testWidgets("add deep targets report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToDeepTargetsReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added deep targets report successfully");
    });
  }

  ///
  /// Trying to edit existing deep targets report to a certain plot. EXPECTED: succeed
  ///
  Future editDeepTargets(String password) async {
    testWidgets("edit deep targets report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToDeepTargetsReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.fillTableReport(
          tester: tester, report: reportDeepTargets);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitTableReport(tester: tester);
      await tester.pumpAndSettle();
      //"${dateToString(this.timeCreated)} - ${this.creator.name ?? "?"}"

      expect(
          find.text(
              "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited deep targets report successfully");
    });
  }

  ///
  /// Trying to delete  existing deep targets report to a certain plot. EXPECTED: succeed
  ///
  Future deleteDeepTargets(String password) async {
    testWidgets("delete deep targets report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToDeepTargetsReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted deep targets report successfully");
    });
  }

  ///
  /// Trying to add new quality mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future addQualityMechanicalReport(String password) async {
    testWidgets("add quality mechanical report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      final Finder addBtn = find.byKey(Key(ADD_REPORT)); // add report button
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("added quality mechanical reports successfully");
    });
  }

  ///
  /// Trying to edit existing quality mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future editQualityMechanicalReport(String password) async {
    testWidgets("edit quality mechanical report", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now().toLocal()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();

      await PlotAndSitesUtils.fillReport(
          tester: tester, report: reportQualityMechanical);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.submitReport(tester: tester);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsOneWidget);

      await PlotAndSitesUtils.tapSpecificReport(
          tester: tester,
          timeOfReport: dateToString(DateTime.now().toLocal()),
          editor: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterEditReportMode(tester: tester);
      await tester.pumpAndSettle();
      reportQualityMechanical.values.forEach((element) {
        expect(find.text(element as String), findsOneWidget);
      });
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edited quality mechanical reports successfully");
    });
  }

  ///
  /// Trying to delete  existing quality mechanical report to a certain plot. EXPECTED: succeed
  ///
  Future deleteQualityMechanicalReport(String password) async {
    testWidgets("delete quality mechanical report",
        (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          tester: tester, email: RegistrationUtils.ADMIN_EMAIL, password: password);
      await tester.pumpAndSettle();
      await GeneralUtils.enterPlotsAndSiteScreen(tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificSite(
          tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.tapSpecificPlot(
          tester: tester, plotName: plotName);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.enterPlotsReport(
        tester: tester,
        plotName: plotName,
      );
      await PlotAndSitesUtils.enterToQualityMechanicalReports(tester: tester);
      await tester.pumpAndSettle();
      await PlotAndSitesUtils.deleteSpecificReport(
          tester: tester, authorName: RegistrationUtils.ADMIN_NAME);
      await tester.pumpAndSettle();
      expect(
          find.text(
              "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}"),
          findsNothing);
      await GeneralUtils.pageBack(tester);
      await tester.pumpAndSettle();
      await GeneralUtils.pageBack(tester);
      await tester.pumpAndSettle();

      // cleaning up
      await PlotAndSitesUtils.deleteSite(tester: tester, siteName: siteName);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("deleted quality mechanical reports successfully");
    });
  }
}

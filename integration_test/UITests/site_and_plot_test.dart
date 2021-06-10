import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/models/stripStatus.dart';
import '../utils/general_utils.dart' as GeneralUtils;
import '../utils/registration_utils.dart' as RegistrationUtils;
import '../utils/site_and_plot_utils.dart' as SiteAndPlotUtils;
import '../integration_test_suite.dart';
import '../LogicTests/utils/Constants.dart' as TestConstants;
import '../../lib/logger.dart' as Logger;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  FireStoreDataService().changeEnvironmentForTesting();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  tearDownAll(() {
    SystemNavigator.pop();
  });

  await SitesAndPlotsTests().runTests();
}

const SITE_AND_PLOT_NAME = "בדיקה";
const EMPLOYEE_FOR_FIRST_ACTION = '  שני סמסון  ';
const FIRST_ACTION_LABEL = "  עובד בפעולה ראשונה  ";

class SitesAndPlotsTests extends IntegrationTestSuite {
  final Finder sitesPageNavigator = find.byIcon(Icons.rule);

  Future<void> runTests({Map<String, String> args = null}) async {
    super.runTests();
    await addSiteAndPlot(args[TestConstants.PASSWORD]);
    await addNewStrip(args[TestConstants.PASSWORD]);
    await editStrip(args[TestConstants.PASSWORD]);
    await deleteStrip(args[TestConstants.PASSWORD]);
    await deleteSiteAndPlot(args[TestConstants.PASSWORD]);
  }

  Future<void> addSiteAndPlot(String password) async {
    testWidgets("add new site and new plot", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          email: RegistrationUtils.ADMIN_EMAIL, tester: tester, password: password);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterSitesListPage(tester: tester);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.addSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();
      await SiteAndPlotUtils.tapSpecificSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.addPlotInSpecificSite(
          tester: tester,
          siteName: SITE_AND_PLOT_NAME,
          plotName: SITE_AND_PLOT_NAME);

      await GeneralUtils.logoutFromAnyPage(tester);

      Logger.info("Add Site and Plot Successfully ");
    });
  }

  Future<void> addNewStrip(String password) async {
    testWidgets("add new strip", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          email: RegistrationUtils.ADMIN_EMAIL, tester: tester, password: password);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterSitesListPage(tester: tester);

      await SiteAndPlotUtils.tapSpecificSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificPlot(
          tester: tester, plotName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterManualReport(
          tester: tester, plotName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.addStripInSpecificPlot(
          tester: tester, plotName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      Logger.info("Add Strip Successfully");
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
    });
  }

  Future deleteStrip(String password) async {
    testWidgets("delete strip", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          email: RegistrationUtils.ADMIN_EMAIL, tester: tester, password: password);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterSitesListPage(tester: tester);

      await SiteAndPlotUtils.tapSpecificSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificPlot(
          tester: tester, plotName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterManualReport(
          tester: tester, plotName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificStatusStrip(
          tester: tester,
          status: generateTitleFromStripStatus(StripStatus.IN_FIRST));

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificStrip(
          tester: tester, stripName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.deleteStrip(tester: tester);
      await tester.pumpAndSettle();
      expect(find.text(SITE_AND_PLOT_NAME), findsNothing);
      await tester.pumpAndSettle();
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("Delete Strip Successfully");
    });
  }

  Future editStrip(String password) async {
    testWidgets("edit strip", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          email: RegistrationUtils.ADMIN_EMAIL, tester: tester, password: password);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterSitesListPage(tester: tester);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificPlot(
          tester: tester, plotName: SITE_AND_PLOT_NAME);
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterManualReport(
          tester: tester, plotName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificStatusStrip(
        tester: tester,
        status: generateTitleFromStripStatus(StripStatus.NONE),
      );
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificStrip(
          tester: tester, stripName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      final Finder firstEmployeeDropDown = find.text(FIRST_ACTION_LABEL);
      // find.byWidgetPredicate((widget) =>
      //     widget is DropdownSearch<HandWorker> &&
      //     widget.label.startsWith(FIRST_ACTION_LABEL));
      await tester.pumpAndSettle();
      await tester.tap(firstEmployeeDropDown);
      await tester.pumpAndSettle();

      expect(find.text(EMPLOYEE_FOR_FIRST_ACTION), isNotNull);
      await tester.tap(find.text(EMPLOYEE_FOR_FIRST_ACTION));
      await tester.pumpAndSettle();

      await SiteAndPlotUtils.submitEditStrip(tester: tester);
      await tester.pumpAndSettle();
      expect(find.text(generateTitleFromStripStatus(StripStatus.NONE)),
          findsNothing);
      expect(find.text(generateTitleFromStripStatus(StripStatus.IN_FIRST)),
          findsOneWidget);
      await SiteAndPlotUtils.tapSpecificStatusStrip(
          tester: tester,
          status: generateTitleFromStripStatus(StripStatus.IN_FIRST));

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.tapSpecificStrip(
          tester: tester, stripName: SITE_AND_PLOT_NAME);
      expect(find.text(EMPLOYEE_FOR_FIRST_ACTION), isNotNull);

      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
      Logger.info("edit strip successfully");
    });
  }

  Future<void> deleteSiteAndPlot(String password) async {
    testWidgets("delete  site and plot", (WidgetTester tester) async {
      await tester.pumpWidget(GeneralUtils.getMainWidget());

      await tester.pumpAndSettle();

      await RegistrationUtils.loginUser(
          email: RegistrationUtils.ADMIN_EMAIL, tester: tester, password: password);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.enterSitesListPage(tester: tester);

      await SiteAndPlotUtils.tapSpecificSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.deletePlot(
          tester: tester, plotName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();

      await SiteAndPlotUtils.deleteSite(
          tester: tester, siteName: SITE_AND_PLOT_NAME);

      await tester.pumpAndSettle();
      Logger.info("Delete Site and Plot Successfully");
      await GeneralUtils.logoutFromAnyPage(tester);
      await tester.pumpAndSettle();
    });
  }
}

// flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/app_test.dart

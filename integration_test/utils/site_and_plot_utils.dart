library site_and_plot_utils;

import 'package:IEODApp/constants/style_constants.dart' as StyleConstants;
import 'package:IEODApp/models/stripStatus.dart';
import 'package:IEODApp/screens/constants/keys.dart' as MainScreenKeys;
import 'package:IEODApp/screens/managesSiteAndPlots/all_sites_plots_screen/widgets/plot_list_tile.dart';
import 'package:IEODApp/screens/managesSiteAndPlots/all_sites_plots_screen/widgets/site_list_tile.dart';
import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/widgets/edit_strip_form.dart';
import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/widgets/status_strip_list_tile.dart';
import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/widgets/strip_tile_list.dart';
import 'package:IEODApp/screens/managesSiteAndPlots/constants/keys.dart'
    as PlotsAndSitesKeys;
import 'package:IEODApp/screens/managesSiteAndPlots/specific_report_screen/widgets/report_list_tile.dart';
import 'package:IEODApp/utils/datetime_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final Finder sitesPageNavigator = find.byIcon(StyleConstants.ICON_PLOT);
final Finder submitBtn = find.byKey(Key(PlotsAndSitesKeys.SUBMIT_REPORT_BTN));

Future<void> enterSitesListPage({WidgetTester tester}) async {
  expect(find.byKey(Key(MainScreenKeys.MAIN_MENU_LIST)), findsOneWidget);
  await tester.pumpAndSettle();

  expect(find.byIcon(StyleConstants.ICON_PLOT), findsOneWidget);
  await tester.pumpAndSettle();

  await tester.tap(sitesPageNavigator);
  await tester.pumpAndSettle();

  expect(find.byKey(Key(PlotsAndSitesKeys.SITE_LIST_LOCATION)), findsOneWidget);
  await tester.pumpAndSettle();
}

Future<void> addSite({WidgetTester tester, String siteName}) async {
  final Finder addSiteBtn = find.byIcon(Icons.add);
  await tester.pumpAndSettle();

  await tester.tap(addSiteBtn);

  await tester.pumpAndSettle();

  final Finder addSiteInNameField =
      find.byKey(Key(PlotsAndSitesKeys.ADD_SITE_NAME_FIELD));
  await tester.tap(addSiteInNameField);
  await tester.pumpAndSettle();
  await tester.enterText(addSiteInNameField, siteName);

  await tester.pumpAndSettle();

  final Finder addSiteSubmitBtn =
      find.byKey(Key(PlotsAndSitesKeys.ADD_SITE_SUBMIT_FIELD));

  await tester.tap(addSiteSubmitBtn);
  await tester.pumpAndSettle();
}

Future<void> tapSpecificSite({WidgetTester tester, String siteName}) async {
  final Finder testSite = find.byWidgetPredicate((widget) =>
      widget is SiteListTile &&
      widget.site.name is String &&
      (widget.site.name).startsWith(siteName));
  await tester.pumpAndSettle();
  await tester.tap(testSite);
  await tester.pumpAndSettle();
}

Future<void> addPlotInSpecificSite(
    {WidgetTester tester, String siteName, String plotName}) async {
  final Finder addplotBtn = find.byKey(Key("addPlotBtnIn_$siteName"));
  await tester.tap(addplotBtn);

  await tester.pumpAndSettle();

  final Finder addPlotInNameField =
      find.byKey(Key(PlotsAndSitesKeys.ADD_PLOT_NAME_FIELD));
  await tester.enterText(addPlotInNameField, plotName);

  final Finder addPlotSumitBtn =
      find.byKey(Key(PlotsAndSitesKeys.ADD_PLOT_SUBMIT_FIELD));
  await tester.pumpAndSettle();

  await tester.tap(addPlotSumitBtn);
  await tester.pumpAndSettle();
}

Future<void> tapSpecificPlot({WidgetTester tester, String plotName}) async {
  final Finder testPlot = find.byWidgetPredicate((widget) =>
      widget is PlotListTile &&
      widget.plot.name is String &&
      (widget.plot.name).startsWith(plotName));
  await tester.pumpAndSettle();

  await tester.tap(testPlot);
  await tester.pumpAndSettle();
}

Future<void> enterManualReport({WidgetTester tester, String plotName}) async {
  final Finder manualPlotBtn = find.byKey(Key('manualPlot_$plotName'));
  await tester.pumpAndSettle();
  await tester.tap(manualPlotBtn);
  await tester.pumpAndSettle();
}

Future<void> enterPlotsReport({WidgetTester tester, String plotName}) async {
  final Finder manualPlotBtn = find.byKey(Key("plotMechReports_$plotName"));
  await tester.pumpAndSettle();
  await tester.tap(manualPlotBtn);
  await tester.pumpAndSettle();
}

Future<void> enterToSpecificReportTypeByKey(
    {WidgetTester tester, String key}) async {
  final Finder wantedButton = find.byKey(Key(key));
  await tester.pumpAndSettle();
  await tester.tap(wantedButton);
  await tester.pumpAndSettle();
}

Future<void> enterToMechanicalReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.MECHANICAL_REPORTS_BTN);
}

Future<void> enterToGeneralMechanicalReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.GENERAL_MECHANICAL_REPORTS_BTN);
}

Future<void> enterToQualityMechanicalReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.QUALITY_MECHANICAL_REPORTS_BTN);
}

Future<void> enterToQualityManualReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.QUALITY_MANUAL_REPORTS_BTN);
}

Future<void> enterToBunkersClearanceReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.BUNKERS_CLEARANCE_REPORTS_BTN);
}

Future<void> enterToDeepTargetsReports({WidgetTester tester}) async {
  return enterToSpecificReportTypeByKey(
      tester: tester, key: PlotsAndSitesKeys.DEEP_TARGETS_REPORTS_BTN);
}

Future<void> tapSpecificReport(
    {WidgetTester tester, String timeOfReport, String editor}) async {
  final Finder testPlot = find.byWidgetPredicate((widget) =>
      widget is ReportListTile &&
      dateToString(widget.report.timeCreated) == timeOfReport &&
      widget.report.lastEditor.name == editor);
  await tester.pumpAndSettle();
  await tester.tap(testPlot);
  await tester.pumpAndSettle();
}

Future<void> deleteSpecificReport(
    {WidgetTester tester, String authorName, DateTime reportTime}) async {
  if (reportTime == null) {
    reportTime = DateTime.now();
  }
  await tapSpecificReport(
    tester: tester,
    timeOfReport: dateToString(reportTime),
    editor: authorName,
  );
  await tester.pumpAndSettle();
  final Finder deleteButton = find.byIcon(Icons.delete);
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
  final Finder sureDeleteButton = find.byKey(
    Key(PlotsAndSitesKeys.SURE_TO_DELETE_REPORT),
  );
  await tester.tap(sureDeleteButton);
  await tester.pumpAndSettle();
}

Future<void> addStripInSpecificPlot(
    {WidgetTester tester, String plotName}) async {
  final Finder addStripBtn = find.byKey(Key('addStripBtn$plotName'));
  await tester.pumpAndSettle();
  await tester.tap(addStripBtn);
  await tester.pumpAndSettle();

  final Finder nameAddStrip = find.byKey(Key('nameAddStrip$plotName'));
  await tester.enterText(nameAddStrip, plotName);
  await tester.pumpAndSettle();

  final Finder addStripSumbitBtn =
      find.byKey(Key('addStripSumbitBtn$plotName'));
  await tester.pumpAndSettle();
  await tester.tap(addStripSumbitBtn);
}

Future<void> enterEditReportMode({WidgetTester tester}) async {
  final Finder editButton = find.byIcon(Icons.edit);
  await tester.tap(editButton);
  await tester.pumpAndSettle();
}

Future<void> fillReport({
  WidgetTester tester,
  Map<String, dynamic> report,
}) async {
  for (String key in report.keys) {
    final Finder currentField = find.byKey(Key(key));
    await tester.tap(currentField);
    await tester.enterText(currentField, (report[key] as String));
    await tester.pumpAndSettle();
  }
}

Future<void> fillTableReport({
  WidgetTester tester,
  Map<String, dynamic> report,
}) async {
  for (String key in report.keys) {
    try {
      final Finder currentField = find.byKey(Key(key)).first;
      await tester.ensureVisible(currentField);
      await tester.pumpAndSettle();
      await tester.tap(currentField);
      await tester.pumpAndSettle();
      await tester.enterText(currentField, (report[key] as String));
      await tester.pumpAndSettle();
    } catch (error) {
      print("key was $key");
      fail(error.toString());
    }
  }
}

Future<void> submitReport({WidgetTester tester}) async {
  final gesture =
      await tester.startGesture(Offset(0, 600)); //Position of the scrollview
  await tester.pumpAndSettle();
  await gesture.moveBy(Offset(0, -600)); //How much to scroll by
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
  final Finder buttonFinder = find.widgetWithText(RaisedButton, 'שמור');
  final RaisedButton button =
      buttonFinder.evaluate().first.widget as RaisedButton;
  button.onPressed();
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
}

Future<void> submitTableReport({WidgetTester tester}) async {
  final RaisedButton button = find
      .widgetWithText(RaisedButton, 'שמור')
      .evaluate()
      .first
      .widget as RaisedButton;
  button.onPressed();
  await tester.pumpAndSettle();
}

Future<void> deleteSite({WidgetTester tester, String siteName}) async {
  await tester.pumpAndSettle();
  final Finder editSiteBtn = find.byKey(Key("editSite_$siteName"));
  await tester.tap(editSiteBtn);
  await tester.pumpAndSettle();
  final Finder delSiteBtn = find.byKey(Key("delSiteBtn_$siteName"));
  await tester.tap(delSiteBtn);
  await tester.pumpAndSettle();
  final Finder approveDelSiteBtn = find.byKey(Key("approveDelSiteBtn"));
  await tester.tap(approveDelSiteBtn);
  await tester.pumpAndSettle();
}

Future<void> tapSpecificStatusStrip(
    {WidgetTester tester, String status}) async {
  final Finder testStripStatus = find.byWidgetPredicate((widget) =>
      widget is StatusStripListTile &&
      widget.status is StripStatus &&
      (generateTitleFromStripStatus(widget.status)).startsWith(status));
  await tester.pumpAndSettle();
  await tester.tap(testStripStatus);
  await tester.pumpAndSettle();
}

Future<void> tapSpecificStrip({WidgetTester tester, String stripName}) async {
  final Finder testStrip = find.byWidgetPredicate((widget) =>
      widget is StripListTile &&
      widget.strip.name is String &&
      (widget.strip.name).startsWith(stripName));
  await tester.pumpAndSettle();
  await tester.tap(testStrip);
  await tester.pumpAndSettle();
}

Future<void> chooseEmployeeForFirst(
    {WidgetTester tester, String empName}) async {
  final Finder firstEmployeeDropDown = find.byWidgetPredicate((widget) =>
      widget is DropdownSearch<HandWorker> &&
      widget.label.startsWith("  עובד בפעולה ראשונה  "));
  await tester.pumpAndSettle();
  await tester.tap(firstEmployeeDropDown);
  await tester.pumpAndSettle();

  expect(find.text(empName), isNotNull);
  await tester.tap(find.text(empName));
  await tester.pumpAndSettle();

  final Finder editStripFormSubmitBtn =
      find.byKey(Key(PlotsAndSitesKeys.EDIT_STRIP_SUBMIT_BTN));
  await tester.pumpAndSettle();
  await tester.ensureVisible(editStripFormSubmitBtn);
  await tester.pumpAndSettle();
  await tester.tap(editStripFormSubmitBtn);
  await tester.pumpAndSettle();
}

Future<void> deleteStrip({WidgetTester tester}) async {
  final Finder deleteStripFormSubmitBtn =
      find.byKey(Key(PlotsAndSitesKeys.DELETE_STRIP_SUBMIT_BTN));
  await tester.ensureVisible(deleteStripFormSubmitBtn);
  await tester.pumpAndSettle();
  if (deleteStripFormSubmitBtn.evaluate().isNotEmpty) {
    final deleteButtonWidget =
        deleteStripFormSubmitBtn.evaluate().first.widget as RaisedButton;
    deleteButtonWidget.onPressed();
    await tester.pumpAndSettle();
    final Finder sureToDeleteBtn =
        find.byKey(Key(PlotsAndSitesKeys.SURE_TO_DELETE_STRIP));
    await tester.tap(sureToDeleteBtn);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
  } else {
    fail("couldnt find delete button");
  }
}

Future<void> submitEditStrip({WidgetTester tester}) async {
  final Finder editStripFormSubmitBtn =
      find.byKey(Key(PlotsAndSitesKeys.EDIT_STRIP_SUBMIT_BTN));
  await tester.pumpAndSettle();
  await tester.ensureVisible(editStripFormSubmitBtn);
  await tester.pumpAndSettle();
  final editBtn =
      editStripFormSubmitBtn.evaluate().first.widget as RaisedButton;
  editBtn.onPressed();
  await tester.pumpAndSettle();
}

Future<void> deletePlot({WidgetTester tester, String plotName}) async {
  final Finder editPlotBtn =
      find.byKey(Key("${PlotsAndSitesKeys.EDIT_PLOT_BTN}$plotName"));
  await tester.tap(editPlotBtn);
  await tester.pumpAndSettle();
  final Finder delPlotBtn =
      find.byKey(Key("${PlotsAndSitesKeys.DELETE_PLOT_BTN}$plotName"));
  await tester.tap(delPlotBtn);
  await tester.pumpAndSettle();
  final Finder approveDelPlotBtn =
      find.byKey(Key(PlotsAndSitesKeys.SURE_TO_DELETE_PLOT));
  await tester.tap(approveDelPlotBtn);
  await tester.pumpAndSettle();
}

import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:IEODApp/logic/fieldHandler.dart';
import 'package:IEODApp/logic/reportHandler.dart';
import 'package:IEODApp/models/plot.dart';
import 'package:IEODApp/models/reports/templates/Template.dart';
import 'package:IEODApp/models/site.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test/utils/ReportTemplateUtils.dart';
import '../../../../test/utils/fieldUtils.dart';
import '../../../integration_test_suite.dart';
import '../projectHandlerTests/dataForTest.dart';
import 'dataForTest.dart';
import '../../utils/Constants.dart' as TestConstants;

class ReportHandlerTests extends IntegrationTestSuite {
  String currentProjectName;

  ReportHandlerTests(this.currentProjectName);

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    if (args == null || !args.containsKey(TestConstants.PASSWORD)){
      throw Exception("Test not run since password not provided");
    }
    else{
      super.runTests();

      testWidgets("setUpForReportHandlerTests", (WidgetTester tester) async {
        await EmployeeHandler().logout();
        await EmployeeHandler()
            .login(email: ADMIN_EMAIL, password: args[TestConstants.PASSWORD]);
        await ProjectHandler().chooseProject(currentProjectName);
        await Future.delayed(Duration(seconds: 2));
        Site site = generateRandomSite();
        Plot plot = generateRandomPlot();
        plot.siteId = site.id;
        final msg1 =
        await FieldHandler().addSite(toAdd: site, projectId: currentProjectName);
        final msg2 = await FieldHandler()
            .addPlotToSite(toAdd: plot, projectId: currentProjectName);
        if (msg1.isEmpty && msg2.isEmpty) {
          addedPlot = plot;
        }
      });

      testWidgets(UPLOAD_UPDATED_REPORT_SUCCESS, (WidgetTester tester) async {
        final report = generateRandomReport();
        report.attributeValues[Constants.PLOT_ID] = addedPlot.name;
        final msg = await ReportHandler()
            .uploadUpdateReport(ProjectHandler().getCurrentProjectId(), report);
        expect(msg, report.id);
        addedReportId = report.id;
      });
      testWidgets(UPLOAD_UPDATED_REPORT_NULL, (WidgetTester tester) async {
        var msg = await ReportHandler()
            .uploadUpdateReport(ProjectHandler().getCurrentProjectId(), null);
        expect(msg, Constants.FAIL);
        msg = await ReportHandler()
            .uploadUpdateReport(null, generateRandomReport());
        expect(msg, Constants.FAIL);
        msg =
        await ReportHandler().uploadUpdateReport("", generateRandomReport());
        expect(msg, Constants.FAIL);
      });
      testWidgets(UPLOAD_UPDATED_REPORT_INVALID, (WidgetTester tester) async {
        final report = generateRandomReport();
        report.attributeValues = null;
        final msg = await ReportHandler()
            .uploadUpdateReport(ProjectHandler().getCurrentProjectId(), report);
        expect(msg, Constants.FAIL);
      });

      testWidgets(RETRIEVE_REPORT_SUCCESS, (WidgetTester tester) async {
        addedReport = await ReportHandler().retrieveReportData(
            ProjectHandler().getCurrentProjectId(), addedReportId);
        expect(addedReport, isNotNull);
        expect(addedReport.attributeValues[Constants.PLOT_ID], addedPlot.name);
      });

      testWidgets(RETRIEVE_REPORT_NULL, (WidgetTester tester) async {
        var report = await ReportHandler()
            .retrieveReportData(ProjectHandler().getCurrentProjectId(), null);
        expect(report, null);
        report = await ReportHandler()
            .retrieveReportData(ProjectHandler().getCurrentProjectId(), "");
        expect(report, null);
        report = await ReportHandler().retrieveReportData(null, addedReportId);
        expect(report, null);

        report = await ReportHandler().retrieveReportData("", addedReportId);
        expect(report, null);
      });

      testWidgets(GET_ALL_REPORTS_IN_PROJECT_BY_TYPE_BY_PLOT,
              (WidgetTester tester) async {
            final ids = [addedReportId].toSet();
            var allNull = ReportHandler().getAllReportsInProjectByTypeByPlot(
                null, TemplateTypeEnum.Mechanical);
            expect(allNull, null);
            allNull = ReportHandler()
                .getAllReportsInProjectByTypeByPlot('', TemplateTypeEnum.Mechanical);
            expect(allNull, null);
            allNull = ReportHandler()
                .getAllReportsInProjectByTypeByPlot(addedReportId, null);
            expect(allNull, null);
            final all = ReportHandler().getAllReportsInProjectByTypeByPlot(
                addedPlot.name, TemplateTypeEnum.Mechanical);
            all.listen(expectAsync1((event) {
              final converted = event.map((e) => e.id).toSet();
              expect(converted.length, ids.length);
              print("current: $converted");
              expect(ids.containsAll(converted), true);
            }, max: 0));
          });

      testWidgets(DELETE_REPORT_NULL, (WidgetTester tester) async {
        var msg = await ReportHandler()
            .deleteReport(projectId: null, toDelete: generateRandomReport());
        expect(msg, isNotEmpty);
        msg = await ReportHandler()
            .deleteReport(projectId: "", toDelete: generateRandomReport());
        expect(msg, isNotEmpty);
        msg = await ReportHandler().deleteReport(
            projectId: ProjectHandler().getCurrentProjectId(), toDelete: null);
        expect(msg, isNotEmpty);
      });

      testWidgets(DELETE_REPORT_SUCCESS, (WidgetTester tester) async {
        final msg = await ReportHandler().deleteReport(
            toDelete: addedReport,
            projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
      });
    }
  }
}

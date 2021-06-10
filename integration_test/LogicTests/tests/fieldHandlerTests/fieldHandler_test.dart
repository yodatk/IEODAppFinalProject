import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/logic/EmployeeHandler.dart';
import 'package:IEODApp/logic/ProjectHandler.dart';
import 'package:IEODApp/logic/fieldHandler.dart';
import 'package:IEODApp/models/strip.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test/utils/fieldUtils.dart';
import '../../../integration_test_suite.dart';
import '../projectHandlerTests/dataForTest.dart';
import 'dataForTest.dart';
import '../../utils/Constants.dart' as TestConstants;

class FieldHandlerTests extends IntegrationTestSuite {
  String currentProjectName;

  FieldHandlerTests(this.currentProjectName);

  @override
  Future<void> runTests({Map<String, String> args = null}) async {
    if (args == null || !args.containsKey(TestConstants.PASSWORD)){
      throw Exception("Test not run since password not provided");
    }
    else{
      super.runTests();

      testWidgets("setUpForFieldHandlerTests", (WidgetTester tester) async {
        await EmployeeHandler().logout();
        await EmployeeHandler()
            .login(email: ADMIN_EMAIL, password: args[TestConstants.PASSWORD]);
        await ProjectHandler().chooseProject(currentProjectName);
        await Future.delayed(Duration(seconds: 2));
      });

      testWidgets(ADD_SITE_TO_SITE_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomSite();
        final msg = await FieldHandler().addSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
        addedSiteId = toAdd.id;
      });
      testWidgets(ADD_SITE_TO_SITE_NULL, (WidgetTester tester) async {
        var msg = await FieldHandler().addSite(
            toAdd: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        msg = await FieldHandler()
            .addSite(toAdd: generateRandomSite(), projectId: null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_SITE_TO_SITE_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomSite();
        toAdd.name = null;
        var msg = await FieldHandler().addSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toAdd.name = "";
        msg = await FieldHandler().addSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_PLOT_TO_SITE_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomPlot();
        toAdd.siteId = addedSiteId;
        final msg = await FieldHandler().addPlotToSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
        addedPlotId = toAdd.id;
      });

      testWidgets(ADD_PLOT_TO_SITE_NULL, (WidgetTester tester) async {
        var msg = await FieldHandler().addPlotToSite(
            toAdd: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        msg = await FieldHandler()
            .addPlotToSite(toAdd: generateRandomPlot(), projectId: null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_PLOT_TO_SITE_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomPlot();
        toAdd.name = null;
        var msg = await FieldHandler().addPlotToSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toAdd.name = '';
        msg = await FieldHandler().addPlotToSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toAdd.name = faker.company.name();
        toAdd.siteId = null;
        msg = await FieldHandler().addPlotToSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toAdd.siteId = "";
        msg = await FieldHandler().addPlotToSite(
            toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_STRIP_TO_PLOT_SUCCESS, (WidgetTester tester) async {
        final toAdd = generateRandomStrip();
        toAdd.plotId = addedPlotId;
        final msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isEmpty);
        addedStripId = toAdd.id;
      });

      testWidgets(ADD_STRIP_TO_PLOT_NULL, (WidgetTester tester) async {
        final msg = await FieldHandler().addStrip(strip: null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_STRIP_TO_PLOT_INVALID, (WidgetTester tester) async {
        final toAdd = generateRandomStrip();
        toAdd.name = null;
        var msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
        toAdd.name = '';
        msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
        toAdd.name = faker.person.name();
        toAdd.mineCount = null;
        msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
        toAdd.mineCount = 0;
        toAdd.depthTargetCount = null;
        msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
        toAdd.depthTargetCount = 0;
        toAdd.plotId = null;
        msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
        toAdd.plotId = "";
        msg = await FieldHandler().addStrip(strip: toAdd);
        expect(msg, isNotEmpty);
      });

      testWidgets(UPDATE_SITE_SUCCESS, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getSiteByIdOnce(addedSiteId);
        toEdit.name = faker.company.name();
        final msg = await FieldHandler().updateSite(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
        final afterEdit = await FieldHandler().getSiteByIdOnce(addedSiteId);
        expect(toEdit.name, afterEdit.name);
      });

      testWidgets(UPDATE_SITE_NULL, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getSiteByIdOnce(addedSiteId);
        toEdit.name = faker.company.name();
        final msg = await FieldHandler().updateSite(
            toUpdate: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        final msg2 =
        await FieldHandler().updateSite(toUpdate: toEdit, projectId: null);
        expect(msg2, isNotEmpty);
      });

      testWidgets(UPDATE_SITE_INVALID, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getSiteByIdOnce(addedSiteId);
        toEdit.name = null;
        var msg = await FieldHandler().updateSite(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toEdit.name = '';
        msg = await FieldHandler().updateSite(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
      });

      testWidgets(UPDATE_PLOT_SUCCESS, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getPlotById(addedPlotId);
        toEdit.name = faker.lorem.word();
        final msg = await FieldHandler().updatePlot(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
        final afterEdit = await FieldHandler().getPlotById(addedPlotId);
        expect(afterEdit.name, toEdit.name);
      });

      testWidgets(UPDATE_PLOT_NULL, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getPlotById(addedPlotId);
        final msg = await FieldHandler().updatePlot(
            toUpdate: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        final msg2 =
        await FieldHandler().updatePlot(toUpdate: toEdit, projectId: null);
        expect(msg2, isNotEmpty);
      });

      testWidgets(UPDATE_PLOT_INVALID, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getPlotById(addedPlotId);
        toEdit.name = null;
        var msg = await FieldHandler().updatePlot(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toEdit.name = '';
        msg = await FieldHandler().updatePlot(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toEdit.name = faker.lorem.word();
        toEdit.siteId = null;
        msg = await FieldHandler().updatePlot(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        toEdit.siteId = '';
        msg = await FieldHandler().updatePlot(
            toUpdate: toEdit, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
      });

      testWidgets(UPDATE_STRIP_SUCCESS, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getStripById(
            stripId: addedStripId,
            projectId: ProjectHandler().getCurrentProjectId());
        toEdit.name = faker.lorem.word();
        final msg = await FieldHandler().editStrip(
            strip: toEdit, changes: {Constants.STRIP_NAME: toEdit.name});
        expect(msg, isEmpty);
      });

      testWidgets(UPDATE_STRIP_NULL, (WidgetTester tester) async {
        final msg = await FieldHandler()
            .editStrip(strip: null, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
      });

      testWidgets(UPDATE_STRIP_INVALID, (WidgetTester tester) async {
        final toEdit = await FieldHandler().getStripById(
            stripId: addedStripId,
            projectId: ProjectHandler().getCurrentProjectId());
        toEdit.name = null;
        var msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.name = '';
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.name = faker.person.name();
        toEdit.mineCount = null;
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.mineCount = 0;
        toEdit.depthTargetCount = null;
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.depthTargetCount = 0;
        toEdit.plotId = null;
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.plotId = "";
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: {Constants.STRIP_NAME: 'yoda'});
        expect(msg, isNotEmpty);
        toEdit.plotId = faker.company.name();
        msg = await FieldHandler().editStrip(strip: toEdit, changes: null);
        expect(msg, isNotEmpty);
        msg = await FieldHandler()
            .editStrip(strip: toEdit, changes: Map<String, dynamic>());
        expect(msg, isNotEmpty);
      });

      testWidgets(GET_ALL_SITES, (WidgetTester tester) async {
        Set<String> ids = [addedSiteId].toSet();
        final all = FieldHandler().getAllSitesOfProjectAsStream();
        all.listen(expectAsync1((event) {
          final converted = event.map((e) => e.id).toSet();
          expect(converted.length, ids.length);
          print("current: $converted");
          expect(ids.containsAll(converted), true);
        }, max: 0));
        print("$GET_ALL_SITES PASSED");
      });

      testWidgets(GET_ALL_PLOTS_Of_SITES, (WidgetTester tester) async {
        Set<String> ids = [addedPlotId].toSet();
        final all = FieldHandler().getAllPlots();
        all.listen(expectAsync1((event) {
          final converted = event.map((e) => e.id).toSet();
          expect(converted.length, ids.length);
          print("current: $converted");
          expect(ids.containsAll(converted), true);
        }, max: 0));
        print("$GET_ALL_STRIPS_Of_PLOT PASSED");
      });

      testWidgets(GET_ALL_STRIPS_Of_PLOT, (WidgetTester tester) async {
        final all = await FieldHandler().getAllStripsOfGivenPlotAsList(
            plotId: addedPlotId,
            projectId: ProjectHandler().getCurrentProjectId());
        final toCompare = await FieldHandler().getStripById(
            stripId: addedStripId,
            projectId: ProjectHandler().getCurrentProjectId());
        expect(all.length, 1);
        final toCheck = all.first;
        compareTwoStrips(toCompare, toCheck);
      });

      testWidgets(DELETE_STRIP_NULL, (WidgetTester tester) async {
        final msg = await FieldHandler().deleteStrip(strip: null);
        expect(msg, isNotEmpty);
      });

      testWidgets(ADD_MULTIPLE_STRIPS_TO_PLOT_SUCCESS,
              (WidgetTester tester) async {
            var toAdd = <Strip>[];
            var msg = await FieldHandler().addMultipleStrips(toAdd: null);
            expect(msg, isNotEmpty);

            msg = await FieldHandler().addMultipleStrips(toAdd: toAdd);
            expect(msg, isNotEmpty);
            toAdd = [
              generateRandomStrip(plotId: addedPlotId),
              generateRandomStrip(plotId: addedPlotId),
              generateRandomStrip(plotId: addedPlotId),
            ];
            msg = await FieldHandler().addMultipleStrips(toAdd: toAdd);
            expect(msg, isEmpty);
            final check = await FieldHandler()
                .getAllStripsOfProject(ProjectHandler().getCurrentProjectId());
            expect(check.length, toAdd.length + 1);
          });

      testWidgets(DELETE_STRIP_SUCCESS, (WidgetTester tester) async {
        final toDelete = await FieldHandler().getStripById(
            stripId: addedStripId,
            projectId: ProjectHandler().getCurrentProjectId());
        final msg = await FieldHandler().deleteStrip(strip: toDelete);
        expect(msg, isEmpty);
      });
      testWidgets(DELETE_PLOT_NULL, (WidgetTester tester) async {
        final msg = await FieldHandler().deletePlot(
            toDelete: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        final toDelete = await FieldHandler().getPlotById(addedPlotId);
        final msg2 =
        await FieldHandler().deletePlot(toDelete: toDelete, projectId: null);
        expect(msg2, isNotEmpty);
      });

      testWidgets(DELETE_PLOT_SUCCESS, (WidgetTester tester) async {
        final toDelete = await FieldHandler().getPlotById(addedPlotId);
        final msg = await FieldHandler().deletePlot(
            toDelete: toDelete,
            projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
      });

      testWidgets(DELETE_SITE_NULL, (WidgetTester tester) async {
        final msg = await FieldHandler().deleteSite(
            toDelete: null, projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isNotEmpty);
        final toDelete = await FieldHandler().getSiteByIdOnce(addedSiteId);
        final msg1 =
        await FieldHandler().deleteSite(toDelete: toDelete, projectId: null);
        expect(msg1, isNotEmpty);
      });

      testWidgets(DELETE_SITE_SUCCESS, (WidgetTester tester) async {
        final toDelete = await FieldHandler().getSiteByIdOnce(addedSiteId);
        final msg = await FieldHandler().deleteSite(
            toDelete: toDelete,
            projectId: ProjectHandler().getCurrentProjectId());
        expect(msg, isEmpty);
      });
    }
  }
}

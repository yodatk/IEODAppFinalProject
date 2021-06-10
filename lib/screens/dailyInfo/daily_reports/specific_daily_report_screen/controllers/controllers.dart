import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

import '../../../../../models/reports/templates/Template.dart';
import '../../../../../models/reports/Report.dart';
import '../../../../../controllers/state_providers/screen_utils.dart';
import '../../../../../models/reports/builders/PDFBuilder.dart';
import '../../../../../models/reports/builders/outputBuilder.dart';
import '../../../../../screens/managesSiteAndPlots/edit_report_screen/edit_report_screen.dart';
import '../../../../../logic/EmployeeHandler.dart';
import '../../../../../models/Employee.dart';
import '../../../../../models/reports/templates/FunctionResolver.dart';
import '../../../../../logic/ProjectHandler.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../../../logic/reportHandler.dart';
import '../../../constants/keys.dart' as Keys;

import '../../../../../constants/style_constants.dart' as StyleConstants;

///
/// Args class to pass parameters dynamically to the stream provider of all matching reports
/// ***THIS CLASS IS IMPORTANT*** since StreamProvider of riverpod can only get hashable objects (map or lists couldn't work)
///
class ArgsForAllDailyReportStream {
  ///
  /// Type of the report
  ///
  final TemplateTypeEnum type;

  ArgsForAllDailyReportStream(this.type);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ArgsForAllDailyReportStream && other.type == this.type;
  }

  @override
  int get hashCode => this.type.hashCode;
}

///
/// Provider to the view model of the specific report screen
///
final specificDailyReportScreenViewModel =
    Provider<SpecificDailyReportScreenViewModel>(
        (ref) => SpecificDailyReportScreenViewModel());

///
/// Stream Provider to get all relevant reports
///
final allRelevantReports = StreamProvider.autoDispose
    .family<List<Report>, ArgsForAllDailyReportStream>((ref, args) {
  return ReportHandler().getAllReportsInProjectByType(args.type);
});

///
/// View Model class for the specific report screen
///
class SpecificDailyReportScreenViewModel {
  ///
  /// Screen utils for the specific report screen ( with query capabilities)
  ///
  final screenUtils = ScreenUtilsControllerForList<DateTime>(
    query: ValueNotifier<DateTime>(null),
    editSuccessMessage: "",
    deleteSuccessMessage: "",
  );

  ///
  /// OutputBuilder to generate Files from Report
  ///
  final OutputBuilder _outputBuilder = PDFBuilder();

  ///
  /// Navigating to creating report screen
  ///
  void navigateAndPushCreateReport(
      BuildContext context, TemplateTypeEnum reportType) async {
    final result = await Navigator.of(context).pushNamed(
        EditReportScreen.routeName,
        arguments: prepareReport(context, reportType)) as Map<String, dynamic>;
    handleEditOrDeleteResult(
      result: result,
      deleteMsg: EditReportScreen.successMessageOnDelete,
      editMsg: EditReportScreen.successMessageOnSubmit,
    );
  }

  ///
  /// function to handle the String result from edit or delete, and notify the user if it went successfully or not
  ///
  void handleEditOrDeleteResult({
    Map<String, dynamic> result,
    String deleteMsg,
    String editMsg,
  }) {
    try {
      final context = this.screenUtils.scaffoldKey.currentContext;
      if (result != null) {
        final isDelete = result["isDelete"] as bool;
        final msg = result["msg"] as String;
        FocusScope.of(context).unfocus();

        this.screenUtils.showOnSnackBar(
              msg: msg,
              successMsg: isDelete ? deleteMsg : editMsg,
            );
      }
    } catch (ignore) {}
  }

  ///
  /// Preparing the report before editing it, resolving all automated values in the report
  ///
  Future<Report> prepareReport(
      BuildContext context, TemplateTypeEnum reportType) async {
    Template fetched =
        await ReportHandler().fetchReportTemplateByType(reportType);
    if (fetched == null) {
      fetched = await ReportHandler().uploadNewTemplateByType(reportType);
    }
    await FunctionResolver().resolveFunctionDerivedData(fetched);
    final currentUser = EmployeeHandler().readCurrentEmployee();
    final currEditor = EmployeeForDocs(currentUser.name, currentUser.id);

    Report newReport = Report(
      template: fetched,
      name: describeEnum(reportType),
      creator: currEditor,
    );

    return newReport;
  }

  // report tile

  ///
  /// Preparing the report before editing it, resolving all automated values in the report
  ///
  Future<Report> prepareReportTile(Report report) async {
    await FunctionResolver().resolveFunctionDerivedData(report.template);
    return report;
  }

  ///
  /// Navigating to edit specific report screen, and handling the result of the edit
  ///
  void navigateAndPushEditReport(BuildContext context, Report report) async {
    final result = await Navigator.of(context).pushNamed(
        EditReportScreen.routeName,
        arguments: prepareReportTile(report)) as Map<String, dynamic>;
    if (result != null) {
      this.handleEditOrDeleteResult(
        result: result,
        deleteMsg: EditReportScreen.successMessageOnDelete,
        editMsg: EditReportScreen.successMessageOnSubmit,
      );
    }
  }

  ///
  /// show delete dialog. if 'yes' is pressed, wil delete the given [report]
  /// else, will cancel the report
  ///
  void deleteReport(BuildContext context, Report report) async {
    final scaffoldKey = this.screenUtils.scaffoldKey;
    Alert(
      context: scaffoldKey.currentContext,
      //used to be just "context"
      type: AlertType.warning,
      title: "מחיקת דו״ח",
      desc: "האם אתה בטוח שאתה רוצה למחוק את הדו״ח ${report.getTitle()} ?",
      buttons: [
        DialogButton(
          key: Key(Keys.SURE_TO_DELETE_REPORT),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            Navigator.of(scaffoldKey.currentContext).pop();
            String msg = await ReportHandler().deleteReport(
                toDelete: report,
                projectId: ProjectHandler().getCurrentProjectId());

            this.handleEditOrDeleteResult(
              result: {
                "isDelete": true,
                "msg": msg,
              },
              deleteMsg: 'הדו"ח נמחק בהצלחה',
            );
          },
          width: 60,
          color: StyleConstants.errorColor,
        ),
        DialogButton(
          key: Key(Keys.CANCEL_DELETE_REPORT),
          child: Text(
            "ביטול",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => Navigator.of(scaffoldKey.currentContext).pop(),
          width: 60,
        )
      ],
    ).show();
  }

  ///
  /// creating a Report File from the given [report] and asks the user where he wants to share it.
  ///
  Future<void> generateAndShareReport(
      BuildContext context, Report report) async {
    final doc = await _outputBuilder.generateReport(report);
    final Directory output = await getApplicationDocumentsDirectory();
    var fileName = "${report.name}"
        "_${report.lastEditor.name}"
        "_${dateToDateTimeString(report.timeModified)}" // date + time w/o '/'
        "${_outputBuilder.getFileSuffix()}";
    final String docPath = p.join(output.path, fileName);
    final file = File(docPath);
    await file.writeAsBytes(await doc.save() as List<int>);
    Share.shareFiles([docPath]);
  }
}

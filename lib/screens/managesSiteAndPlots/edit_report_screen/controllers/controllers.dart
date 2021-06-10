import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/EmployeeHandler.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../logic/reportHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/reports/Report.dart';
import '../../../../models/reports/builders/widgetFormBuilder.dart';

///
/// Provider of the view model to the edit report screen
///
final editReportViewModel = Provider.autoDispose((ref) => EditReportViewModel());

///
/// View Model class for the edit report screen
///
class EditReportViewModel {
  ///
  /// ScreenUtils for the edit report screen
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Key for the form of the report
  ///
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// Saving data that was collected so far to the database
  ///
  void submit(BuildContext context, Report report) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState.saveAndValidate()) {
      final currentUser = EmployeeHandler().readCurrentEmployee();
      final lastEditor = EmployeeForDocs(currentUser.name, currentUser.id);
      report.lastEditor = lastEditor;
      report.timeModified = DateTime.now();

      String reportId = await ReportHandler()
          .uploadUpdateReport(ProjectHandler().getCurrentProjectId(), report);
      Map<String, dynamic> result = {
        "isDelete": false,
        "msg": reportId != Constants.FAIL ? "" : "תקלה בתקשורת עם DB"
      };
      Navigator.of(context).pop(result);
    }
  }

  ///
  /// Converting the given [report] to a widget form
  ///
  Widget buildForm(BuildContext context, Report report) {
    WidgetFormBuilder builder =
        WidgetFormBuilder(formKey, report.attributeValues);
    return builder.visit(context, report.template);
  }
}

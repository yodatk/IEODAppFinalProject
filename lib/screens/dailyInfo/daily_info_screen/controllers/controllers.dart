import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/reportHandler.dart';
import '../../../../models/reports/Report.dart';
import '../../../../models/reports/builders/PDFBuilder.dart';
import '../../../../models/reports/builders/outputBuilder.dart';
import '../../../../models/reports/templates/Template.dart';
import '../../../../utils/datetime_utils.dart';
import '../../constants/keys.dart' as Keys;

///
/// Provider for the View Model of the Reports for date pop-up
///
final specificReportsForDateViewModel =
    Provider.autoDispose<SpecificReportsForDateViewModel>(
        (ref) => SpecificReportsForDateViewModel());

///
/// View Model Class for the Daily Info Menu screen
///
class SpecificReportsForDateViewModel {
  ///
  /// Map of reportType to the number of report it has in a given day
  ///
  var reportsCounter = {};

  ///
  /// [ScreenUtils] for the snack bar messages and loading status
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Form key of the generate all report by date button
  ///
  final _reportsDateFormKey = GlobalKey<FormBuilderState>();

  ///
  /// Shows the "get all report by date" dialog.
  ///
  Future<void> dialogCall(BuildContext context) {
    List<String Function(DateTime)> validators = [];
    validators
        .add(FormBuilderValidators.required(context, errorText: "שדה חובה"));
    return Alert(
      context: context,
      title: "הפקת דוחות לתאריך",
      content: FormBuilder(
        key: _reportsDateFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FormBuilderDateTimePicker(
                key: Key(Keys.DATE_OF_ALL_REPORTS_FORM_BUILDER),
                name: Constants.ENTITY_CREATED,
                initialDate: DateTime.now(),
                inputType: InputType.date,
                decoration: InputDecoration(
                  hintText: "תאריך",
                  icon: Icon(StyleConstants.ICON_REPORT),
                  alignLabelWithHint: true,
                ),
                validator: FormBuilderValidators.compose(validators),
              ),
            ],
          ),
        ),
      ),
      buttons: [
        DialogButton(
          key: Key(Keys.ALL_REPORTS_ZIP_BTN),
          onPressed: () async {
            var date = (_reportsDateFormKey.currentState
                .fields[Constants.ENTITY_CREATED].value) as DateTime;
            FocusScope.of(context).unfocus();

            if (_reportsDateFormKey.currentState.saveAndValidate()) {
              Navigator.of(context).pop();
              await this.shareAllRepo(
                context: context,
                chosenDate: date,
              );
            }
          },
          child: Text(
            "הורד",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  ///
  /// generate a given [Report] to a PDF file.
  ///
  Future<File> generateReport(BuildContext context, Report report) async {
    OutputBuilder _outputBuilder = PDFBuilder();
    final doc = await _outputBuilder.generateReport(report);
    final Directory output = await getApplicationDocumentsDirectory();
    final index = reportsCounter[report.template.templateType]++;
    final fileName =
        "${report.name}" "_$index" "${_outputBuilder.getFileSuffix()}";
    final String docPath = p.join(output.path, fileName);
    final file = File(docPath);
    await file.writeAsBytes(await doc.save() as List<int>);
    return file;
  }

  ///
  /// Collect all given [Report] top a single zip file.
  ///
  Future<void> zipAndShareReports(
      DateTime date, List<File> reportsToZip) async {
    Directory appDocDirectory = await getExternalStorageDirectory();
    var encoder = ZipFileEncoder();
    final String zipPath = appDocDirectory.path +
        "/" +
        'allReports_${dateToDateTimeString(date).replaceAll(":", "").replaceAll(".", "_")}.zip';
    encoder.create(zipPath);
    reportsToZip.forEach((file) {
      encoder.addFile(file);
    });
    encoder.close();
    Share.shareFiles([zipPath]);
    // remove temporary files
  }

  ///
  /// generate all reports of a given [chosenDate]
  ///
  Future<List<Future<File>>> generateReportsAndCreateFiles(
      DateTime chosenDate, BuildContext context) async {
    List<Future<File>> reportsToZip = [];
    List<Report> allReports =
        await ReportHandler().getAllReportsInProjectByDate(chosenDate);
    if (allReports.isEmpty) {
      screenUtils.showOnSnackBar(msg: "לא קיימים דוחות בתאריך זה");
      return null;
    }
    for (var report in allReports) {
      Future<File> f = generateReport(context, report);
      reportsToZip.add(f);
    }

    return reportsToZip;
  }

  ///
  /// Reset the counter of all report type before generating all files
  ///
  void initCounters() {
    for (var type in TemplateTypeEnum.values) {
      reportsCounter[type] = 1;
    }
  }

  ///
  /// Share zip of all [Report] from a given date to the communication channel the user choses
  ///
  Future<void> shareAllRepo({BuildContext context, DateTime chosenDate}) async {
    this.screenUtils.isLoading.value = true;
    initCounters();
    List<Future<File>> reportsFutures =
        await generateReportsAndCreateFiles(chosenDate, context);
    if (reportsFutures != null) {
      List<File> reportsFiles = [];
      for (var report in reportsFutures) {
        File f = await report;
        reportsFiles.add(f);
      }
      await zipAndShareReports(chosenDate, reportsFiles);
    }
    this.screenUtils.isLoading.value = false;
  }
}

import 'dart:io';

import 'package:IEODApp/utils/datetime_utils.dart';
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
import '../../../../logger.dart' as Logger;
import '../../../../logic/EmployeeHandler.dart';
import '../../../../logic/fieldHandler.dart';
import '../../../../models/plot.dart';
import '../../../../models/reports/builders/PDFBuilder.dart';
import '../../../../models/reports/builders/outputBuilder.dart';
import '../../../../models/strip.dart';
import '../../../../models/stripStatus.dart';
import '../../constants/keys.dart' as Keys;
import '../widgets/add_strip_form.dart';
import '../widgets/strips_by_status_pi_chart.dart';

///
/// Provider of the view model of the all strips screen
///
final allStripsViewModel =
    Provider.autoDispose<AllStripsViewModel>((ref) => AllStripsViewModel());

///
/// find all Hand workers in this project
///
final allHandWorkersProvider = FutureProvider.autoDispose(
    (ref) => EmployeeHandler().getAllHandWorkEmployees());

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.NONE]
///
final noneStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.NONE);
  stream.listen((List<Strip> noneStrips) {
    FieldHandler().currentNoneStrips = noneStrips.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.IN_FIRST]
///
final inFirstStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.IN_FIRST);
  stream.listen((List<Strip> inFirstStrip) {
    FieldHandler().currentInFirstStrips = inFirstStrip.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.FIRST_DONE]
///
final firstDoneStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.FIRST_DONE);
  stream.listen((List<Strip> firstDoneStrips) {
    FieldHandler().currentFirstDoneStrips = firstDoneStrips.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.IN_SECOND]
///
final inSecondStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.IN_SECOND);
  stream.listen((List<Strip> inSecondStrips) {
    FieldHandler().currentInSecondStrips = inSecondStrips.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.SECOND_DONE]
///
final secondDoneStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.SECOND_DONE);
  stream.listen((List<Strip> secondDoneStrips) {
    FieldHandler().currentSecondDoneStrips = secondDoneStrips.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.IN_REVIEW]
///
final inReviewStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
      plotId: plotId, status: StripStatus.IN_REVIEW);
  stream.listen((List<Strip> inReviewStrips) {
    FieldHandler().currentInReviewStrips = inReviewStrips.toSet();
  });
  return stream;
});

///
/// Stream Provider to get all Strips that are with the status of [StripStatus.FINISHED]
///
final finishedStatusStrips =
    StreamProvider.autoDispose.family<List<Strip>, String>((ref, plotId) {
  final stream = FieldHandler().getAllStripsOfPlotFromGivenStatusAsStream(
    plotId: plotId,
    status: StripStatus.FINISHED,
  );
  stream.listen((List<Strip> finishedStrips) {
    FieldHandler().currentFinishedStrips = finishedStrips.toSet();
  });
  return stream;
});

///
/// View Model class for the all strips screen
///
class AllStripsViewModel {
  ///
  /// ScreenUtils for All strips screen
  ///
  final screenUtils = ScreenUtilsControllerForList(
    query: ValueNotifier<String>(""),
    editSuccessMessage: "הסטריפ נערך בהצלחה",
    deleteSuccessMessage: "הסטריפ נמחק בהצלחה",
  );

  OutputBuilder _outputBuilder = PDFBuilder();

  ///
  /// Form key for the add strip form
  ///
  final _addStripFormKey = GlobalKey<FormBuilderState>();

  ///
  /// changes the form from single add to multiple add
  ///
  final isMultipleAddForm = ValueNotifier<bool>(false);

  ///
  /// Show dialog to add Strip.
  ///
  void openAddStripDialog(
    BuildContext context,
    Plot plot,
  ) async {
    Alert(
        closeFunction: () {
          Navigator.of(context).pop();
          FocusScope.of(context).unfocus();
        },
        context: context,
        title: "הוספת סטריפים",
        content: AddStripForm(this._addStripFormKey, plot),
        buttons: [
          DialogButton(
            key: Key("${Keys.ADD_STRIP_SUBMIT_BTN}${plot.name}"),
            onPressed: () {
              if (!this.isMultipleAddForm.value) {
                final name = _addStripFormKey
                    .currentState.fields[Constants.STRIP_NAME].value as String;
                if (name == null || name.trim().length == 0) {
                  _addStripFormKey.currentState.reset();
                }
                FocusScope.of(context).unfocus();

                if (_addStripFormKey.currentState.saveAndValidate()) {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                  tryAddStrip(
                    stripName: name,
                    plot: plot,
                  );
                }
              } else {
                final start = _addStripFormKey
                    .currentState.fields[AddStripForm.START].value as String;
                final end = _addStripFormKey
                    .currentState.fields[AddStripForm.END].value as String;
                if ((start == null || start.trim().length == 0) ||
                    (end == null || end.trim().length == 0)) {
                  _addStripFormKey.currentState.reset();
                }
                FocusScope.of(context).unfocus();
                if (_addStripFormKey.currentState.saveAndValidate()) {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                  final toAdd = <Strip>[];
                  for (int i = int.parse(start); i <= int.parse(end); i++) {
                    toAdd.add(Strip(name: i.toString(), plotId: plot.id));
                  }
                  tryAddMultipleStrips(toAdd: toAdd);
                }
              }
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: this.isMultipleAddForm,
              builder: (BuildContext context, bool isMultiple, _) => isMultiple
                  ? Text(
                      "הוסף סטריפים",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  : Text(
                      "הוסף סטריפ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
            ),
          )
        ]).show();
  }

  ///
  /// Trying to add the given strip to the database. will show success\error message on screen when process is finished
  ///
  void tryAddStrip({
    @required String stripName,
    @required Plot plot,
  }) async {
    this.screenUtils.isLoading.value = true;

    String addResult = await FieldHandler().addStrip(
      strip: Strip(name: stripName, plotId: plot.id),
    );
    this.screenUtils.isLoading.value = false;
    try {
      this
          .screenUtils
          .showOnSnackBar(msg: addResult, successMsg: "הסטריפ נוסף בהצלחה");
    } catch (ignore) {
      Logger.warning(ignore.toString());
    }
  }

  ///
  /// Trying to list of strips [toAdd] to the database. will show success\error message on screen when process is finished
  ///
  void tryAddMultipleStrips({
    @required List<Strip> toAdd,
  }) async {
    this.screenUtils.isLoading.value = true;

    String addResult = await FieldHandler().addMultipleStrips(toAdd: toAdd);

    this.screenUtils.isLoading.value = false;
    try {
      this
          .screenUtils
          .showOnSnackBar(msg: addResult, successMsg: "הסטריפים נוספו בהצלחה");
    } catch (ignore) {
      Logger.warning(ignore.toString());
    }
  }

  ///
  /// Updating strip in the data base. will show error\success message when done
  ///
  void updateStrip({
    @required Strip toUpdate,
    @required Map<String, dynamic> changes,
  }) async {
    this.screenUtils.isLoading.value = true;
    String updateResult =
        await FieldHandler().editStrip(strip: toUpdate, changes: changes);
    this.screenUtils.isLoading.value = false;
    try {
      this
          .screenUtils
          .showOnSnackBar(msg: updateResult, successMsg: "הסטריפ נערך בהצלחה");
    } catch (ignored) {}
  }

  ///
  /// Deletes the given [Strip] to delete and show the delete result message on screen
  ///
  void deleteStrip({
    @required Strip toDelete,
  }) async {
    this.screenUtils.isLoading.value = true;
    String deleteResult = await FieldHandler().deleteStrip(strip: toDelete);
    this.screenUtils.isLoading.value = false;

    if (deleteResult != null) {
      this.screenUtils.showOnSnackBar(
            msg: deleteResult,
            successMsg: "הסטריפ נמחק בהצלחה",
          );
    }
  }

  ///
  /// Showing the current [Plot] status [Strip] wise as a Pie chart
  ///
  void showStatistics(BuildContext context) {
    final allStrips = FieldHandler().getAllCurrentStrips();
    if (allStrips.isEmpty) {
      this.screenUtils.showOnSnackBar(msg: "אין סטריפים בחלקה זו");
    } else {
      final dialog = Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        //this right here
        child: Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "מספר סטריפים : ${allStrips.length}",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 20,
              ),
              StripsOfPlotPieChart(),
            ],
          ),
        ),
      );
      showDialog(context: context, builder: (context) => dialog);
    }
  }

  ///
  /// generates all the [Strip] data to a PDF report.
  ///
  Future<void> generateManualReport() async {
    final doc = await _outputBuilder.buildManualReport(
      strips: FieldHandler().getAllCurrentStrips().toList(),
      plot: FieldHandler().readCurrentPlot(),
      site: FieldHandler().readCurrentSite(),
      employeeInChargeOfReport: EmployeeHandler().readCurrentEmployee().name,
    );
    final Directory output = await getApplicationDocumentsDirectory();
    final prefix = "דוח חלקה ידנית";
    final fileName =
        "$prefix ${FieldHandler().readCurrentPlot().name} ${dateToDateTimeString(DateTime.now()).replaceAll("/", "_").replaceAll(':', '').replaceAll('.', "_")}${_outputBuilder.getFileSuffix()}";
    final String docPath = p.join(output.path, fileName);
    final file = File(docPath);
    await file.writeAsBytes(await doc.save() as List<int>);
    Share.shareFiles([docPath]);
  }

  ///
  /// Open edit name and notes dialog for strip [toEdit] Dialog. if yes is pressed, wil update info in data base.
  /// if cancel is pressed - will close dialog
  ///
  void editStripName(
    Strip toEdit,
  ) async {
    final context = this.screenUtils.scaffoldKey.currentContext;
    final _formKey = GlobalKey<FormBuilderState>();
    final allStrips = FieldHandler().getAllCurrentStrips();

    Alert(
        closeFunction: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
        },
        context: context,
        title: "עריכת שם של סטריפ",
        content: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  name: Constants.STRIP_NAME,
                  initialValue: toEdit.name,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "שם הסטריפ",
                    icon: Icon(StyleConstants.ICON_ADD_STRIP),
                    alignLabelWithHint: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      context,
                      errorText: "שדה זה דרוש לסטריפ",
                    ),
                    FormBuilderValidators.maxLength(
                      context,
                      Strip.MAX_STRIP_NAME_LENGTH,
                      errorText: "שם ארוך מדיי",
                    ),
                    (value) {
                      final notes = _formKey.currentState
                              .fields[Constants.STRIP_NOTES].value ??
                          "";
                      final check = allStrips.where((element) =>
                          element.name == value && element.id != toEdit.id);
                      return (check.isNotEmpty && notes == toEdit.notes)
                          ? "שם הסטריפ הזה קיים כבר"
                          : (toEdit.name == value && toEdit.notes == notes)
                              ? "לא שינית דבר"
                              : null;
                    }
                  ]),
                  valueTransformer: (val) => val != null ? val.trim() : val,
                ),
                FormBuilderTextField(
                  name: Constants.STRIP_NOTES,
                  decoration: InputDecoration(
                    hintText: "הערות",
                    icon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  initialValue: toEdit.notes,
                  maxLines: null,
                )
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              final String name = _formKey.currentState
                      .fields[Constants.STRIP_NAME].value as String ??
                  "";
              final String notes = _formKey
                  .currentState.fields[Constants.STRIP_NOTES].value as String;
              if (name.trim().length == 0) {
                _formKey.currentState.reset();
              }
              FocusScope.of(context).unfocus();

              if (_formKey.currentState.saveAndValidate()) {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
                final changes = Map<String, dynamic>();
                if (name != toEdit.name) {
                  toEdit.name = name;
                  changes[Constants.STRIP_NAME] = name;
                }
                if (notes != toEdit.notes) {
                  toEdit.notes = notes;
                  changes[Constants.STRIP_NOTES] = notes;
                }
                updateStrip(
                  toUpdate: toEdit,
                  changes: changes,
                );
              }
            },
            child: Text(
              "ערוך סטריפ",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

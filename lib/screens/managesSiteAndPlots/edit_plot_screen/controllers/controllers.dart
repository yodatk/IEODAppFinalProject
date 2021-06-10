import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logger.dart' as Logger;
import '../../../../logic/ProjectHandler.dart';
import '../../../../logic/fieldHandler.dart';
import '../../../../models/plot.dart';
import '../../../../models/site.dart';
import '../../constants/keys.dart' as Keys;
import '../edit_plot_screen.dart';

///
/// StreamProvider of all sites in current project
///
final allSitesOfProjectStream = StreamProvider.autoDispose<List<Site>>(
    (ref) => FieldHandler().getAllSitesOfProjectAsStream());

///
/// StreamProvider of all plots in current project
///
final allPlotsOfProjectStream =
    StreamProvider.autoDispose<List<Plot>>((ref) => FieldHandler().getAllPlots());

///
/// Provider to the view model of Edit plot screen
///
final editPlotViewModel =
    Provider.autoDispose<EditPlotViewModel>((ref) => EditPlotViewModel());

///
/// View model class for the edit plot screen
///
class EditPlotViewModel {
  final screenUtils = ScreenUtilsController();
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// deleting plot function.
  /// if something went will show error message on screen,
  /// or navigate to the all sites and plots screen otherwise
  ///
  void deletePlot({
    @required BuildContext context,
    @required Plot plotToDelete,
  }) async {
    FocusScope.of(context).unfocus();
    String statusMsg;
    try {
      this.screenUtils.isLoading.value = true;
      statusMsg = await FieldHandler().deletePlot(
        toDelete: plotToDelete,
        projectId: ProjectHandler().getCurrentProjectId(),
      );
    } finally {
      this.screenUtils.isLoading.value = false;
    }
    if (statusMsg == '') {
      Navigator.of(context).pop([true, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
          msg: statusMsg, successMsg: EditPlotScreen.successMessageOnDelete);
    }
  }

  ///
  /// updating given plot in the data base
  ///
  void updatePlotLogic({
    BuildContext context,
    Plot plotToUpdate,
  }) async {
    try {
      this.screenUtils.isLoading.value = true;
      await updatePlot(plotToUpdate, context);
      this.screenUtils.isLoading.value = false;
    } catch (error) {
      Logger.error("updatePlot ERROR\n: $error");
    }
  }

  ///
  /// updating plot function.
  /// if something went will show error message on screen,
  /// or navigate to the all sites and plots screen otherwise
  ///
  Future<void> updatePlot(Plot plotToUpdate, BuildContext context) async {
    final statusMsg = await FieldHandler().updatePlot(
      toUpdate: plotToUpdate,
      projectId: ProjectHandler().getCurrentProjectId(),
    );

    if (statusMsg == '') {
      Navigator.of(context).pop([false, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
          msg: statusMsg, successMsg: EditPlotScreen.successMessageOnSubmit);
    }
  }

  ///
  /// Trying to submit the details from the form.
  /// if the details is the same as [initialPlot] will show matching message and will not update the data base
  /// otherwise -> will try to update the database
  ///
  void onEditPress(BuildContext context, Plot initialPlot) {
    FocusScope.of(context).unfocus();
    if (formKey.currentState.saveAndValidate()) {
      FocusScope.of(context).unfocus();

      final plotToUpdate = Plot.copy(initialPlot);
      plotToUpdate.name =
          (formKey.currentState.fields[Constants.PLOT_NAME].value as String).trim();
      plotToUpdate.siteId =
          (formKey.currentState.fields[Constants.PLOT_SITE_ID].value as Site)
              .id
              .trim();
      if (plotToUpdate.name == initialPlot.name &&
          plotToUpdate.siteId == initialPlot.siteId) {
        this.screenUtils.showOnSnackBar(msg: "לא שינית דבר בחלקה");
        return;
      }

      this.updatePlotLogic(
        context: context,
        plotToUpdate: plotToUpdate,
      );
    }
  }

  ///
  /// Showing delete dialog. if pressed "yes" will try to delete the given plot.
  /// else -> will cancel the dialog
  ///
  void onDeletePress(BuildContext context, Plot initialPlot) {
    // unfocusing the form, and try to submit only of form is validated
    FocusScope.of(context).unfocus();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "מחיקת חלקה",
      desc: "האם אתה בטוח שאתה רוצה למחוק את החלקה '${initialPlot.name}'",
      buttons: [
        DialogButton(
          key: Key(Keys.SURE_TO_DELETE_PLOT),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).pop();

            this.deletePlot(context: context, plotToDelete: initialPlot);
          },
          width: 60,
          color: StyleConstants.errorColor,
        ),
        DialogButton(
          child: Text(
            "ביטול",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
          width: 60,
        )
      ],
    ).show();
  }
}

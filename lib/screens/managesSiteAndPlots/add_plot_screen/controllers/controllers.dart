import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../logic/fieldHandler.dart';
import '../../../../models/plot.dart';
import '../../../../models/site.dart';

///
/// Provider of this view model to the add plot screen
///
final addPlotViewModel = Provider.autoDispose((ref) => AddPlotViewModel());

///
/// StreamProvider of all sites in current project
///
final allSitesOfProjectStream = StreamProvider.autoDispose<List<Site>>(
    (ref) => FieldHandler().getAllSitesOfProjectAsStream());

///
/// StreamProvider of all plots in current project
///
final allPlotsOfProjectStream =
    StreamProvider<List<Plot>>((ref) => FieldHandler().getAllPlots());

///
/// View Model Class for the Add Plot Screen
///
class AddPlotViewModel {
  ///
  /// Screen Utils for the add plot screen
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Key for the add plot form
  ///
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// function to activate when pressing the submit button in the add plot Form
  ///
  void onPressedForm(BuildContext context) {
    FocusScope.of(context).unfocus();
    final newName =
        formKey.currentState.fields[Constants.PLOT_NAME].value as String;
    if (formKey.currentState.saveAndValidate() && newName.trim().isNotEmpty) {
      trySubmitForm(context);
    }
  }

  ///
  /// After validating form, retrieving data from it to submit it
  ///
  void trySubmitForm(BuildContext context) async {
    FocusScope.of(context).unfocus();
    String plotName;
    Site site =
        formKey.currentState.fields[Constants.PLOT_SITE_ID].value as Site;
    plotName = formKey.currentState.fields[Constants.PLOT_NAME].value
        .toString()
        .trim();
    this.submitForm(
      context: context,
      siteId: site.id,
      plotName: plotName,
    );
  }

  ///
  /// Submitting the data form to the database, and show a success or error message to the screen.
  /// if procedure is successful, will navigate back to the all sites and plots screen
  ///
  void submitForm({
    BuildContext context,
    String siteId,
    String plotName,
  }) async {
    String statusMsg;
    try {
      this.screenUtils.isLoading.value = true;
      statusMsg = await this.addingPlot(plotName, siteId);
      this.screenUtils.isLoading.value = false;
      if (statusMsg == '') {
        Navigator.of(context).pop(statusMsg);
      } else {
        this.screenUtils.showOnSnackBar(msg: statusMsg);
      }
    } catch (error) {
      this.screenUtils.showOnSnackBar(msg: Constants.GENERAL_ERROR_MSG);
    }
  }

  ///
  /// Try to add a new [Plot] with the given [plotName] and [siteId].
  /// if successful, will return an empty string, otherwise will return a description with details of what went wrong
  ///
  Future<String> addingPlot(String plotName, String siteId) async {
    final statusMsg = await FieldHandler().addPlotToSite(
      toAdd: Plot.newPlot(name: plotName, siteId: siteId),
      projectId: ProjectHandler().getCurrentProjectId(),
    );
    return statusMsg;
  }
}

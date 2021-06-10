import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../logic/fieldHandler.dart';
import '../../../../models/plot.dart';
import '../../../../models/site.dart';
import '../../add_plot_screen/add_plot_to_site_screen.dart';
import '../../all_strips_screen/allStripsOfCertainPlotScreen.dart';
import '../../constants/keys.dart' as Keys;
import '../../edit_plot_screen/edit_plot_screen.dart';
import '../../edit_site_screen/edit_site_screen.dart';
import '../../plot_report_screen/plot_reports_screen.dart';

///
/// stream of all sites that exists in the current project
///
final allSitesStream = StreamProvider.autoDispose<List<Site>>(
    (ref) => FieldHandler().getAllSitesOfProjectAsStream());

///
/// Stream Provider to get all Plots in the project
///
final allPlotsStream = StreamProvider.autoDispose<List<Plot>>(
    (ref) => FieldHandler().getAllPlots());

///
/// Provider of the View Model class of the [Site]s and [Plot]s screen
///
final allSitesAndPlotViewModel =
    Provider.autoDispose((ref) => AllSitesAndPlotsViewModel());

///
/// View Model Class of the [Site]s and [Plot]s screen
///
class AllSitesAndPlotsViewModel {
  // add site constants
  static const REQUIRED_ADD_SITE = 'שדה זה הכרחי להוספת אתר';
  static const SITE_NAME_MAX_LENGTH = 20;

  ///
  /// [ScreenUtils] to control relevant context, loading proceess, and list filtering
  ///
  final screenUtils = ScreenUtilsControllerForList<String>(
      query: ValueNotifier<String>(""),
      editSuccessMessage: "האתר נערך בהצלחה",
      deleteSuccessMessage: "האתר נמחק בהצלחה");

  ///
  /// Key of the add site form
  ///
  final _addSiteFormKey = GlobalKey<FormBuilderState>();

  ///
  /// Adds the [Site] with the given [siteName] if possible. will show the add result on screen when finished
  ///
  void trySubmitSite({
    BuildContext context,
    String siteName,
    String projectId,
  }) async {
    this.screenUtils.isLoading.value = true;
    String addResult = await FieldHandler().addSite(
      toAdd: Site(name: siteName),
      projectId: projectId,
    );
    this.screenUtils.isLoading.value = false;
    this
        .screenUtils
        .showOnSnackBar(msg: addResult, successMsg: 'האתר נוסף בהצלחה');
  }

  ///
  /// Show the add site form as a dialog
  ///
  void openAddSiteDialog(BuildContext context, List<Site> allSites) async {
    Alert(
        context: this.screenUtils.scaffoldKey.currentContext,
        title: "הוספת אתר",
        content: FormBuilder(
          key: _addSiteFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  key: Key(Keys.ADD_SITE_NAME_FIELD),
                  name: Constants.SITE_NAME,
                  initialValue: '',
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "שם האתר",
                    icon: Icon(Icons.engineering),
                    alignLabelWithHint: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      context,
                      errorText: AllSitesAndPlotsViewModel.REQUIRED_ADD_SITE,
                    ),
                    FormBuilderValidators.maxLength(
                      context,
                      AllSitesAndPlotsViewModel.SITE_NAME_MAX_LENGTH,
                      errorText: "שם ארוך מדיי",
                    ),
                    (value) => allSites.fold(
                            false,
                            (bool previousValue, site) =>
                                previousValue || site.name == value)
                        ? "כבר קיים אתר עם שם זה"
                        : null
                  ]),
                  valueTransformer: (val) => val.trim(),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            key: Key(Keys.ADD_SITE_SUBMIT_FIELD),
            onPressed: () {
              final name = _addSiteFormKey
                  .currentState.fields[Constants.SITE_NAME].value as String;
              if (name.trim().length == 0) {
                _addSiteFormKey.currentState.reset();
              }
              FocusScope.of(context).unfocus();

              if (_addSiteFormKey.currentState.saveAndValidate()) {
                Navigator.of(context).pop();

                trySubmitSite(
                  context: this.screenUtils.scaffoldKey.currentContext,
                  siteName: name,
                  projectId: ProjectHandler().getCurrentProjectId(),
                );
              }
            },
            child: Text(
              "הוסף אתר",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  ///
  /// shows the edit/delete process result message on screen
  ///
  void handleEditOrDeleteResult({
    List result,
    BuildContext context,
    String deleteMsg,
    String editMsg,
  }) {
    try {
      final isDelete = result[0] as bool;
      final msg = result[1] as String;
      FocusScope.of(this.screenUtils.scaffoldKey.currentContext).unfocus();

      this.screenUtils.showOnSnackBar(
            msg: msg,
            successMsg: isDelete ? deleteMsg : editMsg,
          );
    } catch (ignored) {}
  }

  ///
  /// Navigate to the edit [Site] Screen
  ///
  void navigateAndPushEditSite(BuildContext context, Site site) async {
    final scaffoldKey = this.screenUtils.scaffoldKey;
    final result = await Navigator.of(context)
        .pushNamed(EditSiteScreen.routeName, arguments: site) as List<dynamic>;
    if (result != null) {
      this.handleEditOrDeleteResult(
        result: result,
        context: scaffoldKey.currentContext,
        deleteMsg: EditSiteScreen.successMessageOnDelete,
        editMsg: EditSiteScreen.successMessageOnSubmit,
      );
    }
  }

  ///
  /// Navigate to the add [Plot] to the given [site] screen
  ///
  void navigateAndPushAddPlot(BuildContext context, Site site) async {
    final result = await Navigator.of(context)
        .pushNamed(AddPlotToSite.routeName, arguments: site) as String;
    try {
      FocusScope.of(context).unfocus();
      if (result != null) {
        this.screenUtils.showOnSnackBar(
              msg: result,
              successMsg: AddPlotToSite.successMessageOnSubmit,
            );
      }
    } catch (ignored) {}
  }

  ///
  /// Navigate to the edit [Plot] screen
  ///
  void navigateAndPushEditPlot(BuildContext context, Plot plot) async {
    final scaffoldKey = this.screenUtils.scaffoldKey;
    final result = (await Navigator.of(context)
        .pushNamed(EditPlotScreen.routeName, arguments: plot) as List<dynamic>);
    handleEditOrDeleteResult(
      result: result,
      context: scaffoldKey.currentContext,
      deleteMsg: EditPlotScreen.successMessageOnDelete,
      editMsg: EditPlotScreen.successMessageOnSubmit,
    );
  }

  ///
  /// Navigate to the [Report] of a given [plot] screen
  ///
  void navigateAndPushPlotReports(BuildContext context, Plot plot) async {
    await setCurrentPlotAndSite(plot);
    await Navigator.of(context)
        .pushNamed(PlotReportsScreen.routeName, arguments: plot);
    await clearPlotAndSite();
  }

  ///
  /// Navigate to the [Strip] screen of the given [plot]
  ///
  void navigateAndPushHandWorkScreen(BuildContext context, Plot plot) async {
    await setCurrentPlotAndSite(plot);

    await Navigator.of(context)
        .pushNamed(AllStripsOfSpecificPlotScreen.routeName, arguments: plot);
    await clearPlotAndSite();
  }

  ///
  /// Sets the current [site] and current [plot] in the [FieldHandler]
  ///
  Future<void> setCurrentPlotAndSite(Plot plot) async {
    await FieldHandler().resetCurrentPlot(plot.id);
    await FieldHandler().resetCurrentSite(plot.siteId);
  }

  ///
  /// Clearing the current [Site] and [Plot] from the FieldHandler
  ///
  Future<void> clearPlotAndSite() async {
    await FieldHandler().resetCurrentPlot(null);
    await FieldHandler().resetCurrentSite(null);
  }
}

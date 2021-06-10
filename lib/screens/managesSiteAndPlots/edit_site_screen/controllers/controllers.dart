import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logger.dart' as Logger;
import '../../../../logic/ProjectHandler.dart';
import '../../../../logic/fieldHandler.dart';
import '../../../../models/site.dart';
import '../edit_site_screen.dart';
import '../widgets/edit_site_form.dart';

///
/// Provider of view model of the edit site Screen
///
final editSiteViewModel =
    Provider.autoDispose<EditSiteViewModel>((ref) => EditSiteViewModel());

///
/// View model class for the edit site screen
///
class EditSiteViewModel {
  ///
  /// Screen utils for the edit site screen
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Form key for the edit site form
  ///
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// delete the given [siteToDelete] from the data base.
  /// if successful, will navigate to the all site page and show a success message
  /// else will show an error message
  ///
  void deleteSite({
    @required BuildContext context,
    @required Site siteToDelete,
  }) async {
    FocusScope.of(context).unfocus();
    String statusMsg;
    try {
      this.screenUtils.isLoading.value = true;
      statusMsg = await FieldHandler().deleteSite(
        toDelete: siteToDelete,
        projectId: ProjectHandler().getCurrentProjectId(),
      );
    } finally {
      this.screenUtils.isLoading.value = false;
    }
    if (statusMsg == '') {
      Navigator.of(context).pop([true, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
            msg: statusMsg,
            successMsg: EditSiteScreen.successMessageOnDelete,
          );
    }
  }

  ///
  /// update given [siteToUpdate] in the database
  /// if update is successful, will navigate to all site screen
  /// else will show error message on screen
  ///
  void updateSite({
    @required BuildContext context,
    @required Site siteToUpdate,
  }) async {
    try {
      this.screenUtils.isLoading.value = true;
      await _updateSiteLogic(siteToUpdate, context);
      this.screenUtils.isLoading.value = false;
    } catch (error) {
      Logger.error("ERROR in '_updateSite': $error");
    }
  }

  ///
  /// Updates given [siteToUpdate] in the database
  ///
  Future<void> _updateSiteLogic(Site siteToUpdate, BuildContext context) async {
    final statusMsg = await FieldHandler().updateSite(
      toUpdate: siteToUpdate,
      projectId: ProjectHandler().getCurrentProjectId(),
    );

    if (statusMsg == '') {
      Navigator.of(context).pop([false, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
            msg: statusMsg,
            successMsg: EditSiteScreen.successMessageOnSubmit,
          );
    }
  }

  ///
  /// Checking if the details in the form are valid. if so, will try to update the site
  ///
  void trySubmit(BuildContext context, Site initialSite) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState.saveAndValidate()) {
      FocusScope.of(context).unfocus();

      final siteToUpdate = Site.copy(initialSite);
      siteToUpdate.name =
          formKey.currentState.fields[EditSiteForm.SITE_NAME].value as String;
      if (initialSite.name == siteToUpdate.name) {
        this.screenUtils.showOnSnackBar(msg: "לא שינית דבר");
        return;
      }
      updateSite(
        context: context,
        siteToUpdate: siteToUpdate,
      );
    }
  }

  ///
  /// show a delete dialog on screen. if 'yes' is pressed, will try to delete the given [initialSite]
  /// else, will cancel the dialog
  ///
  void tryDelete(BuildContext context, Site initialSite) async {
    // unfocusing the form, and try to submit only of form is validated
    FocusScope.of(context).unfocus();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "מחיקת אתר",
      desc:
          "מחיקת האתר תמחוק גם את כל החלקות אותו הוא מכיל. האם אתה בטוח שאתה רוצה למחוק את האתר '${initialSite.name}'?",
      buttons: [
        DialogButton(
          key: Key("approveDelSiteBtn"),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            this.deleteSite(context: context, siteToDelete: initialSite);
          },
          width: 60,
          color: Theme.of(context).errorColor,
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

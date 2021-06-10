import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../controllers/state_providers/screen_utils.dart';
import '../../../../../logic/ProjectHandler.dart';
import '../../../../../logic/dailyInfoHandler.dart';
import '../../../../../models/image_folder.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../constants/keys.dart' as Keys;
import '../../specific_folder_screen/specific_folder_screen.dart';

///
/// ViewModel class for the all images folders screen
///
final allImagesFoldersViewModel =
    Provider.autoDispose<allImagesFolderViewModel>(
        (ref) => allImagesFolderViewModel());

///
/// StreamProvider of all map folders of the current Project
///
final allFolderOfCurrentProjectStream = StreamProvider.autoDispose((ref) =>
    DailyInfoHandler()
        .allMapFoldersFromProject(ProjectHandler().getCurrentProjectId()));

///
/// View Model Class for the all IOmages folder screen
///
class allImagesFolderViewModel {
  ///
  /// [ScreenUtilsController] for the all Images folders view Model
  ///
  final screenUtils = ScreenUtilsControllerForList(
    query: ValueNotifier<DateTime>(null),
    editSuccessMessage: "התיקייה נשמרה בהצלחה",
    deleteSuccessMessage: "התיקייה נמחקה בהצלחה",
  );

  ///
  /// form key for the add folder dialog
  ///
  final addFormKey = GlobalKey<FormBuilderState>();

  ///
  /// Shows add [ImageFolder] add form dialog
  ///
  void showAddDialog(BuildContext context, List<ImageFolder> allFolders) async {
    Alert(
        context: context,
        title: "הוספת תיקייה",
        content: FormBuilder(
          key: addFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilderDateTimePicker(
                  key: Key(Keys.DATE_PICKER_MAP_FOLDER),
                  inputType: InputType.date,
                  name: Constants.MAP_FOLDER_DATE,
                  initialValue: DateTime.now().add(Duration(days: 1)),
                  locale: Localizations.localeOf(context),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                      hintText: "תאריך",
                      icon: const Icon(Icons.create_new_folder),
                      alignLabelWithHint: true),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      context,
                      errorText: "שדה זה הוא חובה להוספת תיקייה",
                    ),
                    (value) {
                      if (value == null) {
                        return "תאריך לא יכול להיות ריק";
                      }
                      final matching = allFolders.where((element) {
                        return dateToString(element.date) ==
                            dateToString(value);
                      });
                      if (matching.length >= 1) {
                        return "קיימת תיקייה לתאריך זה";
                      }
                      return null;
                    }
                  ]),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            key: Key(Keys.OK_DATE_PICKER_MAP_FOLDER),
            onPressed: () {
              FocusScope.of(context).unfocus();

              if (addFormKey.currentState.saveAndValidate()) {
                final date = addFormKey.currentState
                    .fields[Constants.MAP_FOLDER_DATE].value as DateTime;

                ImageFolder mapFolder =
                    ImageFolder(date: date, numberOfImages: 0);

                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
                this.trySubmitMapFolder(context: context, toAdd: mapFolder);
              }
            },
            child: Text(
              "הוסף תיקייה",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  ///
  /// Trying to submit a new MapFolder to the dataBase
  ///
  void trySubmitMapFolder({
    @required BuildContext context,
    @required ImageFolder toAdd,
  }) async {
    this.screenUtils.isLoading.value = true;
    String addResult = await DailyInfoHandler().addOrOverrideMapFolder(toAdd);
    this.screenUtils.isLoading.value = false;
    this.screenUtils.showOnSnackBar(
        msg: addResult, successMsg: this.screenUtils.editSuccessMessage);
  }

  ///
  /// Updated the given Folder [toUpdate] date name
  ///
  Future<void> updateFolderName({
    BuildContext context,
    ImageFolder toUpdate,
  }) async {
    this.screenUtils.isLoading.value = true;
    final msg = await DailyInfoHandler().updateFolderName(toUpdate);
    this.screenUtils.isLoading.value = false;
    this.screenUtils.showOnSnackBar(
        msg: msg, successMsg: this.screenUtils.editSuccessMessage);
  }

  ///
  /// Show dialog for rename the given folder [toEdit] with a new name
  ///
  void renameFolder(
    BuildContext context,
    ImageFolder toEdit,
    List<ImageFolder> allFolders,
  ) async {
    final _formKey = GlobalKey<FormBuilderState>();

    Alert(
        closeFunction: () {
          Navigator.of(context).pop();
          FocusScope.of(context).unfocus();
        },
        context: context,
        title: "עריכת שם תיקייה",
        content: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilderDateTimePicker(
                  key: Key(Keys.DATE_PICKER_MAP_FOLDER),
                  name: Constants.MAP_FOLDER_DATE,
                  initialValue: toEdit.date,
                  inputType: InputType.date,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "שם התיקייה",
                    icon: const Icon(Icons.folder),
                    alignLabelWithHint: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      context,
                      errorText: "שדה זה הוא חובה להוספת סידור נסיעה",
                    ),
                    (value) {
                      final matching = allFolders.where((element) {
                        return dateToString(element.date) ==
                            dateToString(value);
                      });
                      if (matching.length >= 1) {
                        return "קיים סידור נסיעה לתאריך זה";
                      }
                      return null;
                    }
                  ]),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            key: Key(Keys.OK_DATE_PICKER_MAP_FOLDER),
            onPressed: () {
              final date = _formKey.currentState
                  .fields[Constants.MAP_FOLDER_DATE].value as DateTime;
              FocusScope.of(context).unfocus();

              if (_formKey.currentState.saveAndValidate()) {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
                final toUpdate = toEdit.clone() as ImageFolder;
                toUpdate.date = date;
                updateFolderName(
                  context: context,
                  toUpdate: toUpdate,
                );
              }
            },
            child: Text(
              "שמור",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  ///
  /// Show dialog for deleting folder
  ///
  void deleteMapFolder(BuildContext context, ImageFolder toDelete) async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "מחיקת תיקייה",
      desc:
          "האם אתה בטוח שאתה רוצה למחוק את התיקייה מתאריך ${toDelete.generateTitle()} ?",
      buttons: [
        DialogButton(
          key: Key(Keys.SURE_DELETE_MAP_FOLDER),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
            this.screenUtils.isLoading.value = true;
            String msg = await DailyInfoHandler().deleteMapFolders(toDelete);
            this.screenUtils.isLoading.value = false;
            this.screenUtils.showOnSnackBar(
                msg: msg, successMsg: this.screenUtils.deleteSuccessMessage);
          },
          width: 60,
          color: Theme.of(context).errorColor,
        ),
        DialogButton(
          key: Key(Keys.CANCEL_DELETE_MAP_FOLDER),
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

  ///
  /// Navigating to the screen with all the images of the chosen [folder]
  ///
  void navigateAndPushSpecificFolderScreen(
      BuildContext context, ImageFolder folder) async {
    Navigator.of(context)
        .pushNamed(SpecificImagesFolderScreen.routeName, arguments: folder);
  }
}

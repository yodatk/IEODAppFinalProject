import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../models/project.dart';
import '../../constants/keys.dart' as Keys;
import '../../edit_project_menu/edit_project_screen.dart';

///
/// View Model class for the all project Screen. in charge of connecting events in the UI to the logic layer handlers
///
class ProjectsViewModel {
  ///
  /// [ScreenUtils] to handle context , loading, and query status.
  ///
  ScreenUtilsControllerForList<String> screenUtils =
      ScreenUtilsControllerForList<String>(
          query: ValueNotifier<String>(""),
          editSuccessMessage: "הפרויקט נערך בהצלחה",
          deleteSuccessMessage: "הפרויקט נמחק בהצלחה");

  ///
  /// function to show a delete project dialog. user will need to entyer the projet name to permenatly delete a project.
  ///
  void deleteProject(BuildContext context, Project projectToDelete) async {
    final _formKey = GlobalKey<FormBuilderState>();
    final firstSubtitle =
        "האם אתה בטוח שאתה רוצה למחוק את הפרויקט ${projectToDelete.getTitle()} ?\n";
    final secondSubtitle = "לצורך כך רשום את שם הפרויקט";
    final thirdSubtitle = " על מנת למחוק את הפרויקט לצמיתות.";
    final desc =
        "$firstSubtitle$secondSubtitle '${projectToDelete.name}' $thirdSubtitle";
    Alert(
      context: screenUtils.scaffoldKey.currentContext,
      //used to be just "context"
      type: AlertType.warning,
      title: "מחיקת פרויקט",
      desc: desc,
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Center(
            child: FormBuilderTextField(
              key: Key(Keys.PROJECT_NAME_FIELD),
              name: Constants.PROJECT_NAME,
              decoration: InputDecoration(
                hintText: "שם פרויקט",
                icon: Icon(Icons.error_outline),
                alignLabelWithHint: true,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context,
                    errorText: "חובה לכתוב את שם הפרויקט על מנת למחוק אותו"),
                (value) =>
                    value != projectToDelete.name ? "שם פרויקט שגוי" : null
              ]),
            ),
          ),
        ),
      ),

      buttons: [
        DialogButton(
          key: Key(Keys.SURE_TO_DELETE_PROJECT),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            if (_formKey.currentState.saveAndValidate()) {
              screenUtils.isLoading.value = true;
              Navigator.of(screenUtils.scaffoldKey.currentContext).pop();
              String msg =
                  await ProjectHandler().deleteProject(projectToDelete);
              screenUtils.isLoading.value = false;
              screenUtils.showOnSnackBar(
                  msg: msg, successMsg: "הפרויקט נמחק בהצלחה");
            }
          },
          width: 60,
          color: Theme.of(context).errorColor,
        ),
        DialogButton(
          key: Key(Keys.CANCEL_DELETE_PROJECT),
          child: Text(
            "ביטול",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () =>
              Navigator.of(screenUtils.scaffoldKey.currentContext).pop(),
          width: 60,
        )
      ],
    ).show();
  }

  ///
  /// Navigating to a edit project screen
  ///
  void navigateAndPushEditProject(BuildContext context, Project project) async {
    final result = await Navigator.of(context)
            .pushNamed(EditProjectScreen.routeName, arguments: project)
        as EditResult;
    screenUtils.handleEditResult(result);
  }

  ///
  /// Navigating to the Edit project screen to create a new project
  ///
  void navigateAndPushCreateProject(BuildContext context) {
    navigateAndPushEditProject(context, null);
  }

  ///
  /// Filter a given list of [allProjects] to contain only the project which their names contain the given [query]
  ///
  List<Project> filterProjects(List<Project> allProjects, String query) {
    return query == null || query.isEmpty
        ? allProjects
        : allProjects
            .where((item) => item.name != null && item.name.contains(query))
            .toList()
      ..sort((p1, p2) {
        if (p1.isActive == p2.isActive) {
          return p1.name.compareTo(p2.name);
        } else {
          return p1.isActive ? -1 : 1;
        }
      });
  }
}

///
/// Stream Provider of all [Project] available
///
final allProjectsProvider = StreamProvider.autoDispose<List<Project>>(
    (ref) => ProjectHandler().getAllProjects());

///
/// Stream provider of all active [Project] available
///
final allActiveProjectsProvider = StreamProvider.autoDispose<List<Project>>(
    (ref) => ProjectHandler().getAllActiveProjects());

///
/// view model of the all project screen
///
final allProjectsViewModel =
    Provider.autoDispose<ProjectsViewModel>((ref) => ProjectsViewModel());

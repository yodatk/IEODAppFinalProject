import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/EmployeeHandler.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/edit_image_case.dart';
import '../../../../models/project.dart';
import '../../../../models/company.dart';

///
/// Stream provider for all [Employee] in system
///
final allEmployeeForProject = StreamProvider.autoDispose<List<Employee>>(
    (ref) => EmployeeHandler().getAllEmployeesAsStream());

///
/// Stream provider for all [Employee] which have [Permission] of Admin in system
///
final allAdminsForProject =
    StreamProvider.autoDispose<List<Employee>>((ref) => EmployeeHandler().getAllAdmins());

///
/// Provider for this view model
///
final editProjectViewModel =
    Provider.autoDispose<EditProjectViewModel>((ref) => EditProjectViewModel());

///
/// View Model Object for the Edit Project Screen
///
class EditProjectViewModel {
  ///
  /// [ScreenUtilsController] for the Edit Project Screen
  ///
  ScreenUtilsController screenUtils = ScreenUtilsController();

  ///
  /// Key to the form in the page
  ///
  final _formKey = GlobalKey<FormBuilderState>();

  ///
  /// Image chosen by the user. null means the user don't want an image in this project
  ///
  File pickedImage;

  ///
  /// cancel button indicator
  ///
  bool isCanceled = false;

  GlobalKey<FormBuilderState> get formKey => _formKey;

  ///
  /// Trying to submit the edit  \ add result of the form to the data base
  ///
  Future<void> trySubmitProjectForm(
      BuildContext context, Project oldProject, Employee manager) async {
    this.screenUtils.isLoading.value = true;

    // 1. extracting values from form (image already extracted)
    Project updated = extractDataFromForm(oldProject, manager);
    if (updated == null) {
      this.screenUtils.isLoading.value = false;
      return;
    }
    // 2. checking if add \ edit and image case, and wait for server response
    String msg = await addOrEditProject(oldProject, updated);
    this.screenUtils.isLoading.value = false;
    // 3. returning result
    if (msg != null && msg.isNotEmpty) {
      this.screenUtils.showOnSnackBar(msg: msg);
    } else {
      Navigator.of(context).pop(EditResult(msg, false));
    }
  }

  ///
  /// Check if edit \ add of [project] according to given [oldProject]
  ///
  Future<String> addOrEditProject(Project oldProject, Project project) async {
    String msg;
    final bool isEdit = oldProject != null;
    if (isEdit && !project.employees.contains(oldProject.projectManagerId)) {
      project.employees.remove(oldProject.projectManagerId);
    }
    project.employees.add(project.projectManagerId);
    if (!isEdit) {
      EditImageCase imageCase = this.pickedImage == null
          ? EditImageCase.NO_CHANGE
          : EditImageCase.NEW_IMAGE;
      msg = await ProjectHandler().addProject(
        project,
        this.pickedImage,
        imageCase,
      );
    } else {
      EditImageCase imgCase = pickedImage != null
          ? EditImageCase.NEW_IMAGE
          : oldProject.isWithImage() && isCanceled
              ? EditImageCase.DELETE_IMAGE
              : EditImageCase.NO_CHANGE;
      List<String> employeesToRemoveFromProject = oldProject.employees
          .where((element) => !project.employees.contains(element))
          .toList();
      List<String> employeesToAddToProject = project.employees
          .where((element) => !oldProject.employees.contains(element))
          .toList();

      msg = await ProjectHandler().editProject(
        updatedProject: project,
        image: this.pickedImage,
        currentCase: imgCase,
        employeesToAdd: employeesToAddToProject,
        employeesToRemove: employeesToRemoveFromProject,
      );
    }
    return msg;
  }

  ///
  /// Extracting all data from form into a new project.
  /// if in edit mode, will first extract all data from the given [oldProject]
  ///
  Project extractDataFromForm(Project oldProject, Employee manager) {
    if (manager == null) {
      screenUtils.showOnSnackBar(msg: "מנהל אתר הוא שדה חובה להוספת פרויקט");
      return null;
    }
    // 1. extracting values from form (image already extracted)
    final name =
        _formKey.currentState.fields[Constants.PROJECT_NAME].value as String;
    final isActive =
        _formKey.currentState.fields[Constants.PROJECT_IS_ACTIVE].value as bool;
    final projectEmployees = (_formKey.currentState
            .fields[Constants.PROJECT_EMPLOYEES].value as List<Employee>)
        .map((e) => e.id)
        .toSet();
    final managerId = manager?.id;
    final employer = _formKey
        .currentState.fields[Constants.PROJECT_EMPLOYER].value as Company;
    // 2. creating a copy of the project to upload
    Project updated;
    if (oldProject != null) {
      updated = oldProject.clone() as Project;
    } else {
      updated = Project();
    }
    updated.name = name;
    updated.isActive = isActive;
    updated.projectManagerId = managerId;
    updated.employees = projectEmployees;
    updated.employer = employer;
    return updated;
  }
}

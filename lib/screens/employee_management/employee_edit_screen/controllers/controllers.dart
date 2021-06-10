import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/EmployeeHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/edit_image_case.dart';
import '../../../../models/permission.dart';
import '../edit_employee_screen.dart';

///
/// Provider of View Model for the Edit Employee Class
///
final editEmployeeViewModel = Provider.autoDispose<EditEmployeeViewModel>(
    (ref) => EditEmployeeViewModel());

///
/// View Model Class for the Edit Employee Screen
///
class EditEmployeeViewModel {
  ///
  /// Screen Utils for the edit employee screen
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Form key for the edit employee form
  ///
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// Image Chose by user. null means the user don't want an image for the current employee.
  ///
  File pickedImage;

  ///
  /// Cancel button indicator
  ///
  bool isCanceled = false;

  /// Delete the given [toDelete] from the database. also show a result message on screen
  void removeEmployee({
    BuildContext context,
    Employee toDelete,
  }) async {
    FocusScope.of(context).unfocus();
    String statusMsg;
    try {
      this.screenUtils.isLoading.value = true;
      statusMsg = await EmployeeHandler().deleteEmployee(toDelete);
    } finally {
      this.screenUtils.isLoading.value = false;
    }
    if (statusMsg.isEmpty) {
      Navigator.of(context).pop([true, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
            msg: statusMsg,
            successMsg: EditEmployeeScreen.successMessageOnSubmit,
          );
    }
  }

  /// edit the given [toEdit] to database
  void submitEditForm({
    @required BuildContext context,
    @required Employee toEdit,
    @required Map<String, dynamic> changes,
    @required File image,
    @required EditImageCase currentCase,
  }
      // more fields here according to need
      ) async {
    String statusMsg;

    this.screenUtils.isLoading.value = true;
    statusMsg = await EmployeeHandler()
        .editEmployee(toEdit, changes, image, currentCase);
    this.screenUtils.isLoading.value = false;
    if (statusMsg.isEmpty) {
      Navigator.of(context).pop([false, statusMsg]);
    } else {
      this.screenUtils.showOnSnackBar(
            msg: statusMsg,
            successMsg: EditEmployeeScreen.successMessageOnSubmit,
          );
    }
  }

  ///
  /// Trying to submit the datails from the edit form to the vdata base. if all the data is valid, will contact the database
  ///
  void trySubmit(BuildContext context, Employee toEdit) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState.saveAndValidate()) {
      FocusScope.of(context).unfocus();
      final employeeToUpdate = Employee.copy(toEdit);

      employeeToUpdate.name =
          (formKey.currentState.fields[Constants.EMPLOYEE_NAME].value as String)
              .trim();
      employeeToUpdate.permission = formKey.currentState
          .fields[Constants.EMPLOYEE_PERMISSION].value as Permission;
      employeeToUpdate.phoneNumber = formKey
          .currentState.fields[Constants.EMPLOYEE_PHONE_NUMBER].value as String;
      employeeToUpdate.isHandWorker = formKey
          .currentState.fields[Constants.EMPLOYEE_IS_HAND_WORKER].value as bool;

      EditImageCase imgCase = pickedImage != null
          ? EditImageCase.NEW_IMAGE
          : toEdit.isWithImage() && isCanceled
              ? EditImageCase.DELETE_IMAGE
              : EditImageCase.NO_CHANGE;

      if (employeeToUpdate.name == toEdit.name &&
          employeeToUpdate.permission == toEdit.permission &&
          employeeToUpdate.phoneNumber == toEdit.phoneNumber &&
          employeeToUpdate.isHandWorker == toEdit.isHandWorker &&
          imgCase == EditImageCase.NO_CHANGE) {
        this.screenUtils.showOnSnackBar(msg: "לא שינית דבר אצל העובד");
        return;
      }

      employeeToUpdate.timeModified = DateTime.now();
      final old = toEdit.toJson();
      final changes = employeeToUpdate.toJson();
      changes.removeWhere((key, value) => value == old[key]);
      bool isOk = true;
      if (employeeToUpdate.name != toEdit.name) {
        final allEmployeesWithSameName = await EmployeeHandler()
            .getAllEmployeesWithSameName(employeeToUpdate.name);
        if (allEmployeesWithSameName.isNotEmpty) {
          //check if admin still want to submit with same name
          isOk = false;
          final isSingle = allEmployeesWithSameName.length < 2;
          String title;
          String beforeMessage;
          String list = "\n";
          final intl.DateFormat formatter = intl.DateFormat('dd-MM-yyyy');

          for (Employee employee in allEmployeesWithSameName) {
            list += employee.name +
                "\n" +
                " נוצר בתאריך " +
                formatter.format(employee.timeCreated) +
                "\n";
          }

          String afterMessage =
              "האם אתה בטוח שאתה רוצה להוסיף עובד נוסף עם אותו שם ?";

          if (isSingle) {
            title = "עובד עם שם זהה";
            beforeMessage = "נמצא עובד עם שם זהה במערכת:\n";
          } else {
            title = "עובדים עם שם זהה";
            beforeMessage = "נמצאו עובדים עם שם זהה במערכת:\n";
          }
          Alert(
            context: context,
            type: AlertType.warning,
            title: title,
            desc: beforeMessage + list + afterMessage,
            buttons: [
              DialogButton(
                child: Text(
                  "כן",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  this.submitEditForm(
                    context: context,
                    toEdit: employeeToUpdate,
                    changes: changes,
                    image: this.pickedImage,
                    currentCase: imgCase,
                  );
                },
                width: 60,
                color: Theme.of(context).errorColor,
              ),
              DialogButton(
                child: Text(
                  "ביטול",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();

                  return;
                },
                width: 60,
              )
            ],
          ).show();
        }
      }
      if (isOk) {
        submitEditForm(
          context: context,
          toEdit: employeeToUpdate,
          changes: changes,
          image: this.pickedImage,
          currentCase: imgCase,
        );
      }
    }
  }
}

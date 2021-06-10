import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/EmployeeHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/permission.dart';
import '../../../../models/edit_image_case.dart';
import '../../constants/keys.dart' as Keys;
import '../register_employee_screen.dart';
import 'dart:io';

///
/// View Model class provider for register [Employee] screen
///
final registerEmployeeViewModel =
    Provider.autoDispose<RegisterEmployeeViewModel>((ref) => RegisterEmployeeViewModel());

class RegisterEmployeeViewModel {
  final screenUtils = ScreenUtilsController();

  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// Image Chose by user. null means the user don't want an image for the current employee.
  ///
  File pickedImage;

  ///
  /// cancel button indicator
  ///
  bool isCanceled = false;

  /// submitting all data From the form to database
  void submitRegisterUserForm({
    Employee toAdd,
    String password,
  }) // more fields here according to need
  async {
    EditImageCase imgCase = pickedImage != null
        ? EditImageCase.NEW_IMAGE
        : toAdd.isWithImage() && isCanceled
        ? EditImageCase.DELETE_IMAGE
        : EditImageCase.NO_CHANGE;
    String statusMsg;
    this.screenUtils.isLoading.value = true;
    statusMsg = await EmployeeHandler().register(toAdd, password,pickedImage,imgCase);
    this.screenUtils.isLoading.value = false;
    if (statusMsg.isEmpty) {
      Navigator.of(this.screenUtils.scaffoldKey.currentContext).pop(statusMsg);
    } else {
      this.screenUtils.showOnSnackBar(
            msg: statusMsg,
            successMsg: RegisterEmployeeScreen.successMessageOnSubmit,
          );
    }
  }

  ///
  /// Function of validation and submitting
  ///
  void trySubmit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (this.formKey.currentState.saveAndValidate()) {
      String name = (this
              .formKey
              .currentState
              .fields[Constants.EMPLOYEE_NAME]
              .value as String)
          .trim();
      String email = (this
              .formKey
              .currentState
              .fields[Constants.EMPLOYEE_EMAIL]
              .value as String)
          .toLowerCase()
          .trim();
      String password =
          this.formKey.currentState.fields[Constants.PASSWORD].value as String;
      Permission permission = this
          .formKey
          .currentState
          .fields[Constants.EMPLOYEE_PERMISSION]
          .value as Permission;
      String phoneNumber = (this
              .formKey
              .currentState
              .fields[Constants.EMPLOYEE_PHONE_NUMBER]
              .value as String)
          .toLowerCase()
          .trim();
      bool isHandWorker = this
          .formKey
          .currentState
          .fields[Constants.EMPLOYEE_IS_HAND_WORKER]
          .value as bool;
      Employee newEmployee = Employee(
        email: email,
        name: name,
        isHandWorker: isHandWorker,
        phoneNumber: phoneNumber,
        permission: permission,
      );

      final allEmployeesWithSameName =
          await EmployeeHandler().getAllEmployeesWithSameName(newEmployee.name);
      if (allEmployeesWithSameName.isNotEmpty) {
        //check if admin still want to submit with same name
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
                submitRegisterUserForm(
                  toAdd: newEmployee,
                  password: password,
                );
              },
              width: 60,
              color: StyleConstants.errorColor,
            ),
            DialogButton(
              key: Key(Keys.CANCEL_ADD_SAME_EMPLOYEE),
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
      } else {
        submitRegisterUserForm(
          toAdd: newEmployee,
          password: password,
        );
      }
    }
  }
}

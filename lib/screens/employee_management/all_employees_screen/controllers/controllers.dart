import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../models/Employee.dart';
import '../../employee_edit_screen/edit_employee_screen.dart';
import '../../register_employee_screen/register_employee_screen.dart';
import '../all_employees.dart';

///
/// Provider of View Model for the all employees screen
///
final allEmployeesViewModel = Provider.autoDispose<AllEmployeesViewModel>(
    (ref) => AllEmployeesViewModel());

///
/// View Model class for all employees Screen
///
class AllEmployeesViewModel {
  final screenUtils = ScreenUtilsControllerForList(
    query: ValueNotifier<String>(""),
    editSuccessMessage: "העובד נערך בהצלחה",
    deleteSuccessMessage: "העובד נמחק בהצלחה",
  );

  ///
  /// Navigate to the add employee screen, and show it's result after the add process is finished
  ///
  void navigateAndPushAddUser(BuildContext context) async {
    final result =
        await Navigator.of(context).pushNamed(RegisterEmployeeScreen.routeName);
    FocusScope.of(context).unfocus();
    if (result != null) {
      this.screenUtils.showOnSnackBar(
            msg: result as String,
            successMsg: AllEmployeesEditPage.successMessageOnAdd,
          );
    }
  }

  ///
  /// Navigate to the add employee screen, and show it's result after the add process is finished
  ///
  void navigateAndPushEditUser(BuildContext context, Employee employee) async {
    final result = await Navigator.of(context)
            .pushNamed(EditEmployeeScreen.routeName, arguments: employee)
        as List<dynamic>;

    if (result != null) {
      final bool isDelete = result[0] as bool;
      final String msg = result[1] as String;
      FocusScope.of(this.screenUtils.scaffoldKey.currentContext).unfocus();
      this.screenUtils.showOnSnackBar(
            msg: msg,
            successMsg: isDelete
                ? EditEmployeeScreen.successMessageOnDelete
                : EditEmployeeScreen.successMessageOnSubmit,
          );
    }
  }

  ///
  /// Navigate to the phone app in this phone to call the chosen [Employee]
  ///
  void tryCallEmployee(Employee toCall) {
    UrlLauncher.launch('tel://${toCall.phoneNumber}');
  }
}

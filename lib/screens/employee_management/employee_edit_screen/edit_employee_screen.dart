import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './controllers/controllers.dart';
import './widgets/edit_employee_form.dart';
import '../../../models/Employee.dart';
import '../../../models/permission.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';

///
/// Screen to show to form of editing an existing [Employee]
///
class EditEmployeeScreen extends HookWidget {
  static const routeName = '/edit_employee';
  static const title = 'עריכת משתמש';
  static const successMessageOnSubmit = 'המשתמש נערך בהצלחה';
  static const successMessageOnDelete = 'המשתמש נמחק בהצלחה';

  @override
  Widget build(BuildContext context) {
    Employee toEdit = (ModalRoute.of(context).settings.arguments as Employee);
    final viewModel = useProvider(editEmployeeViewModel);
    return PermissionScreenWithAppBar(
      title: title,
      permissionLevel: Permission.ADMIN,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: SafeArea(
        child: Center(
          child: EditEmployeeForm(toEdit),
        ),
      ),
      withProject: false,
    );
  }
}

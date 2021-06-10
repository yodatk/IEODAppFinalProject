import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './controllers/controllers.dart';
import './widgets/register_form.dart';
import '../../../models/permission.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';

///
/// Screen to show to form of registering new user to the system.
///
class RegisterEmployeeScreen extends HookWidget {
  static const routeName = '/register_employee';
  static const title = 'הוספת משתמש חדש';
  static const successMessageOnSubmit = 'המשתמש נוצר בהצלחה';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(registerEmployeeViewModel);
    return PermissionScreenWithAppBar(
      title: title,
      withProject: false,
      permissionLevel: Permission.ADMIN,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: SafeArea(
        child: Center(
          child: RegisterEmployeeForm(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../constants/general_keys.dart' as GeneralKeys;
import '../../constants/style_constants.dart' as StyleConstants;
import '../../models/permission.dart';
import '../../widgets/navigation/navigation_row.dart';
import '../../widgets/permission_widgets/normal_permission_screen.dart';
import '../employee_management/all_employees_screen/all_employees.dart';
import '../projects_menu_screens/all_projects_screen/all_projects_screen.dart';

class AdminMenuScreen extends StatelessWidget {
  static const routeName = "/admin_menu_screen";
  static const title = "תפריט אדמין";

  @override
  Widget build(BuildContext context) {
    return PermissionScreenWithAppBar(
      title: AdminMenuScreen.title,
      permissionLevel: Permission.ADMIN,
      scaffoldKey: GlobalKey<ScaffoldState>(),
      withProject: false,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            NavigationRow(
              key: Key(GeneralKeys.EMPLOYEES),
              route: AllEmployeesEditPage.routeName,
              title: AllEmployeesEditPage.adminTitle,
              color: StyleConstants.primaryColor,
              icon: StyleConstants.ICON_EMPLOYEES,
              args: false,
            ),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
              key: Key(GeneralKeys.PROJECTS),
              route: AllProjectsScreen.routeName,
              title: AllProjectsScreen.title,
              color: StyleConstants.primaryColor,
              icon: StyleConstants.ICON_PROJECT,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './widgets/employee_list_tile.dart';
import '../../../logger.dart' as Logger;
import '../../../logic/EmployeeHandler.dart';
import '../../../models/Employee.dart';
import '../../../models/permission.dart';
import '../../../screens/employee_management/all_employees_screen/controllers/controllers.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/permission_widgets/permission_widget.dart';
import '../../../widgets/permission_widgets/screen_with_permission.dart';
import '../constants/keys.dart' as Keys;

///
/// Screen to show [Employee] in List Tile.
/// two possible views to this screen:
/// 1. All employees of a given project -> can routed to that screen from the Project Home Screen
/// 2. All Employees In the SYSTEM -> can get routed to that screen from the admin menu
///
class AllEmployeesEditPage extends HookWidget {
  static const inProjectTitle = "עובדים באתר";
  static const adminTitle = "כל העובדים";
  static const routeName = "/all_employees";
  static const successMessageOnAdd = 'העובד נוצר בהצלחה';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allEmployeesViewModel);
    final bool isProjectOnly =
        (ModalRoute.of(context).settings.arguments ?? false) as bool;
    return PermissionScreen(
      permissionLevel: isProjectOnly ? Permission.MANAGER : Permission.ADMIN,
      // if employees of Project, will show only if project is valid. if all employees, will show anyway
      withProject: isProjectOnly,

      title: AllEmployeesEditPage.inProjectTitle,
      body: Scaffold(
        endDrawer: AppDrawer(),
        key: viewModel.screenUtils.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(isProjectOnly
              ? AllEmployeesEditPage.inProjectTitle
              : AllEmployeesEditPage.adminTitle),
        ),
        body: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) =>
                          viewModel.screenUtils.query.value = value,
                      decoration: InputDecoration(
                          labelText: "חיפוש",
                          hintText: "חיפוש",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  StreamBuilder<List<Employee>>(
                    stream: isProjectOnly
                        ? EmployeeHandler().getAllEmployeesFromCurrentProject()
                        : EmployeeHandler().getAllEmployeesAsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        Logger.error(snapshot.error.toString());
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ValueListenableBuilder<String>(
                          valueListenable: viewModel.screenUtils.query,
                          child: Center(
                            child: Text(
                              "לא נמצאו עובדים",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          builder: (BuildContext context, String query,
                              Widget child) {
                            final allEmployees = snapshot.data;
                            final filteredEmployees = allEmployees
                                .where((element) =>
                                    element.name != null &&
                                    element.name.contains(
                                        viewModel.screenUtils.query.value))
                                .toList();
                            filteredEmployees
                                .sort((e1, e2) => e1.name.compareTo(e2.name));

                            return filteredEmployees.isEmpty
                                ? child
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.7),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: filteredEmployees.length,
                                            separatorBuilder:
                                                (context, index) => Divider(),
                                            itemBuilder: (context, index) {
                                              return EmployeeListTile(
                                                filteredEmployees[index],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: PermissionWidget(
          withPermission: Builder(
            builder: (context) => isProjectOnly
                ? SizedBox.shrink()
                : FloatingActionButton(
                    key: Key(Keys.ADD_NEW_EMPLOYEE_BTN),
                    onPressed: () {
                      viewModel.navigateAndPushAddUser(context);
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
          ),
          permissionLevel: Permission.ADMIN,
        ),
      ),
    );
  }
}

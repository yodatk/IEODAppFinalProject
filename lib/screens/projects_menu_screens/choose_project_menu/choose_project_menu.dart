import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/style_constants.dart' as StyleConstants;
import '../../../logger.dart' as Logger;
import '../../../logic/EmployeeHandler.dart';
import '../../../models/permission.dart';
import '../../../widgets/loading_circular.dart';
import '../../../widgets/permission_widgets/permission_widget.dart';
import '../../general_screens/admin_menu_screen.dart';
import '../../general_screens/splash_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/projects_grid.dart';

///
/// <<DEPRECATED>>
/// Screen to choose an active [Project] from a list of [Project] that the current [Employee] is belong to.
///
class ChooseProjectScreen extends HookWidget {
  static const routeName = "/choose_project";
  static const title = "בחר פרויקט";

  @override
  Widget build(BuildContext context) {
    final employee = useProvider(currentEmployee.state);

    final relevantProjects = useProvider(allActiveProjectOfEmployee(employee));

    final viewModel = useProvider(chooseProjectViewModelProvider);

    return relevantProjects.when(
      data: (projects) {
        if (projects.length == 1) {
          viewModel.changeProject(projects.first.id);
          return MySplashScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const FittedBox(
                fit: BoxFit.fitHeight,
                child: const Text(
                  ChooseProjectScreen.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),
            ),
            drawer: ChooseProjectAppDrawer(),
            body: Center(
              child: employee == null
                  ? const LoadingCircularWidget()
                  : projects.isEmpty
                      ? Text(
                          employee.permission == Permission.ADMIN
                              ? "לא קיימים פרויקטים. ניתן להוסיף דרך התפריט"
                              : "לא קיימים פרויקטים עבורך, פנה למנהל האתר",
                          style: Theme.of(context).textTheme.headline6,
                        )
                      : ProjectsGrid(projects),
            ),
          );
        }
      },
      loading: () => MySplashScreen(),
      error: (error, stack) {
        Logger.error(error.toString());
        Logger.error(stack.toString());
        return MySplashScreen();
      },
    );
  }
}

///
/// App Drawer for the Choose Project screen
///
class ChooseProjectAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: Key("hamburgerMenu"),
      child: Column(
        children: <Widget>[
          AppBar(
            centerTitle: true,
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: const Text(
                ChooseProjectScreen.title,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          PermissionWidget(
            permissionLevel: Permission.ADMIN,
            withPermission: Divider(),
          ),
          PermissionWidget(
            permissionLevel: Permission.ADMIN,
            withPermission: ListTile(
              key: Key("adminSettings"),
              leading: Icon(StyleConstants.ICON_ADMIN_SETTINGS),
              title: Text('תפריט אדמין'),
              onTap: () =>
                  Navigator.of(context).pushNamed(AdminMenuScreen.routeName),
            ),
          ),
          Divider(),
          ListTile(
            key: Key("signOut"),
            leading: Icon(StyleConstants.ICON_EXIT_APP),
            title: Text('התנתק'),
            onTap: () async {
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
              await EmployeeHandler().logout();
            },
          ),
        ],
      ),
    );
  }
}

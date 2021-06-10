import 'package:flutter/material.dart';

import '../../constants/constants.dart' as Constants;
import '../../constants/general_keys.dart' as GeneralKeys;
import '../../constants/style_constants.dart' as StyleConstants;
import '../../logic/EmployeeHandler.dart';
import '../../logic/ProjectHandler.dart';
import '../../models/permission.dart';
import '../../screens/general_screens/admin_menu_screen.dart';
import '../../widgets/permission_widgets/permission_widget.dart';

///
/// Default Drawer to navigate to important parts of the app. showing in most of the screens
///
class AppDrawer extends StatelessWidget {
  ///
  /// Title of the App Drawer. default is [Constants.APP_NAME]
  ///
  final String title;

  AppDrawer({this.title = Constants.APP_NAME});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: Key(GeneralKeys.HAMBURGER_MENU),
      child: Column(
        children: <Widget>[
          AppBar(
            centerTitle: true,
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                this.title,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
              leading: Icon(StyleConstants.ICON_HOME_PAGE),
              title: Text('עמוד ראשי'),
              onTap: () =>
                  Navigator.of(context).popUntil(ModalRoute.withName('/'))),
          Divider(),
          ListTile(
              key: Key(GeneralKeys.CHOOSE_PROJECT),
              leading: Icon(StyleConstants.ICON_PROJECT),
              title: Text('שנה פרויקט'),
              onTap: () async {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
                await ProjectHandler().resetCurrentProject(null);
              }),
          PermissionWidget(
            permissionLevel: Permission.ADMIN,
            withPermission: Divider(),
          ),
          PermissionWidget(
            permissionLevel: Permission.ADMIN,
            withPermission: ListTile(
                key: Key(GeneralKeys.ADMIN_SETTINGS),
                leading: Icon(StyleConstants.ICON_ADMIN_SETTINGS),
                title: Text('תפריט אדמין'),
                onTap: () {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                  Navigator.of(context).pushNamed(AdminMenuScreen.routeName);
                }),
          ),
          Divider(),
          ListTile(
            key: Key(GeneralKeys.SIGN_OUT),
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

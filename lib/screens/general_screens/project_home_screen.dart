import 'dart:io' show Platform;

import 'package:IEODApp/widgets/permission_widgets/permission_denied_widget.dart';
import 'package:IEODApp/widgets/permission_widgets/screen_with_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../all_screens.dart';
import '../constants/keys.dart' as Keys;
import '../../constants/constants.dart' as Constants;
import '../../constants/style_constants.dart' as StyleConstants;
import '../../logger.dart' as Logger;
import '../../logic/EmployeeHandler.dart';
import '../../logic/ProjectHandler.dart';
import '../../models/all_models.dart';
import '../../models/permission.dart';
import '../../widgets/navigation/app_drawer.dart';
import '../../widgets/navigation/navigation_row.dart';
import '../../widgets/permission_widgets/permission_widget.dart';
import '../employee_management/all_employees_screen/all_employees.dart';

const app_url = 'arcgis-collector://';
const playstore_url =
    'https://play.google.com/store/apps/details?id=com.esri.arcgis.collector';

class ProjectHomeScreen extends StatefulHookWidget {
  static const routeName = '/specific_project_menu';
  static const title = "עמוד פרויקט";

  @override
  _ProjectHomeScreenState createState() => _ProjectHomeScreenState();
}

class _ProjectHomeScreenState extends State<ProjectHomeScreen> {
  void _launchURL({String appURL, String secondaryURL}) async =>
      await canLaunch(appURL)
          ? await launch(appURL)
          : (await canLaunch(secondaryURL)
              ? await launch(secondaryURL)
              : throw 'Could not launch $playstore_url');

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final currentProject = useProvider(currentProjectProvider.state);
    final waitingWidget = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(ProjectHomeScreen.title),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    return currentEmployee == null
        ? waitingWidget
        : (currentProject == null ||
                !currentProject.isActive ||
                !currentProject.employees.contains(currentEmployee.id))
            ? PermissionDeniedScreen(
                title: "שלום ${currentEmployee.name}",
                msg: PermissionDeniedWidget.INVALID_PROJECT_MSG,
              )
            : Scaffold(
                floatingActionButton: PermissionWidget(
                    withPermission: MaterialButton(
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          _launchURL(
                              appURL: Constants.COLLECTOR_ANDROID_APP_URL,
                              secondaryURL: Constants.COLLECTOR_PLAYSTORE_URL);
                        } else if (Platform.isIOS) {
                          Logger.critical(
                              "COLLECTOR LAUNCHER NOT IMPLEMENTED YET IN IOS");
                        }
                      },
                      color: Theme.of(context).accentColor,
                      textColor: StyleConstants.textColorOnPrimary,
                      child: Icon(
                        Icons.my_location,
                        size: 30,
                      ),
                      padding: EdgeInsets.all(16),
                      shape: CircleBorder(),
                    ),
                    permissionLevel: Permission.MANAGER),
                appBar: AppBar(
                  centerTitle: true,
                  title: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("שלום ${currentEmployee.name}"),
                  ),
                ),
                drawer: AppDrawer(),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            currentProject?.name ?? "שגיאה",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      Center(
                        child: ListView(
                          key: Key(Keys.MAIN_MENU_LIST),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10),
                          children: <Widget>[
                            PermissionWidget(
                              permissionLevel: Permission.MANAGER,
                              withPermission: NavigationRow(
                                key: Key(Keys.EMPLOYEES_SCREEN),
                                icon: StyleConstants.ICON_EMPLOYEES,
                                color: Theme.of(context).accentColor,
                                route: AllEmployeesEditPage.routeName,
                                title: AllEmployeesEditPage.inProjectTitle,
                                textColor: StyleConstants.textColorOnPrimary,
                                args: true,
                              ),
                            ),
                            PermissionWidget(
                              withPermission: NavigationRow(
                                key: Key(Keys.PLOT_AND_SITE_SCREEN),
                                title: AllSitesAndPlotsScreen.title,
                                route: AllSitesAndPlotsScreen.routeName,
                                color: Theme.of(context).accentColor,
                                icon: StyleConstants.ICON_PLOT,
                                textColor: StyleConstants.textColorOnPrimary,
                              ),
                              permissionLevel: Permission.MANAGER,
                            ),
                            NavigationRow(
                              key: Key(Keys.DAILY_INFO_SCREEN),
                              title: DailyInfoScreen.title,
                              route: DailyInfoScreen.routeName,
                              color: Theme.of(context).accentColor,
                              icon: Icons.calendar_today,
                              textColor: StyleConstants.textColorOnPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}

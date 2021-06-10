import 'package:IEODApp/widgets/permission_widgets/permission_denied_widget.dart';
import 'package:IEODApp/widgets/permission_widgets/screen_with_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../constants/style_constants.dart' as StyleConstants;
import '../../../logic/EmployeeHandler.dart';
import '../../../logic/ProjectHandler.dart';
import '../../../models/permission.dart';
import '../../../widgets/navigation/navigation_row.dart';
import '../../../widgets/permission_widgets/permission_widget.dart';
import '../arrangment/allArrangements/all_arrangements_screen.dart';
import '../constants/keys.dart' as Keys;
import '../daily_images/all_images_folders/all_images_folders_screen.dart';
import '../daily_reports/daily_reports_screen.dart';
import 'controllers/controllers.dart';

///
/// Shows all option of the Daily Info Menu.
///
class DailyInfoScreen extends HookWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = "/daily_info";

  ///
  /// Title of this screen
  ///
  static const title = "מידע יומי";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificReportsForDateViewModel);
    final currentProject = useProvider(currentProjectProvider.state);
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    return !ProjectHandler().projectIsValid(currentProject, currentEmployee)
        ? PermissionDeniedScreen(
            title: DailyInfoScreen.title,
            msg: PermissionDeniedWidget.INVALID_PROJECT_MSG,
          )
        : Scaffold(
            key: viewModel.screenUtils.scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              title: const Text(DailyInfoScreen.title),
              actions: [
                PermissionWidget(
                    withPermission: ValueListenableBuilder<bool>(
                      valueListenable: viewModel.screenUtils.isLoading,
                      child: const Center(
                          child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: const CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ))),
                      builder: (BuildContext context, bool isLoading,
                              Widget child) =>
                          isLoading
                              ? child
                              : IconButton(
                                  icon: Icon(Icons.today),
                                  onPressed: () async {
                                    await viewModel.dialogCall(context);
                                  },
                                  tooltip: "הפקת דוחות לתאריך",
                                ),
                    ),
                    permissionLevel: Permission.MANAGER)
              ],
            ),
            body: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                children: <Widget>[
                  NavigationRow(
                      key: Key(Keys.DRIVE_MENU),
                      route: AllArrangementsScreen.routeName,
                      title: Constants.DRIVE_ARRANGEMENT_TITLE,
                      color: Colors.limeAccent,
                      icon: StyleConstants.ICON_DRIVE_ARRANGEMENT,
                      args: Constants.DRIVE_ARRANGEMENT_TITLE),
                  const SizedBox(
                    height: 20,
                  ),
                  NavigationRow(
                    key: Key(Keys.WORK_MENU),
                    route: AllArrangementsScreen.routeName,
                    title: Constants.WORK_ARRANGEMENT_TITLE,
                    color: Colors.orange,
                    icon: StyleConstants.ICON_WORK_ARRANGEMENT,
                    args: Constants.WORK_ARRANGEMENT_TITLE,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  NavigationRow(
                    key: Key(Keys.IMAGES_MENU),
                    route: AllImagesFoldersScreen.routeName,
                    title: AllImagesFoldersScreen.title,
                    color: Colors.deepOrange,
                    icon: StyleConstants.ICON_DAILY_IMAGES,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PermissionWidget(
                      permissionLevel: Permission.MANAGER,
                      withPermission: NavigationRow(
                        key: Key(Keys.DAILY_REPORTS_MENU),
                        route: DailyReportsScreen.routeName,
                        title: DailyReportsScreen.title,
                        color: Colors.deepOrangeAccent,
                        icon: StyleConstants.ICON_REPORT,
                      )),
                ],
              ),
            ),
          );
  }
}

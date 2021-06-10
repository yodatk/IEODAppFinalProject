import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../logger.dart' as Logger;
import '../../logic/EmployeeHandler.dart';
import '../../logic/ProjectHandler.dart';
import '../../models/Employee.dart';
import '../../models/permission.dart';
import '../../models/project.dart';
import '../screen.dart';
import 'permission_denied_widget.dart';

///
/// Widget which showing only if the current given user is with the right permission, and in a valid [Project]
///
class PermissionScreen extends HookWidget {
  /// [Permission] level necessary to see the screen
  final Permission permissionLevel;

  /// [Widget] to show if the current user is with the right permission
  final Widget body;

  /// Title to show at app bar
  final String title;

  /// If true, -> the screen is blocked if current project is null, otherwise - can access the page if the current project is null
  /// default is true
  final bool withProject;

  PermissionScreen({
    @required this.permissionLevel,
    @required this.title,
    @required this.body,
    this.withProject = true,
  });

  /// Returns the right widget according the the permission level of the [currentUser]
  Widget stateAccordingToUser(Employee currentUser) {
    if (currentUser != null &&
        currentUser.isPermissionOk(this.permissionLevel)) {
      return this.body; // return the wanted widget
    } else {
      return PermissionDeniedScreen(title: title); // return blank widget
    }
  }

  bool projectIsValid(Project projectToCheck, Employee currentEmployee) {
    return !this.withProject ||
        ProjectHandler().projectIsValid(projectToCheck, currentEmployee);
  }

  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final currentProject = useProvider(currentProjectProvider.state);
    if (currentEmployee == null ||
        (!projectIsValid(currentProject, currentEmployee))) {
      // employee is not logged in OR project is in-active OR employee does not belong to the project -> going back to main menu
      Future.microtask(() {
        Logger.warning(
            "you permissions settings / project settings has been changed. talk to your supervisor");
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      });
      return PermissionDeniedScreen(
        title: this.title,
        msg: currentProject == null
            ? PermissionDeniedWidget.INVALID_PROJECT_MSG
            : PermissionDeniedWidget.PERMISSION_DENIED_MSG,
      );
    }

    return stateAccordingToUser(currentEmployee);
  }
}

///
/// Screen to show to user when it doesn't have the [Permission] to access current screen
///
class PermissionDeniedScreen extends StatelessWidget {
  PermissionDeniedScreen({
    Key key,
    @required this.title,
    this.msg = PermissionDeniedWidget.PERMISSION_DENIED_MSG,
  }) : super(key: key);

  ///
  /// Title to put on the AppBar
  ///
  final String title;

  ///
  /// Message to shoe in the center of the screen
  ///
  final String msg;

  ///
  /// Scaffold key for that screen
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return NormalScreen(
      body: PermissionDeniedWidget(
        msg: msg,
      ),
      title: title,
      scaffoldKey: _scaffoldKey,
    );
  }
}

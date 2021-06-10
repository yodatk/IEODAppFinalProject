import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/permission.dart';
import '../screen.dart';
import 'screen_with_permission.dart';

///
/// Normal Screen [Widget] with [Permission] protector.
/// main use case of this widget is to let users enter the screen only if the user has the right permission \ it is in the right project
///
class PermissionScreenWithAppBar extends StatelessWidget {
  /// [Permission] level necessary to see the screen
  final Permission permissionLevel;

  /// Title to show at app bar
  final String title;

  /// Scaffold key for the normal screen
  final GlobalKey<ScaffoldState> scaffoldKey;

  /// [Widget] to show if the current user is with the right permission
  /// IMPORTANT - the body cannot be a scaffold or an app bar. since it's already inside of one
  final Widget body;

  /// If 'true' -> the screen is blocked if current project is null, otherwise - can access the page if the current project is null
  /// default is 'true'
  final bool withProject;

  PermissionScreenWithAppBar({
    @required this.title,
    @required this.permissionLevel,
    @required this.scaffoldKey,
    @required this.body,
    this.withProject = true,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      permissionLevel: this.permissionLevel,
      withProject: this.withProject,
      title: this.title,
      body: NormalScreen(
        title: this.title,
        scaffoldKey: this.scaffoldKey,
        body: this.body,
      ),
    );
  }
}

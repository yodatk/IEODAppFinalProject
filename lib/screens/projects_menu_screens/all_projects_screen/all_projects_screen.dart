import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/projectsList.dart';

///
/// Screen to show all possible project to edit. from that screen the user can delete a project, and add a new one .
///
class AllProjectsScreen extends HookWidget {
  ///
  /// route fo this screen
  ///
  static const routeName = "/all_projects_screen";

  ///
  /// title to put on the AppBar
  ///
  static const title = "פרויקטים";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allProjectsViewModel);
    return PermissionScreenWithAppBar(
      permissionLevel: Permission.ADMIN,
      title: title,
      body: SafeArea(
        child: ProjectsList(),
      ),
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      withProject: false,
    );
  }
}

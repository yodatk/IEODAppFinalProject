import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../models/project.dart';
import '../../../widgets/loading_circular.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../../../widgets/unexpected_error_widget.dart';
import '../all_projects_screen/controllers/controllers.dart';
import 'controllers/controllers.dart';
import 'widgets/edit_project_form.dart';

///
/// Screen for the editing an [Project] entity
///
class EditProjectScreen extends HookWidget {
  ///
  /// Route to get to this screen
  ///
  static const routeName = "/edit_specific_project";

  @override
  Widget build(BuildContext context) {
    final allProjects = useProvider(allProjectsProvider);
    Project project = (ModalRoute.of(context).settings.arguments as Project);
    final scaffoldKey =
        useProvider(editProjectViewModel).screenUtils.scaffoldKey;
    return allProjects.when(
        data: (projects) => PermissionScreenWithAppBar(
              title: project == null ? "הוספת פרויקט" : "עריכת פרויקט",
              permissionLevel: Permission.ADMIN,
              scaffoldKey: scaffoldKey,
              body: SafeArea(
                child: EditProjectForm(
                  toEdit: project,
                  allProjects: projects,
                ),
              ),
              withProject: false,
            ),
        loading: () => const LoadingCircularWidget(),
        error: (error, stack) => printAndShowErrorWidget(error, stack));
  }
}

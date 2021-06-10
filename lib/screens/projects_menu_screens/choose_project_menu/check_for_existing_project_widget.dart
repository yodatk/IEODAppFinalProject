import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logger.dart' as Logger;
import '../../../logic/ProjectHandler.dart';
import '../../../models/permission.dart';
import '../../../widgets/loading_circular.dart';
import '../../general_screens/project_home_screen.dart';
import '../../general_screens/splash_screen.dart';
import '../choose_project_menu/widgets/projects_grid.dart';
import 'choose_project_menu.dart';
import 'controllers/controllers.dart';

///
/// Main part of the Main widget. after the user is logged in, this widget is in charge of showing the correct Widget according to the current project state.
/// this are the possible outcome:
/// 1. The user has a projectId saved in cache -> will load that project and route to project home screen
/// 2. the user has multiple active projects -> will show all active project to choose one from
/// 3. the user has only one project -> will preload it and route to the project homescreen
/// 4. the user has no active projects -> will show an empty choose project screen with an info message.
/// admin could go to the admin menu in any one of the options
///
class CheckForExistingProject extends HookWidget {
  static const routeName = "/check_for_choose_project";
  static const title = "בחר פרויקט";

  @override
  Widget build(BuildContext context) {
    final employee = useProvider(currentEmployee.state);
    final loadLastProjectFuture = useProvider(loadLastProjectProvider);
    final currentProject = useProvider(currentProjectProvider.state);
    final relevantProjects = useProvider(allActiveProjectOfEmployee(employee));
    final viewModel = useProvider(chooseProjectViewModelProvider);
    if (employee == null) {
      return MySplashScreen();
    } else {
      return loadLastProjectFuture.when(
        data: (data) {
          if (currentProject != null &&
              currentProject.employees.contains(employee.id) &&
              currentProject.isActive) {
            return PreLoadProjectWidget();
          } else {
            if (currentProject != null) {
              ProjectHandler().resetCurrentProject(null);
              return MySplashScreen();
            } else {
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
                            style: const TextStyle(
                                color: Colors.white, fontSize: 26),
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
                                    style:
                                        Theme.of(context).textTheme.headline6,
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
        },
        loading: () => MySplashScreen(),
        error: (error, stack) {
          Logger.error(error.toString());
          return MySplashScreen();
        },
      );
    }
  }
}

///
/// Widget to pre-load all data the belongs to a certain project
///
class PreLoadProjectWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final preLoadProject = useProvider(preloadProjectProvider);
    return preLoadProject.when(
      data: (data) => ProjectHomeScreen(),
      loading: () => MySplashScreen(),
      error: (error, stack) {
        // try to reset to null to get to a different screen
        ProjectHandler().resetCurrentProject(null);
        Logger.critical(error.toString());
        Logger.critical(stack.toString());
        return MySplashScreen();
      },
    );
  }
}

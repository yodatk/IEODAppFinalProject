import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logic/EmployeeHandler.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/project.dart';

final currentEmployee = currentEmployeeProvider;

final allActiveProjectOfEmployee =
    StreamProvider.autoDispose.family<List<Project>, Employee>((ref, employee) {
  return ProjectHandler().getAllActiveProjectsOfCurrentUser(employee.id);
});

final preloadProjectProvider = FutureProvider.autoDispose(
    (ref) => ProjectHandler().preLoadDataOfProject());

final chooseProjectViewModelProvider =
    Provider.autoDispose<ChooseProjectViewModel>(
        (ref) => ChooseProjectViewModel());

final loadLastProjectProvider = FutureProvider.autoDispose(
    (ref) => ProjectHandler().loadLastProjectToController());
final resetProjectProvider = FutureProvider.autoDispose(
    (ref) => ProjectHandler().resetCurrentProject(null));

class ChooseProjectViewModel {
  ScreenUtilsController screenUtils = ScreenUtilsController();

  Future<void> changeProject(String projectId) async {
    await ProjectHandler().resetCurrentProject(projectId);
  }
}

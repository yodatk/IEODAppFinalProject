import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/snackbar_capable.dart';
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../models/project.dart';
import '../../../../widgets/loading_circular.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';
import 'project_tile.dart';

///
/// Main widget in the all projects list screen. shows all the project as a list tiles
///
class ProjectsList extends StatefulHookWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectsList> with SnackBarCapable {
  ///
  /// filter the project by the given [newQuery] : only project that contain the query in the name will show on screen
  ///
  void filterSearchResults(
          ScreenUtilsControllerForList<String> screenUtils, String newQuery) =>
      screenUtils.query.value = newQuery;

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allProjectsViewModel);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(width: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: FormBuilderTextField(
                    name: "date",
                    onChanged: (value) =>
                        filterSearchResults(viewModel.screenUtils, value),
                    decoration: const InputDecoration(
                        labelText: "חיפוש פרויקטים",
                        hintText: "חיפוש פרויקטים",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                const SizedBox(width: 5),
                ValueListenableBuilder<bool>(
                  valueListenable: viewModel.screenUtils.isLoading,
                  builder: (BuildContext context, bool value, Widget child) {
                    return value ? const CircularProgressIndicator() : child;
                  },
                  child: RaisedButton(
                    key: const Key(Keys.ADD_PROJECT_BTN),
                    onPressed: () =>
                        viewModel.navigateAndPushCreateProject(context),
                    color: Theme.of(context).accentColor,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            ActualList(),
          ],
        ),
      ),
    );
  }
}

///
/// Widget to load all projects, and convert them to list tiles
///
class ActualList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allProjectsViewModel);
    final allProjects = useProvider(allProjectsProvider);
    return allProjects.when(
      loading: () => LoadingCircularWidget(),
      error: (error, stack) => printAndShowErrorWidget(error, stack),
      data: (data) {
        return ValueListenableBuilder<String>(
          valueListenable: viewModel.screenUtils.query,
          child: Center(
            child: Text(
              "לא נמצאו פרויקטים",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          builder: (BuildContext context, String query, Widget child) {
            List<Project> filteredProjects =
                viewModel.filterProjects(data, query);

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: filteredProjects.isEmpty
                  ? child
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredProjects.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox.shrink(),
                            itemBuilder: (context, index) {
                              return ProjectListTile(
                                project: filteredProjects[index],
                                // handleEditOrDeleteResult:
                                //     _handleEditOrDeleteResult,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

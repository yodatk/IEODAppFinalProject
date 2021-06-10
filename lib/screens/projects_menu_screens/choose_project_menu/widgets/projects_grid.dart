import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../models/project.dart';
import 'project_tile.dart';

///
/// Show all possible active [Project] for an [Employee] to choose from.
///
class ProjectsGrid extends HookWidget {
  ///
  /// List of [Project] that the current user can connect to
  ///
  final List<Project> projects;

  ProjectsGrid(
    this.projects,
  );

  @override
  Widget build(BuildContext context) {
    projects.sort((a, b) => b.timeModified.compareTo(a.timeModified));
    return projects.isNotEmpty
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: projects.length,
              itemBuilder: (ctx, i) => ProjectTile(projects[i]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

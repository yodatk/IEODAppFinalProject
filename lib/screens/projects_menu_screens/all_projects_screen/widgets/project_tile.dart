import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/project.dart';
import '../controllers/controllers.dart';

///
/// List tile to represents the [Project] entity
///
class ProjectListTile extends HookWidget {
  ///
  /// Project to show \ edit
  ///
  final Project project;

  ProjectListTile({
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allProjectsViewModel);
    return Center(
      child: ExpansionTile(
        leading: project.isActive
            ? const Icon(
                Icons.done,
                color: Colors.green,
              )
            : const Icon(
                Icons.do_not_disturb,
                color: Colors.red,
              ),
        key: Key(project.name),
        title: Text(
          project.getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(project.getSubTitle()),
        children: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  height: 60.0,
                  color: Colors.green,
                  onPressed: () {
                    viewModel.navigateAndPushEditProject(context, this.project);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'ערוך',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FlatButton(
                  textColor: Colors.white,
                  height: 60.0,
                  color: Theme.of(context).errorColor,
                  onPressed: () {
                    viewModel.deleteProject(context, this.project);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'מחק',
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

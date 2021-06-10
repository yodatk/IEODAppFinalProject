import 'package:flutter/foundation.dart';

import '../../../models/project.dart';
import 'entity_dao.dart';

///
/// Specific Entity for the [Project] entity
///
abstract class ProjectDAO extends EntityDAO<Project> {
  ///
  /// Adds project [toAdd] and handles all the sub tasks that comes with it
  ///
  Future<String> addProject(Project toAdd);

  ///
  /// Deletes project [toDelete] and handles all the sub tasks that comes with it
  ///
  Future<String> deleteProject(Project toDelete);

  ///
  /// Edit project [toEdit] and handles all the sub tasks that comes with it
  /// [employeesToRemove] - list of [Employee] id's that needs to be removed from the project, and also to remove the project [toEdit] from them
  /// [employeesToAdd] - list of [Employee] id's to add to [toEdit] and also add [toEdit] to them
  ///
  Future<String> editProject(
      {@required Project toEdit,
      @required List<String> employeesToRemove,
      @required List<String> employeesToAdd});

  ///
  /// Pre-generates a project id before uploading it.
  ///
  String generateProjectId();
}

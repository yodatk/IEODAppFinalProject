import 'package:flutter/foundation.dart';

import '../../../models/site.dart';
import 'entity_dao.dart';

///
/// Specific DAO for the [Site] Entity.
///
abstract class SiteDAO extends EntityDAO<Site> {
  ///
  /// Check if a [Site] with a given [siteName] and [Project] with the given id of [projectId] exists.
  /// if so , return 'true' otherwise - 'false'
  ///
  Future<bool> checkIfSiteExistsInProject(
      {@required String siteName, @required String projectId});

  ///
  /// Removing site [toRemove] from [Project] with [projectId].
  /// If a site with the given name doesn't exists in this project, or if there was another problem with server, will return string with error message.
  /// Otherwise, will return empty screen as a symbol of success operation
  ///
  Future<String> removeSite(
      {@required Site toRemove, @required String projectId});

  ///
  /// Updates site [toUpdate] for the [Project] with the given [projectId].
  /// If a site with the given name already exists in this project, or if there was another problem with server, will return string with error message.
  /// Otherwise, will return empty screen as a symbol of success operation
  Future<String> updateSite(
      {@required Site toUpdate, @required String projectId});
}

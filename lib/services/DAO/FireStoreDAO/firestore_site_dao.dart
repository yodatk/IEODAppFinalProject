import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../models/site.dart';
import '../../services_firebase/firebase_data_service.dart';
import '../interfacesDAO/site_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Strip] DAO with Firestore
///
class FireStoreSiteDAO extends FireStoreEntityDAO<Site> implements SiteDAO {
  FireStoreSiteDAO()
      : super(
            collectionName: Constants.SITE_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Site.fromJson(id: id, data: data));

  ///
  /// Check if a [Site] with a given [siteName] and [Project] with the given id of [projectId] exists.
  /// if so , return 'true' otherwise - 'false'
  ///
  Future<bool> checkIfSiteExistsInProject(
      {@required String siteName, @required String projectId}) async {
    CollectionReference sites = FireStoreDataService()
        .getRoot()
        .collection(Constants.PROJECTS)
        .doc(projectId)
        .collection(Constants.SITE_COLLECTION_NAME);
    try {
      final siteDoc =
          await sites.where(Constants.SITE_NAME, isEqualTo: siteName).get();
      return siteDoc.docs.length > 0;
    } catch (error) {
      Logger.error("error in checkIfSiteExistsInProject:\n$error");
      return true;
    }
  }

  ///
  /// Removing site [toRemove] from [Project] with [projectId].
  /// If a site with the given name doesn't exists in this project, or if there was another problem with server, will return string with error message.
  /// Otherwise, will return empty screen as a symbol of success operation
  ///
  Future<String> removeSite(
      {@required Site toRemove, @required String projectId}) async {
    CollectionReference sites = FireStoreDataService()
        .getRoot()
        .collection(Constants.PROJECTS)
        .doc(projectId)
        .collection(Constants.SITE_COLLECTION_NAME);

    try {
      final isSiteExists = await this.checkIfSiteExistsInProject(
          siteName: toRemove.name, projectId: projectId);
      if (!isSiteExists) {
        Logger.error("removeSite: site doesn't exists");
        return "לא קיים אתר עם שם זה";
      } else {
        // delete all plots as well
        final plots = await FireStoreDataService()
            .getRoot()
            .collection(Constants.PROJECTS)
            .doc(projectId)
            .collection(Constants.PLOT_COLLECTION_NAME)
            .where(Constants.PLOT_SITE_ID, isEqualTo: toRemove.id)
            .get();
        final docRef = sites.doc(toRemove.id);
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (DocumentSnapshot doc in plots.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(docRef);
        await batch.commit();
        return "";
      }
    } catch (error) {
      final msg = handleGeneralError(error, 'removeSite');
      return msg;
    }
  }

  ///
  /// Updates site [toUpdate] for the [Project] with the given [projectId].
  /// If a site with the given name already exists in this project, or if there was another problem with server, will return string with error message.
  /// Otherwise, will return empty screen as a symbol of success operation
  Future<String> updateSite(
      {@required Site toUpdate, @required String projectId}) async {
    toUpdate.timeModified = DateTime.now();

    CollectionReference sites = FireStoreDataService()
        .getRoot()
        .collection(Constants.PROJECTS)
        .doc(projectId)
        .collection(Constants.SITE_COLLECTION_NAME);
    try {
      final isSiteExists = await this.checkIfSiteExistsInProject(
          siteName: toUpdate.name, projectId: projectId);
      if (isSiteExists) {
        return "אתר עם שם זהה כבר קיים בפרויקט זה";
      } else {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        final docRef = sites.doc(toUpdate.id);
        batch.update(docRef, toUpdate.toJson());
        await batch.commit();
        return "";
      }
    } catch (error) {
      final msg = handleGeneralError(error, 'updateSite');
      return msg;
    }
  }
}

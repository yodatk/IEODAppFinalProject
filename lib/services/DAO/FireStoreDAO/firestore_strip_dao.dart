import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../models/strip.dart';
import '../interfacesDAO/strip_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Strip] DAO with Firestore
///
class FireStoreStripDAO extends FireStoreEntityDAO<Strip> implements StripDAO {
  FireStoreStripDAO()
      : super(
            collectionName: Constants.STRIP_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Strip.fromJson(id: id, data: data));

  @override
  Future<String> addMultipleStrips(
      {@required List<Strip> toAdd, @required String projectId}) async {
    try {
      final collectionRef = getCollectionReference(projectId: projectId);
      getNewBatch();
      for (Strip current in toAdd) {
        final newDoc = collectionRef.doc();
        this.writeBatch.set(newDoc, current.toJson());
      }
      await this.writeBatch.commit();
      return "";
    } catch (error) {
      Logger.error("error in addMultipleStrips:\n$error");
      return Constants.GENERAL_ERROR_MSG;
    }
  }
}

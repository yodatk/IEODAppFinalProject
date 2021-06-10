import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../models/work_arrangement.dart';
import '../interfacesDAO/work_arrangement_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [WorkArrangement] DAO with Firestore
///
class FireStoreWorkArrangementDAO extends FireStoreEntityDAO<WorkArrangement>
    implements WorkArrangementDAO {
  FireStoreWorkArrangementDAO()
      : super(
            collectionName: Constants.WORK_ARRANGEMENT_PATH,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                WorkArrangement.fromJson(id: id, data: data));
}

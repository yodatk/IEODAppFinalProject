import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../models/drive_arrangement.dart';
import '../interfacesDAO/drive_arrangement_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [DriveArrangement] DAO with Firestore
///
class FireStoreDriveArrangementDAO extends FireStoreEntityDAO<DriveArrangement>
    implements DriveArrangementDAO {
  FireStoreDriveArrangementDAO()
      : super(
            collectionName: Constants.DRIVE_ARRANGEMENT_PATH,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                DriveArrangement.fromJson(id: id, data: data));
}

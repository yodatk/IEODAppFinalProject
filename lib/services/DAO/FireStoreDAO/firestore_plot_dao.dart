import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../models/plot.dart';
import '../interfacesDAO/plot_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Plot] DAO with Firestore
///
class FireStorePlotDAO extends FireStoreEntityDAO<Plot> implements PlotDAO {
  FireStorePlotDAO()
      : super(
            collectionName: Constants.PLOT_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Plot.fromJson(id: id, data: data));
}

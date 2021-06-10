import 'package:flutter/foundation.dart';

import '../../../models/strip.dart';
import 'entity_dao.dart';

///
/// Specific DAO for the [Strip] entity
///
abstract class StripDAO extends EntityDAO<Strip> {
  ///
  /// Adds multiple Strips at once
  ///
  Future<String> addMultipleStrips(
      {@required List<Strip> toAdd, @required String projectId});
}

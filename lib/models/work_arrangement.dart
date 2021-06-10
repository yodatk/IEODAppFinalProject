import 'package:flutter/cupertino.dart';

import '../models/all_models.dart';
import '../utils/datetime_utils.dart';
import 'arrangement_type.dart';
import 'entity.dart';

///
/// [Entity] to represent a Work Arrangement in a [Project]
///
class WorkArrangement extends Arrangement {
  final ArrangementType arrangementType = ArrangementType.WORK;

  WorkArrangement({
    DateTime date,
    String freeTextInfo,
    EmployeeForDocs lastEditor,
    String id,
  }) : super(
            date: date,
            freeTextInfo: freeTextInfo,
            id: id,
            lastEditor: lastEditor);

  @override
  String toString() {
    return "סידור עבודה: " + "$freeTextInfo (${dateToString(date)})";
  }

  ///
  /// Construct [WorkArrangement] from given [id] and Json object [data]
  ///
  WorkArrangement.fromJson(
      {@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data);

  ///
  /// Copy Constructors for [WorkArrangement]
  ///
  WorkArrangement.copy(WorkArrangement other) : super.copy(other);

  @override
  Entity clone() {
    return WorkArrangement.copy(this);
  }
}

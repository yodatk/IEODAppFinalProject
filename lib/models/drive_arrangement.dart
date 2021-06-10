import 'package:flutter/material.dart';

import '../models/all_models.dart';
import '../utils/datetime_utils.dart';
import 'arrangement_type.dart';
import 'entity.dart';

///
/// [Entity] to represents a Drive Arrangement in a Project
///
class DriveArrangement extends Arrangement {
  final ArrangementType arrangementType = ArrangementType.DRIVE;

  DriveArrangement(
      {DateTime date,
      String freeTextInfo,
      EmployeeForDocs lastEditor,
      String id})
      : super(
            date: date,
            freeTextInfo: freeTextInfo,
            id: id,
            lastEditor: lastEditor);

  @override
  String toString() {
    return "סידור נסיעה: " + "$freeTextInfo (${dateToString(date)})";
  }

  ///
  /// Construct [DriveArrangement] from given [id] and Json object [data]
  ///
  DriveArrangement.fromJson(
      {@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data);

  ///
  /// Copy Constructors for [DriveArrangement]
  ///
  DriveArrangement.copy(DriveArrangement other) : super.copy(other);

  @override
  Entity clone() {
    return DriveArrangement.copy(this);
  }
}

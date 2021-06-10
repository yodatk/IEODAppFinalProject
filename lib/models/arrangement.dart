import 'package:flutter/cupertino.dart';

import '../constants/constants.dart' as Constants;
import '../utils/datetime_utils.dart';
import 'Employee.dart';
import 'editable.dart';
import 'entity.dart';

///
/// [Entity] to describe a daily arrangement
///
class Arrangement extends Entity implements Editable {
  ///
  /// current date of the [Arrangement]
  ///
  DateTime date;

  ///
  /// info on the this [Arrangement]
  ///
  String freeTextInfo;

  ///
  /// last editor to edit this [Arrangement]
  ///
  EmployeeForDocs lastEditor;

  Arrangement({
    String id = "",
    this.date,
    this.freeTextInfo,
    this.lastEditor,
  }) : super(
          id: id,
          timeCreated: DateTime.now(),
          timeModified: DateTime.now(),
        );

  ///
  /// Generates [String] title from this [Arrangement] to show in list
  ///
  String generateTitle() {
    return dateToString(date);
  }

  ///
  /// Generates sub-title from this [Arrangement] to show in list
  ///
  String getSubtitle() {
    final start = "עריכה אחרונה: ";

    final editor = this.lastEditor != null ? this.lastEditor.name + " " : "";
    final afterEditor = "ב-";

    return start +
        editor +
        afterEditor +
        dateToString(this.timeModified) +
        ", " +
        dateToHourString(this.timeModified);
  }

  ///
  /// Copy Constructors for [Arrangement]
  ///
  Arrangement.copy(Arrangement other) : super.copy(other) {
    this.date = other.date;
    this.freeTextInfo = other.freeTextInfo;
    this.lastEditor =
        other.lastEditor == null ? null : other.lastEditor.clone();
  }

  ///
  /// Construct [Arrangement] from given [id] and Json object [data]
  ///
  Arrangement.fromJson(
      {@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.date =
        (DateTime.fromMillisecondsSinceEpoch(data[Constants.A_DATE] as int) ??
                DateTime.now())
            .toLocal();
    this.freeTextInfo = data[Constants.A_FREE_TEXT_INFO] as String ?? "";
    this.lastEditor = data[Constants.A_LAST_EDITOR] == null
        ? null
        : EmployeeForDocs.fromJson(
            data[Constants.A_LAST_EDITOR] as Map<String, dynamic>);
  }

  ///
  /// Converts this [Arrangement] to Json object
  ///
  @override
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// Part of the 'toJson' function. Converts this [Arrangement] attributes to Json Object
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.A_DATE: date.millisecondsSinceEpoch,
      Constants.A_FREE_TEXT_INFO: freeTextInfo,
      Constants.A_LAST_EDITOR:
          this.lastEditor == null ? null : this.lastEditor.toJson(),
    };
  }

  @override
  Entity clone() {
    return Arrangement.copy(this);
  }

  @override
  bool isNew() => this.id == null || this.id == "";

  @override
  void setLastEditor(EmployeeForDocs newEmployee) {
    this.lastEditor = newEmployee;
  }

  @override
  void updateLastModified() {
    if (!this.isNew()) {
      this.timeModified = DateTime.now();
    }
  }

  @override
  bool validateMustFields() => this.date != null && this.freeTextInfo != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Arrangement &&
          other.id == this.id &&
          other.date == this.date &&
          other.freeTextInfo == this.freeTextInfo;

  @override
  int get hashCode => this.id.hashCode;
}

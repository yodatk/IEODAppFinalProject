import 'package:flutter/foundation.dart';

import './builders/acceptOutputBuilders.dart';
import '../../constants/constants.dart' as Constants;
import '../../utils/datetime_utils.dart';
import '../Employee.dart';
import '../entity.dart';
import 'builders/outputBuilder.dart';
import 'templates/Template.dart';

///
/// [Entity] to represent a Report that is documented in the Project
///
class Report extends Entity implements AcceptOutputBuilders {
  ///
  /// Name of the report
  ///
  String name;

  ///
  /// All attributes values of the report to fill in the form \ document
  ///
  Map<String, dynamic> attributeValues;

  ///
  /// Template version of the report
  ///
  Template template;

  ///
  /// Creator of the report
  ///
  EmployeeForDocs creator;

  ///
  /// Last editor of the report
  ///
  EmployeeForDocs lastEditor;

  Report({
    String id = "",
    this.name,
    Map<String, dynamic> attributeValues,
    this.template,
    this.creator,
    this.lastEditor,
  })  : this.attributeValues = attributeValues ?? Map<String, dynamic>(),
        super(
            id: id, timeCreated: DateTime.now(), timeModified: DateTime.now()) {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    this.timeCreated = date;
  }

  DateTime dateForReport() {
    DateTime now = new DateTime.now();
    return new DateTime(now.year, now.month, now.day);
  }

  @override
  String toString() {
    return name;
  }

  Report.copy(Report other) : super.copy(other) {
    this.name = other.name;
    this.attributeValues =
        other.attributeValues.map((key, value) => MapEntry(key, value)); // copy
    this.template = other.template.clone() as Template;
    this.lastEditor =
        other.lastEditor == null ? null : other.lastEditor.clone();
    this.creator = // if none is listed, update to current editor
        other.creator == null ? this.lastEditor.clone() : other.creator.clone();
  }

  Report.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.REPORT_NAME] as String ?? "";
    this.attributeValues =
        data[Constants.REPORT_ATTR] as Map<String, dynamic> ??
            new Map<String, dynamic>();
    this.template = data[Constants.REPORT_TEMPLATE] as Template ?? null;
    this.lastEditor = data[Constants.REPORT_LAST_EDITOR] == null
        ? null
        : EmployeeForDocs.fromJson(
            data[Constants.REPORT_LAST_EDITOR] as Map<String, dynamic>);
    this.creator = data[Constants.REPORT_CREATOR] == null
        ? this.lastEditor
        : EmployeeForDocs.fromJson(
            data[Constants.REPORT_CREATOR] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.REPORT_NAME: this.name,
      Constants.REPORT_ATTR: this.attributeValues,
      Constants.REPORT_TEMPLATE: this.template,
      Constants.REPORT_LAST_EDITOR:
          this.lastEditor == null ? null : this.lastEditor.toJson(),
      Constants.REPORT_CREATOR: // TODO: test edge case of update twice
          this.creator == null
              ? this.lastEditor.toJson()
              : this.creator.toJson(),
    };
  }

  @override
  Entity clone() {
    return Report.copy(this);
  }

  String getTitle() {
    return "${dateToString(this.timeCreated)} - ${this.creator.name ?? "?"}";
  }

  String getSubtitle() {
    final start = "עריכה אחרונה: ";

    final editor = this.lastEditor != null ? this.lastEditor.name + " " : "";
    final afterEditor = "ב-";

    return start +
        editor +
        afterEditor +
        dateToDateTimeString(this.timeModified);
  }

  @override
  dynamic acceptOutput(
          {Map<String, dynamic> values,
          OutputBuilder builder,
          String suffix = ""}) =>
      builder.generateReport(this);

  @override
  String getStringValue(
      {Map<String, dynamic> values,
      OutputBuilder<dynamic> builder,
      String suffix = ""}) {
    return "";
  }

  @override
  bool validateMustFields() => attributeValues != null && template != null;
}

import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;
import '../utils/datetime_utils.dart';
import 'Employee.dart';
import 'company.dart';
import 'entity.dart';
import 'with_image.dart';

///
/// [Entity] to describe Project in the system
///
class Project extends Entity implements WithImage {
  ///
  /// Name of this [Project]
  ///
  String name;

  ///
  /// The employing [Company] in charge of this [Project]
  ///
  Company employer;

  ///
  /// Id of [Employee] in charge of this [Project]
  ///
  String projectManagerId;

  ///
  /// determines if this project is this [Project] is currently active or not
  ///
  bool isActive;

  ///
  /// List of [Employee] which works in this [Project]
  ///
  Set<String> employees;

  ///
  /// url for the image of this [Project]
  ///
  String imageUrl;

  Project(
      {String id = "",
      this.name,
      this.isActive = true,
      this.employees,
      this.projectManagerId,
      this.imageUrl = "",
      this.employer = Company.IMAG})
      : super(
          id: id,
          timeCreated: DateTime.now(),
          timeModified: DateTime.now(),
        ) {
    if (this.employees == null) {
      this.employees = Set<String>();
    }
  }

  @override
  String toString() {
    return this.name;
  }

  String getTitle() {
    return this.name;
  }

  String getSubTitle() {
    final date = dateToString(this.timeModified);
    final msg = "נערך לאחרונה ב";
    return "$msg $date";
  }

  ///
  /// Copy Costurctor for [Project]
  ///
  Project.copy(Project other) : super.copy(other) {
    this.name = other.name;
    this.isActive = other.isActive;
    this.projectManagerId = other.projectManagerId;
    this.employees = Set<String>();
    other.employees.forEach((element) {
      this.employees.add(element);
    });
    this.imageUrl = other.imageUrl;
    this.employer = other.employer;
  }

  ///
  /// Construct [Project] from given [id] and Json object [data]
  ///
  Project.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.PROJECT_NAME] as String ?? "";
    this.isActive = data[Constants.PROJECT_IS_ACTIVE] as bool ?? false;
    this.projectManagerId = data[Constants.PROJECT_MANAGER_ID] as String ?? "";
    final temp = data[Constants.PROJECT_EMPLOYEES] ?? <String>[];
    this.employees = (temp as List<dynamic>).cast<String>().toSet();
    this.imageUrl = data[Constants.PROJECT_IMAGE_URL] as String ?? "";
    this.employer = data[Constants.PROJECT_EMPLOYER] != null
        ? convertStringToCompany(data[Constants.PROJECT_EMPLOYER] as String)
        : Company.IMAG;
  }

  @override
  Entity clone() {
    return Project.copy(this);
  }

  ///
  /// Converts this [Project] to Json object to upload to database
  ///
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// part of 'toJson'. convert all attributes of this [Project] to Json object.
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.PROJECT_IS_ACTIVE: this.isActive ?? false,
      Constants.PROJECT_NAME: this.name ?? "",
      Constants.PROJECT_MANAGER_ID: this.projectManagerId ?? "",
      Constants.PROJECT_EMPLOYEES: this.employees?.toList() ?? [],
      Constants.PROJECT_IMAGE_URL: this.imageUrl ?? "",
      Constants.PROJECT_EMPLOYER: describeEnum(this.employer ?? Company.IMAG)
    };
  }

  bool isWithImage() => imageUrl != null && imageUrl.isNotEmpty;

  String getUrl() => this.imageUrl;

  String getId() => this.id;

  String getPath() => "project_${this.id}.jpg";

  @override
  bool validateMustFields() =>
      name != null &&
      name.isNotEmpty &&
      projectManagerId != null &&
      projectManagerId.isNotEmpty &&
      isActive != null &&
      employees != null &&
      employees.isNotEmpty &&
      employees.contains(projectManagerId) &&
      employer != null;
}

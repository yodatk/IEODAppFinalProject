import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart' as Constants;
import 'entity.dart';
import 'permission.dart';
import 'with_image.dart';

class Employee extends Entity implements WithImage {
  ///
  /// Email address for login purposes
  ///
  String email;

  ///
  /// Name of the Employee
  ///
  String name;

  ///
  /// Phone number of the employee
  ///
  String phoneNumber;

  ///
  /// Permission enum to determine the action this employee can opr cannot do in the app
  ///
  Permission permission;

  ///
  /// Determines if this employee is can work as a handWorker in [Strip] or not.
  ///
  bool isHandWorker;

  ///
  /// Set of [Project] that this employee took a part of
  ///
  Set<String> projects;

  ///
  /// url to the profile of the employee
  ///
  String imageUrl;

  Employee({
    String id = "",
    @required this.email,
    @required this.name,
    @required this.phoneNumber,
    @required this.permission,
    this.isHandWorker = true,
    this.imageUrl = "",
    this.projects,
  }) : super(id: id) {
    if (this.projects == null) {
      this.projects = Set<String>();
    }
  }

  @override
  String toString() {
    return name;
  }

  bool isWithImage() => imageUrl != null && imageUrl.isNotEmpty;

  String getUrl() => this.imageUrl;

  String getId() => this.id;

  String getPath() => "employee_${this.id}.jpg";

  ///
  /// Copy Constructor for [Employee]
  ///
  Employee.copy(Employee other) : super.copy(other) {
    this.email = other.email;
    this.name = other.name;
    this.phoneNumber = other.phoneNumber;
    this.permission = other.permission;
    this.isHandWorker = other.isHandWorker;
    this.imageUrl = other.imageUrl;
    this.projects = Set<String>();
    other.projects.forEach((element) {
      this.projects.add(element);
    });
  }

  ///
  /// Create a [Employee] object from [id] and json object [data]
  ///
  Employee.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.EMPLOYEE_NAME] as String ?? "";
    this.email = data[Constants.EMPLOYEE_EMAIL] as String ?? "";
    this.phoneNumber = data[Constants.EMPLOYEE_PHONE_NUMBER] as String ?? "";
    this.permission = convertStringToPermission(
        data[Constants.EMPLOYEE_PERMISSION] as String);
    this.isHandWorker = data[Constants.EMPLOYEE_IS_HAND_WORKER] as bool ?? true;
    this.imageUrl = data[Constants.EMPLOYEE_IMAGE_URL] as String ?? "";
    final temp = data[Constants.EMPLOYEE_PROJECTS] ?? <String>[];
    this.projects = (temp as List<dynamic>).cast<String>().toSet();
  }

  ///
  /// Converts this [Employee] to Json object to upload to database
  ///
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// Part of 'toJson' function. convert [Employee] attributes to Json Object
  ///
  Map<String, dynamic> toMap() {
    return {
      Constants.EMPLOYEE_NAME: this.name,
      Constants.EMPLOYEE_PHONE_NUMBER: this.phoneNumber,
      Constants.EMPLOYEE_EMAIL: this.email,
      Constants.EMPLOYEE_PERMISSION:
          describeEnum(this.permission ?? Permission.REGULAR),
      Constants.EMPLOYEE_IS_HAND_WORKER: this.isHandWorker,
      Constants.EMPLOYEE_IMAGE_URL: this.imageUrl,
      Constants.EMPLOYEE_PROJECTS: this.projects?.toList() ?? [],
    };
  }

  @override
  Entity clone() {
    return Employee.copy(this);
  }

  /// Get secondary [String] data on this user to be displayed as a list item
  String getSubs() {
    if (this.name == "") {
      return "";
    }

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formatted = formatter.format(this.timeModified);
    final updatedInfo = "עודכן לאחרונה ב$formatted";
    return updatedInfo;
  }

  bool validateMustFields() {
    return this.email != null &&
        this.email.isNotEmpty &&
        this.name != null &&
        this.name.isNotEmpty &&
        this.permission != null &&
        isHandWorker != null &&
        this.projects != null;
  }

  ///
  /// Checking if the given user has a permission level of at least the given [needed] permission
  ///
  bool isPermissionOk(Permission needed) {
    if (needed == null) {
      needed = Permission.ADMIN;
    }
    if (this.permission == null) {
      return false;
    }
    if (this.permission == Permission.ADMIN) {
      return true;
    }
    if (this.permission == Permission.MANAGER && needed == Permission.ADMIN) {
      return false;
    }
    if (this.permission == Permission.REGULAR && this.permission != needed) {
      return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.isHandWorker == this.isHandWorker &&
          other.phoneNumber == this.phoneNumber &&
          other.permission == this.permission;

  @override
  int get hashCode => this.id.hashCode;
}

///
/// Class to be saved in docs, and other entities which need to save minimal employee data even if it changes
///
class EmployeeForDocs {
  ///
  /// Name of the employee
  ///
  String name;

  ///
  /// ID of the employee
  ///
  String id;

  EmployeeForDocs(this.name, this.id);

  ///
  /// Constructs a [EmployeeForDocs] object from json object [data]
  ///
  EmployeeForDocs.fromJson(Map<String, dynamic> data) {
    this.id = data[Constants.ENTITY_ID] as String ?? "";
    this.name = data[Constants.EMPLOYEE_NAME] as String ?? "";
  }

  ///
  /// Converts this [EmployeeForDocs] object to json object
  ///
  Map<String, String> toJson() {
    return {
      Constants.ENTITY_ID: id,
      Constants.EMPLOYEE_NAME: name,
    };
  }

  ///
  /// Copy constructor for [EmployeeForDocs]
  ///
  EmployeeForDocs.copy(EmployeeForDocs other) {
    this.id = other.id;
    this.name = other.name;
  }

  EmployeeForDocs clone() {
    return EmployeeForDocs.copy(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeForDocs &&
          other.id == this.id &&
          other.name == this.name;

  @override
  int get hashCode => this.id.hashCode;
}

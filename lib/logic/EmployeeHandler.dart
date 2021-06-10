import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;
import '../models/Employee.dart';
import '../models/edit_image_case.dart';
import '../models/permission.dart';
import '../services/DAO/FireStoreDAO/firestore_employee_dao.dart';
import '../services/DAO/interfacesDAO/employee_dao.dart';
import '../services/services_interfaces/auth_service.dart';
import '../services/services_interfaces/storage_service.dart';
import 'ProjectHandler.dart';
import 'entity_updater.dart';
import 'handler.dart';
import 'result.dart';

///
/// Class to handle all [Employee] data manipulation and logic procedures
///
class EmployeeHandler extends Handler with EntityUpdater {
  ///
  /// Singleton instance for the [EmployeeHandler]
  ///
  static final EmployeeHandler _instance = EmployeeHandler._internal();

  ///
  /// DAO for [Employee] entities
  ///
  EmployeeDAO _employeeDAO;

  ///
  /// Auth Provider for [Employee]s of the app
  ///
  AuthService _authProvider;

  ///
  /// for Uploading images of workers
  ///
  StorageService _storageService;

  ///
  /// StateNotifier of currentLogged In Employee
  ///
  CurrentEmployeeController _currentEmployeeController;

  ///
  /// Public getter for [EmployeeHandler] Instance
  ///
  factory EmployeeHandler() {
    return _instance;
  }

  @override
  void initWithFirebase() {
    _employeeDAO = FireStoreEmployeeDAO();
  }

  ///
  /// Private constructor of [EmployeeHandler]
  ///
  EmployeeHandler._internal() {
    init();
  }

  ///
  /// Initializing services of the employee handler: [storageService] and [authService].
  /// also initializing the [_currentEmployeeController]
  ///
  void initEmployeeHandler(
      AuthService authService, StorageService storageService) {
    _authProvider = authService;
    _storageService = storageService;
    _currentEmployeeController = CurrentEmployeeController();
  }

  ///
  /// Sending a reset password link to the [Employee] with the given [email]
  ///
  Future<String> sendResetPasswordLinkToEmail(String email) async {
    return await this._authProvider.sendResetPasswordLinkToEmail(email);
  }

  ///
  /// Get the current logged in [Employee] if non is logged in, will return null
  ///
  Employee readCurrentEmployee() {
    return _currentEmployeeController.readEmployee();
  }

  ///
  /// Switch the current loggedIn employee
  ///
  Future<Employee> resetCurrentEmployee({bool isWaiting = false}) async {
    await this._currentEmployeeController.cancel();
    return await this._currentEmployeeController.reset(isWaiting: isWaiting);
  }

  ///
  /// Get a specific Employee by Email
  ///
  Future<Employee> getEmployeeWithGivenEmail(String email) async {
    if (email == null || email.isEmpty) {
      // no employee has an empty or null email
      return null;
    }
    final all = await this._employeeDAO.allItemsAsListWithEqualsGivenField(
        projectId: null, field: Constants.EMPLOYEE_EMAIL, predicate: email);
    return (all == null || all.isEmpty) ? null : all.first;
  }

  ///
  /// get all [Employee] with the [employeeName]
  ///
  Future<List<Employee>> getAllEmployeesWithSameName(String employeeName) {
    return _employeeDAO.allItemsAsListWithEqualsGivenField(
        field: Constants.EMPLOYEE_NAME,
        predicate: employeeName,
        projectId: null);
  }

  /// Returns stream of snapshots of all the [Employee] in the system
  Stream<List<Employee>> getAllEmployeesAsStream() {
    return _employeeDAO.allItemsAsStream(projectId: null);
  }

  /// Returns stream of all the [Employee] in the system that are in the current [Project]
  Stream<List<Employee>> getAllEmployeesFromCurrentProject() {
    final currentProject = ProjectHandler().readCurrentProject();
    return this._employeeDAO.allItemsAsStreamWithArrayContainsClause(
        projectId: null,
        arrayField: Constants.EMPLOYEE_PROJECTS,
        value: currentProject.id);
  }

  /// Returns stream of all the [Employee] in the system that are in the current [Project]
  Future<List<Employee>> getAllEmployeesFromCurrentProjectAsFuture() async {
    final currentProject = ProjectHandler().readCurrentProject();
    return await this._employeeDAO.allItemsAsListWithArrayContainsClause(
        projectId: null,
        arrayField: Constants.EMPLOYEE_PROJECTS,
        value: currentProject.id);
  }

  /// Returns list of all the [Employee] in the system that are in the current [Project]
  Future<List<Employee>> getAllManagersFromCurrentProject() async {
    final currentProject = ProjectHandler().readCurrentProject();
    return await this
        ._employeeDAO
        .allItemsAsListWithArrayContainsClauseAndIsEqual(
            projectId: null,
            arrayField: Constants.EMPLOYEE_PROJECTS,
            value: currentProject.id,
            isEqualFields: {
          Constants.EMPLOYEE_PERMISSION: describeEnum(Permission.MANAGER),
        });
  }

  ///
  /// Trying to upload the given [image] of the [employee] to the storage service
  ///
  Future<void> tryUploadImage(File image, Employee employee) async {
    if (employee.id == null || employee.id.isEmpty) {
      employee.id = _employeeDAO.preGenerateId(projectId: null);
    }

    final imageUrl =
        await this._storageService.uploadFile(employee.getPath(), image);
    employee.imageUrl = imageUrl;
  }

  ///
  /// Edit the given [Employee] with the new [newEmployeeDetails]
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> editEmployee(
      Employee newEmployeeDetails,
      Map<String, dynamic> changes,
      File image,
      EditImageCase currentCase) async {
    if (newEmployeeDetails == null ||
        !newEmployeeDetails.validateMustFields()) {
      return "חלק מהשדות אינם תקינים";
    }

    if (currentCase == EditImageCase.NEW_IMAGE) {
      try {
        await tryUploadImage(image, newEmployeeDetails);
        changes[Constants.EMPLOYEE_IMAGE_URL] = newEmployeeDetails.imageUrl;
      } catch (ignored, stack) {
        Logger.error(
            "editEmployee: tried to upload image but couldn't succeed because of this error:");
        Logger.error(ignored.toString());
        Logger.error(stack.toString());
      }
    } else if (currentCase == EditImageCase.DELETE_IMAGE) {
      try {
        await this._storageService.deleteFile(newEmployeeDetails.getPath());
      } finally {
        newEmployeeDetails.imageUrl = "";
        changes[Constants.EMPLOYEE_IMAGE_URL] = "";
      }
    }

    updateEntityModifiedTime(newEmployeeDetails);
    changes[Constants.ENTITY_MODIFIED] =
        newEmployeeDetails.timeModified.millisecondsSinceEpoch;
    return _employeeDAO.update(
      toUpdate: newEmployeeDetails,
      currentProjectId: null,
      data: changes,
    );
  }

  ///
  /// Delete the given [Employee]
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> deleteEmployee(Employee toDelete) async {
    if (toDelete == null) {
      return "אראה שגיאה";
    }
    final current = readCurrentEmployee();
    if (current.id == toDelete.id) {
      return "לא ניתן למחוק את עצמך!";
    }
    if (toDelete.isWithImage()) {
      await this._storageService.deleteFile(toDelete.getPath());
    }

    return this._employeeDAO.deleteEmployee(toDelete: toDelete);
  }

  ///
  /// for testing purpuses. delete all [Employee] With the given Emails
  ///
  Future<String> deleteEmployeesFromEmails(List<String> emailsToDelete) {
    return this
        ._employeeDAO
        .deleteEmployeesByEmails(emailsToDelete: emailsToDelete);
  }

  ///
  /// Register new Employee [Employee] with the new [uidToDelete]
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> register(Employee newEmployeeDetails, String password,
      File image, EditImageCase imgCase) async {
    if (newEmployeeDetails == null ||
        !newEmployeeDetails.validateMustFields() ||
        password == null) {
      return "חלק מהשדות אינם תקינים";
    }
    Result<String> authRegisterResult = await this
        ._authProvider
        .registerEmployee(newEmployeeDetails.email, password);
    if (authRegisterResult.isSuccessful) {
      final now = DateTime.now();
      newEmployeeDetails.id = authRegisterResult.result;
      newEmployeeDetails.timeCreated = now;
      newEmployeeDetails.timeModified = now;
      if (imgCase == EditImageCase.NEW_IMAGE) {
        try {
          await tryUploadImage(image, newEmployeeDetails);
        } catch (ignored, stack) {
          Logger.error(
              "editEmployee: tried to upload image but couldn't succeed because of this error:");
          Logger.error(ignored.toString());
          Logger.error(stack.toString());
        }
      }
      String msg = await this._employeeDAO.registerEmployee(
            newEmployee: newEmployeeDetails,
            toAddTo: null,
          );
      return msg;
    } else {
      return authRegisterResult.msg;
    }
  }

  ///
  /// Logging in an [Employee] with the given [email] and [password]
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> login(
      {@required String email, @required String password}) async {
    Result<String> loginAuthResult = await this
        ._authProvider
        .loginEmployee(email: email, password: password);
    if (loginAuthResult.isSuccessful) {
      Result<Employee> result = await this
          ._employeeDAO
          .checkValidityOfLogin(loginAuthResult.result, email);
      if (!result.isSuccessful) {
        await this.logout();
      }
      await this._currentEmployeeController.setEmployee(result.result);
      return result.msg;
    } else {
      return loginAuthResult.msg;
    }
  }

  ///
  /// Logging out the current user from the device
  ///
  Future<String> logout() async {
    await ProjectHandler().cancelProjectSubscription();
    await this._currentEmployeeController.cancel();
    await this._currentEmployeeController.setEmployee(null);

    final msg = await this._authProvider.logout();
    await _currentEmployeeController.reset();
    return msg;
  }

  ///
  /// if Employee is connected, return it's id, otherwise return null
  ///
  Stream<String> isConnected() {
    return this._authProvider.isConnected();
  }

  Stream<Employee> getCurrentLoggedInEmployee() {
    return this.isConnected().flatMap((String uid) {
      if (uid == null) {
        Logger.info("currently no Employee is logged in");
        return Stream<Employee>.value(null);
      } else {
        return _employeeDAO.getCurrentEmployeeStream(uid);
      }
    });
  }

  ///
  /// Get all [Employee] that are also hand workers, and works in the current project
  ///
  Future<List<Employee>> getAllHandWorkEmployees() {
    final currentProject = ProjectHandler().readCurrentProject();
    return currentProject != null
        ? this._employeeDAO.allItemsAsListWithArrayContainsClauseAndIsEqual(
            projectId: null,
            arrayField: Constants.EMPLOYEE_PROJECTS,
            value: currentProject.id,
            isEqualFields: {
                Constants.EMPLOYEE_IS_HAND_WORKER: true,
              })
        : this._employeeDAO.allItemsAsListWithEqualsGivenField(
            projectId: null,
            field: Constants.EMPLOYEE_IS_HAND_WORKER,
            predicate: true);
  }

  ///
  /// Get all [Employee] that are also hand workers, and works in the current project
  ///
  Stream<List<Employee>> getAllAdmins() {
    return this._employeeDAO.allItemsFilteredByFieldsAsStream(
      projectId: null,
      fields: {Constants.EMPLOYEE_PERMISSION: describeEnum(Permission.ADMIN)},
    );
  }

  ///
  /// Get all [Employee] that are admins, and works in the current project
  ///
  Future<List<Employee>> getAllAdminsFromCurrentProject() async {
    final currentProject = ProjectHandler().readCurrentProject();
    return await this
        ._employeeDAO
        .allItemsAsListWithArrayContainsClauseAndIsEqual(
            projectId: null,
            arrayField: Constants.EMPLOYEE_PROJECTS,
            value: currentProject.id,
            isEqualFields: {
          Constants.EMPLOYEE_PERMISSION: describeEnum(Permission.ADMIN),
        });
  }

  ///
  /// loading all [Employee] that are required for the given project
  ///
  Future<void> preLoadDataForProject(String projectId) async {
    await _employeeDAO.allItemsAsList(projectId: null);
  }

  @override
  Future<String> resetForTests({String projectId}) async => "";
}

///
/// Provider of current [Employee] stateNotifier
///
final currentEmployeeProvider =
    StateNotifierProvider<CurrentEmployeeController>(
        (ref) => EmployeeHandler()._currentEmployeeController);

///
/// Current logged in [Employee] notifier
///
class CurrentEmployeeController extends StateNotifier<Employee> {
  StreamSubscription<Employee> _isConnectedChanges;

  CurrentEmployeeController() : super(null) {
    _isConnectedChanges?.cancel();
    reset();
  }

  Employee readEmployee() => state;

  Future<void> setEmployee(Employee newState) async {
    this.state = newState;
  }

  Future<Employee> reset({bool isWaiting = false}) async {
    final stream = EmployeeHandler().getCurrentLoggedInEmployee();
    _isConnectedChanges = stream.listen((user) {
      state = user;
    }, onError: (error, stack) {
      if (error.toString().contains("permission-denied")) {
      } else {
        Logger.warning("Unexpected Error:\n ${error.toString()}");
      }
      state = null;
    });
    if (isWaiting) {
      return await stream.firstWhere((element) => element != null);
    } else {
      return await stream.first;
    }
  }

  Future<void> cancel() async => await _isConnectedChanges?.cancel();

  @override
  void dispose() {
    _isConnectedChanges?.cancel();
    super.dispose();
  }
}

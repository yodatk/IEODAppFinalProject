import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;
import '../models/Employee.dart';
import '../models/company.dart';
import '../models/edit_image_case.dart';
import '../models/project.dart';
import '../models/site.dart';
import '../services/DAO/FireStoreDAO/firestore_project_dao.dart';
import '../services/DAO/interfacesDAO/project_dao.dart';
import '../services/services_interfaces/storage_service.dart';
import 'EmployeeHandler.dart';
import 'dailyInfoHandler.dart';
import 'entity_updater.dart';
import 'fieldHandler.dart';
import 'handler.dart';
import 'reportHandler.dart';
import 'stateNotifiers/entityNotifier.dart';

///
/// Class to handle all the [Project] and [Site] data manipulation and logic procedures
///
class ProjectHandler extends Handler with EntityUpdater {
  ///
  /// Singleton instance
  ///
  static final ProjectHandler _instance = ProjectHandler._internal();

  ///
  /// DAO for [Project]
  ///
  ProjectDAO _projectDAO;

  ///
  /// state controller for current chosen [Project]
  ///
  EntityController<Project> _currentProjectController;

  ///
  /// Storage service to upload images of project
  ///
  StorageService _storageService;

  ///
  /// Getter of the singleton Instance
  ///
  factory ProjectHandler() {
    return _instance;
  }

  @override
  void initWithFirebase() {
    _projectDAO = FireStoreProjectDAO();
  }

  ///
  /// Private constructor for [ProjectHandler]
  ///
  ProjectHandler._internal() {
    init();
  }

  ///
  /// initillize this [ProjectHandler]
  ///
  Future<void> initProjectHandler(StorageService storageService) async {
    _storageService = storageService;
    _currentProjectController = EntityController<Project>(
        id: null, streamFunction: ProjectHandler().getCurrentProjectById);
  }

  ///
  /// reset [_currentProjectController] to a [Project] with the given [projectId].
  /// if the given [projectId] is null, will reset the current Project to null
  ///
  Future<void> resetCurrentProject(String projectId) async {
    await this.storeProjectIdInCache(projectId);
    await _currentProjectController?.reset(projectId);
  }

  ///
  /// Get Current Project
  ///
  Project readCurrentProject() {
    return _currentProjectController?.read();
  }

  ///
  /// Getter for the Id of the current [Project]
  ///
  String getCurrentProjectId() => _currentProjectController?.getId();

  ///
  /// Getter for the Id of the current [Project]
  ///
  String getCurrentProjectName() => _currentProjectController?.read()?.name;

  ///
  /// Getter for the Id of the current [Project]
  ///
  Company getCurrentProjectEmployer() =>
      _currentProjectController?.read()?.employer;

  ///
  /// Get all [Project] that are in the database
  ///
  Stream<List<Project>> getAllProjects() {
    return _projectDAO.allItemsAsStream(projectId: null);
  }

  ///
  /// Get all active [Project] that are in the database
  ///
  Stream<List<Project>> getAllActiveProjects() {
    return _projectDAO
        .allItemsFilteredByFieldsAsStream(projectId: null, fields: {
      Constants.PROJECT_IS_ACTIVE: true,
    });
  }

  ///
  /// Get all active [Project] that  the current logged in employee is a part of
  ///
  Stream<List<Project>> getAllActiveProjectsOfCurrentUser(
      String currentEmployeeId) {
    //final currentEmployeeId = EmployeeHandler().readCurrentEmployee().id;
    return currentEmployeeId != null
        ? this.getAllActiveProjects().map((projects) => projects
            .where((p) => p.employees.contains(currentEmployeeId))
            .toList())
        : Stream.value(<Project>[]);
  }

  ///
  /// Get [Stream] of [Project] with the given [projectId]
  ///
  Stream<Project> getCurrentProjectById(String projectId) {
    return _projectDAO.getByIdAsStream(currentProject: null, id: projectId);
  }

  ///
  /// Get [Stream] of [Project] with the given [projectId]
  ///
  Future<Project> getCurrentProjectByIdFuture(String projectId) {
    try {
      return _projectDAO.getById(currentProject: null, id: projectId);
    } catch (error) {
      Logger.error(error.toString());
      return null;
    }
  }

  ///
  /// Delete [Project] from the database with the given [projectToDelete]
  ///
  Future<String> deleteProject(Project projectToDelete) async {
    if (projectToDelete == null) {
      Logger.error('given project to delete cannot be null');
      return "אראה שגיאה";
    }
    // delete image
    try {
      if (projectToDelete.isWithImage()) {
        await this._storageService.deleteFile(projectToDelete.getPath());
      }
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        Logger.error(
            'User does not have permission to delete to this reference.');
      }
    } catch (error) {
      Logger.error("something went wrong in 'deleteProject' : couldnt delete");
      Logger.error(error.toString());
    }

    // delete project
    try {
      final msg = await _projectDAO.deleteProject(projectToDelete);
      return msg;
    } catch (error) {
      Logger.error("something went wrong in 'deleteProject'");
      Logger.error(error.toString());
      return Constants.GENERAL_ERROR_MSG;
    }
  }

  ///
  /// Adding project to database. if project includes a theme image, upload it to storage
  ///
  Future<String> addProject(
      Project newProject, File image, EditImageCase currentCase) async {
    if (newProject == null) {
      Logger.error('given project to add cannot be null');
      return "אראה שגיאה";
    }
    try {
      newProject.id = _projectDAO.generateProjectId();
      if (currentCase == EditImageCase.NEW_IMAGE) {
        await tryUploadImage(image, newProject);
      }
      updateEntityModifiedTime(newProject);

      final msg = await _projectDAO.addProject(newProject);
      return msg;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        Logger.error(
            'User does not have permission to upload to this reference.');
      }
      return Constants.GENERAL_ERROR_MSG;
    } catch (error) {
      Logger.error("something went wrong in 'uploadImageToFolder'");
      Logger.error(error.toString());
      return Constants.GENERAL_ERROR_MSG;
    }
  }

  ///
  /// Trying to upload the given [image] of the [newProject] to the storage service
  ///
  Future<void> tryUploadImage(File image, Project newProject) async {
    if (newProject.id == null || newProject.id.isEmpty) {
      newProject.id = _projectDAO.preGenerateId(projectId: null);
    }

    final imageUrl =
        await this._storageService.uploadFile(newProject.getPath(), image);
    newProject.imageUrl = imageUrl;
  }

  ///
  /// loading last project id from cache
  ///
  Future<String> loadLastProjectIdFromCache() async {
    await Hive.openBox(Constants.HIVE_PROJECT_ID_KEY);
    final String output = Hive.box(Constants.HIVE_PROJECT_ID_KEY)
        .get(Constants.HIVE_PROJECT_ID_KEY) as String;
    await Hive.box(Constants.HIVE_PROJECT_ID_KEY).close();
    return output;
  }

  ///
  /// storing given ProjectID in cache for next opening of the app
  ///
  Future<void> storeProjectIdInCache(String projectId) async {
    await Hive.openBox(Constants.HIVE_PROJECT_ID_KEY);
    await Hive.box(Constants.HIVE_PROJECT_ID_KEY)
        .put(Constants.HIVE_PROJECT_ID_KEY, projectId);
    await Hive.box(Constants.HIVE_PROJECT_ID_KEY).close();
  }

  ///
  /// loading the last project into [_currentProjectController]
  ///
  Future<String> loadLastProjectToController() async {
    final projectID = await loadLastProjectIdFromCache();
    if (projectID != null) {
      await this._currentProjectController.reset(projectID);
    }
    return projectID;
  }

  ///
  /// update changes of given [updatedProject] to the data base, and to the storage service if necessary
  ///
  Future<String> editProject({
    @required Project updatedProject,
    @required File image,
    @required EditImageCase currentCase,
    @required List<String> employeesToAdd,
    @required List<String> employeesToRemove,
  }) async {
    if (updatedProject == null) {
      Logger.error('given project to edit cannot be null');
      return "אראה שגיאה";
    }
    if (!updatedProject.validateMustFields()) {
      Logger.error(
          "invalid fields in project: \n${updatedProject.toJson().toString()}");
      return "שדות לא חוקיים בפרויקט";
    }
    try {
      if (currentCase == EditImageCase.NEW_IMAGE) {
        await tryUploadImage(image, updatedProject);
      } else if (currentCase == EditImageCase.DELETE_IMAGE) {
        // delete from firebase storage
        await this._storageService.deleteFile(updatedProject.getPath());

        updatedProject.imageUrl = "";
      }
      this.updateEntityModifiedTime(updatedProject);
      final msg = await _projectDAO.editProject(
          toEdit: updatedProject,
          employeesToRemove: employeesToRemove,
          employeesToAdd: employeesToAdd);
      return msg;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        Logger.error(
            'User does not have permission to upload to this reference.');
      }
      return Constants.GENERAL_ERROR_MSG;
    } catch (error) {
      Logger.error("something went wrong in 'editProject'");
      Logger.error(error.toString());
      return Constants.GENERAL_ERROR_MSG;
    }
  }

  ///
  /// Cancel subscription of this [CurrentProjectController] stream.
  ///
  Future<void> cancelProjectSubscription() async {
    await this.storeProjectIdInCache(null);
    if (readCurrentProject() != null) {
      await this._currentProjectController.cancel();
      await this._currentProjectController.set(null);
    }
  }

  ///
  /// Replace the [Project] streaming from the [CurrentProjectController] with the one with the given [projectId]
  ///
  Future<void> chooseProject(String projectId) async {
    if (projectId == "") {
      projectId = null;
    }
    if (readCurrentProject() != null) {
      await this.cancelProjectSubscription();
    }
    await this._currentProjectController.reset(projectId);
  }

  ///
  /// loading a project from cache to state
  ///
  Future<void> loadProjectToState() async {
    final projectId = await loadLastProjectIdFromCache();
    await this._currentProjectController.cancel();
    await this._currentProjectController.reset(projectId);
  }

  ///
  /// Pre-Loads all data of the currentProject
  ///
  Future<void> preLoadDataOfProject() async {
    if (readCurrentProject() != null) {
      await EmployeeHandler().preLoadDataForProject(readCurrentProject().id);
      await DailyInfoHandler().preLoadDataForProject(readCurrentProject().id);
      await ReportHandler().preLoadDataForProject(readCurrentProject().id);
      await FieldHandler().preLoadDataForProject(readCurrentProject().id);
    }
  }

  @override
  Future<String> resetForTests({String projectId}) async => "";

  ///
  /// checks that the given [projectToCheck] is active, and that the [currentEmployee] is a part of it
  ///
  bool projectIsValid(Project projectToCheck, Employee currentEmployee) {
    return projectToCheck != null &&
        currentEmployee != null &&
        projectToCheck.isActive &&
        projectToCheck.employees.contains(currentEmployee.id);
  }
}

///
/// Provider of the current Project
///
final currentProjectProvider = StateNotifierProvider<EntityController<Project>>(
    (ref) => ProjectHandler()._currentProjectController);

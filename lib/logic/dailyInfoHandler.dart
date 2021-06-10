import 'dart:io';

import 'package:IEODApp/logic/handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;
import '../logic/ProjectHandler.dart';
import '../models/all_models.dart';
import '../models/arrangement_type.dart';
import '../models/drive_arrangement.dart';
import '../models/work_arrangement.dart';
import '../services/DAO/FireStoreDAO/firestore_drive_arrangement_dao.dart';
import '../services/DAO/FireStoreDAO/firestore_image_folder_dao.dart';
import '../services/DAO/FireStoreDAO/firestore_work_arrangement_dao.dart';
import '../services/DAO/interfacesDAO/drive_arrangement_dao.dart';
import '../services/DAO/interfacesDAO/image_folder_dao.dart';
import '../services/DAO/interfacesDAO/work_arrangement_dao.dart';
import '../services/services_interfaces/storage_service.dart';
import 'entity_updater.dart';

///
/// Class to handle Daily information manipulation:
///   a. [WorkArrangement]
///   b. [DriveArrangement]
///   c. [ImageFolder]
///
class DailyInfoHandler extends Handler with EntityUpdater {
  ///
  /// singleton instance of the DailyInfoHandler
  ///
  static final DailyInfoHandler _instance = DailyInfoHandler._internal();

  ///
  /// DAO for [WorkArrangement] entities
  ///
  WorkArrangementDAO _workArrangementDAO;

  ///
  /// DAO for [DriveArrangement] entities
  ///
  DriveArrangementDAO _driveArrangementDAO;

  ///
  /// DAO for [ImageFolder] entities
  ///
  ImageFolderDAO _imageFolderDAO;

  ///
  /// Storage service to upload and download images and files
  ///
  StorageService _storageService;

  ///
  ///  Public getter for the instance
  ///
  factory DailyInfoHandler() => _instance;

  @override
  void initWithFirebase() {
    _workArrangementDAO = FireStoreWorkArrangementDAO();
    _driveArrangementDAO = FireStoreDriveArrangementDAO();
    _imageFolderDAO = FireStoreImageFolderDAO();
  }

  ///
  /// Private constructor
  ///
  DailyInfoHandler._internal() {
    init();
  }

  ///
  /// Initializing [DailyInfoHandler] with the given [storageService]
  ///
  initDailyInfoHandler(StorageService storageService) {
    this._storageService = storageService;
  }

// =========================== Arrangement ============================================================================================================

  ///
  /// Deleting [Arrangement] with [arrangementId] from database
  ///
  Future<String> deleteArrangement(
      String arrangementId, ArrangementType arrangmentType) async {
    if (arrangmentType == ArrangementType.WORK)
      return deleteWorkArrangement(arrangementId);
    return deleteDriveArrangement(arrangementId);
  }

  ///
  /// Add or edit a given [Arrangement]
  ///
  Future<String> addOrOverrideArrangement(Arrangement arrangement) async {
    if (arrangement is WorkArrangement)
      return addOrOverrideWorkArrangement(arrangement);
    else
      return addOrOverrideDriveArrangement(arrangement as DriveArrangement);
  }

  ///
  /// retrieve a stream of all [Arrangement] from a certain project with the given [projectId].
  ///
  Stream<List<Arrangement>> allArrangementsFromProject(
      String projectId, ArrangementType arrangmentType) {
    if (arrangmentType == ArrangementType.WORK)
      return allWorkArrangementsFromProject(projectId);
    return allDriveArrangementsFromProject(projectId);
  }

  ///
  /// Retrieve list of [Arrangement] from the project with the given [projectId]
  ///
  Future<List<Arrangement>> allArrangementsFromProjectAsItems(
      String projectId, ArrangementType arrangementType) {
    if (arrangementType == ArrangementType.WORK) {
      return allWorkArrangementsFromProjectAsItems(projectId);
    }
    return allDriveArrangementsFromProjectAsItems(projectId);
  }

// =========================== Work Arrangement ============================================================================================================
  ///
  /// Adds the given work [arrangement] to the database.
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> addOrOverrideWorkArrangement(
      WorkArrangement arrangement) async {
    if (arrangement == null || !arrangement.validateMustFields()) {
      return "שדות לא תקינים";
    }
    await updateEditorAndModifiedTime(arrangement);
    return await _workArrangementDAO.updateWithOverride(
        toUpdate: arrangement,
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Deletes the [WorkArrangement] with the given [arrangementId] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> deleteWorkArrangement(String arrangementId) async {
    if (arrangementId == null || arrangementId.isEmpty) {
      Logger.error("deleteWorkArrangement: invalid id");
      return "אראה שגיאה";
    }
    return await _workArrangementDAO.deleteWithId(
        toDeleteId: arrangementId,
        currentProject: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// retrieve a stream of all [WorkArrangement] from a certain project with the given [projectId].
  ///
  Stream<List<WorkArrangement>> allWorkArrangementsFromProject(
      String projectId) {
    return _workArrangementDAO.allItemsAsStream(projectId: projectId);
  }

  ///
  /// Retrieve list of [WorkArrangement] from the project with the given [projectId]
  ///
  Future<List<WorkArrangement>> allWorkArrangementsFromProjectAsItems(
      String projectId) {
    return _workArrangementDAO.allItemsAsList(projectId: projectId);
  }

  ///
  /// Get desired [WorkArrangement] according to given date from current [Project]
  ///
  Future<WorkArrangement> getWorkArrangementByDate(DateTime date) async {
    List<WorkArrangement> result =
        await this._workArrangementDAO.allItemsAsListWithEqualsGivenField(
              projectId: ProjectHandler().getCurrentProjectId(),
              field: Constants.WA_DATE,
              predicate: date.millisecondsSinceEpoch,
            );
    if (result == null || result.isEmpty) {
      return null;
    } else {
      return result.first;
    }
  }

  ///
  /// Get desired [WorkArrangement] according to given id from current [Project]
  ///
  Future<WorkArrangement> getWorkArrangementByID(String id) async {
    if (id == null || id.isEmpty) {
      return null;
    }
    WorkArrangement result = await this._workArrangementDAO.getById(
        currentProject: ProjectHandler().getCurrentProjectId(), id: id);
    return result;
  }

// =========================== Drive Arrangement ============================================================================================================

  ///
  /// Retrieve list of [DriveArrangement] from the project with the given [projectId]
  ///
  Future<List<DriveArrangement>> allDriveArrangementsFromProjectAsItems(
      String projectId) {
    return _driveArrangementDAO.allItemsAsList(projectId: projectId);
  }

  ///
  /// Retrieve list of [DriveArrangement] as stream from the project with the given [projectId]
  ///
  Stream<List<DriveArrangement>> allDriveArrangementsFromProject(
      String projectId) {
    return _driveArrangementDAO.allItemsAsStream(projectId: projectId);
  }

  ///
  /// Creates or overrides the given drive [arrangement] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> addOrOverrideDriveArrangement(
      DriveArrangement arrangement) async {
    if (arrangement == null || !arrangement.validateMustFields()) {
      return "שדות לא תקינים";
    }
    await updateEditorAndModifiedTime(arrangement);
    return await _driveArrangementDAO.updateWithOverride(
        toUpdate: arrangement,
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Deletes the [DriveArrangement] with the given [arrangementId] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> deleteDriveArrangement(String arrangementId) async {
    if (arrangementId == null || arrangementId.isEmpty) {
      Logger.error("deleteDriveArrangement: invalid id");
      return "אראה שגיאה";
    }
    return await _driveArrangementDAO.deleteWithId(
        toDeleteId: arrangementId,
        currentProject: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Get desired [DriveArrangement] according to given date from current [Project]
  ///
  Future<DriveArrangement> getDriveArrangementByDate(DateTime date) async {
    List<DriveArrangement> result =
        await this._driveArrangementDAO.allItemsAsListWithEqualsGivenField(
              projectId: ProjectHandler().getCurrentProjectId(),
              field: Constants.DA_DATE,
              predicate: date.millisecondsSinceEpoch,
            );
    if (result == null || result.isEmpty) {
      return null;
    } else {
      return result.first;
    }
  }

  ///
  /// Get desired [DriveArrangement] according to given id from current [Project]
  ///
  Future<DriveArrangement> getDriveArrangementByID(String id) async {
    if (id == null || id.isEmpty) {
      return null;
    }
    DriveArrangement result = await this._driveArrangementDAO.getById(
        currentProject: ProjectHandler().getCurrentProjectId(), id: id);
    return result;
  }

// =========================== Map Folder ============================================================================================================

  ///
  /// Retrieve list of [ImageFolder] from the project with the given [projectId]
  ///
  Future<List<ImageFolder>> allMapFoldersFromProjectAsItems(String projectId) {
    return _imageFolderDAO.allItemsAsList(projectId: projectId);
  }

  ///
  /// Retrieve list of [ImageFolder] as stream from the project with the given [projectId]
  ///
  Stream<List<ImageFolder>> allMapFoldersFromProject(String projectId) {
    return _imageFolderDAO.allItemsAsStream(projectId: projectId);
  }

  ///
  /// Creates or overrides the given [mapFolder] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> addOrOverrideMapFolder(ImageFolder mapFolder) async {
    if (mapFolder == null || !mapFolder.validateMustFields()) {
      return "שדות לא תקינים";
    }
    return await _imageFolderDAO.updateWithOverride(
        toUpdate: mapFolder,
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Updates the given [mapFolder] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> updateFolderName(ImageFolder mapFolder) async {
    if (mapFolder == null) {
      Logger.error("updateFolderName: mapFolder was null");
      return "ארעה שגיאה";
    }
    if (!mapFolder.validateMustFields()) {
      Logger.error("updateFolderName: map folder has invalid fields");
      return "ארעה שגיאה";
    }
    return await _imageFolderDAO.update(
        toUpdate: mapFolder,
        data: {
          Constants.MAP_FOLDER_DATE: mapFolder.date.millisecondsSinceEpoch
        },
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Deletes the [ImageFolder] with the given [folder] in the database
  /// if the procedure was successful , return empty string.
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> deleteMapFolders(ImageFolder folder) async {
    if (folder == null) {
      Logger.error("deleteMapFolders: null folder");
      return "ארעה שגיאה";
    }
    final String currentProjectId = ProjectHandler().getCurrentProjectId();

    final List<ImageReference> images = await this
        ._imageFolderDAO
        .allImageReferencesFromFolderAsList(
            currentProjectId: currentProjectId, id: folder.id);

    for (ImageReference image in images) {
      try {
        await this._storageService.deleteFile(image.fullPath);
      } catch (ignored) {
        Logger.error(ignored.toString());
      }
    }
    return await _imageFolderDAO.deleteWithEntity(
        toDelete: folder, currentProject: currentProjectId);
  }

  ///
  /// rename given [ImageReference] view name from the given [folder].
  /// if the procedure was successful , return empty [String].
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> addingSingleReference({
    @required ImageFolder folder,
    @required ImageReference refToUpdate,
  }) async {
    if (refToUpdate == null || !refToUpdate.validateMustFields()) {
      return "שדות לא תקינים";
    }
    await updateEditorAndModifiedTime(refToUpdate);
    final msg = await _imageFolderDAO.addReferences(
        imageFolder: folder,
        imageRefs: {refToUpdate.imageUrl: refToUpdate},
        currentProjectId: ProjectHandler().getCurrentProjectId());
    return msg;
  }

  ///
  /// rename given [ImageReference] view name from the given [folder].
  /// if the procedure was successful , return empty [String].
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> updatingSingleReference({
    @required ImageFolder folder,
    @required ImageReference refToUpdate,
  }) async {
    if (refToUpdate == null || !refToUpdate.validateMustFields()) {
      return "שדות לא תקינים";
    }
    await updateEditorAndModifiedTime(refToUpdate);
    final msg = await _imageFolderDAO.updateReferences(
        imageFolder: folder,
        imageRefs: {refToUpdate.imageUrl: refToUpdate},
        currentProjectId: ProjectHandler().getCurrentProjectId());
    return msg;
  }

  ///
  /// delete given [ImageReference] from given [ImageFolder]
  /// if the procedure was successful , return empty [String].
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> deleteImage({
    @required ImageFolder folder,
    @required ImageReference toDelete,
  }) async {
    try {
      if (toDelete == null || !toDelete.validateMustFields()) {
        return "שדות לא תקינים";
      }
      // delete from firebase storage
      await this._storageService.deleteFile(toDelete.fullPath);
      final msg = await _imageFolderDAO.deleteImage(
          imageFolder: folder,
          toDelete: toDelete,
          currentProjectId: ProjectHandler().getCurrentProjectId());
      return msg;
    } catch (error) {
      Logger.error("Error in 'deleteImage'\n$error");
      return Constants.GENERAL_ERROR_MSG;
    }
  }

  ///
  /// Uploads given [ImageReference] to given [ImageFolder]
  /// if the procedure was successful , return empty [String].
  /// otherwise will return msg with the reason for failure
  ///
  Future<String> uploadImageToFolder({
    @required ImageFolder folder,
    @required ImageReference toUpdate,
    @required File imageToUpload,
  }) async {
    final uuid = Uuid();
    final imageFinalName = uuid.v4();
    final fullPath = "${ProjectHandler().getCurrentProjectName()}/${folder.id}"
        "/${Constants.MAP_FOLDER_IMAGES}/$imageFinalName.jpg";
    try {
      final imageUrl =
          await this._storageService.uploadFile(fullPath, imageToUpload);
      toUpdate.imageUrl = imageUrl;
      toUpdate.fullPath = fullPath;

      await updateEditorAndModifiedTime(toUpdate);

      final msg =
          await addingSingleReference(folder: folder, refToUpdate: toUpdate);
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
  /// Get desired [ImageFolder] according to given date from current [Project]
  ///
  Future<ImageFolder> getFolderByDate(DateTime date) async {
    List<ImageFolder> result =
        await this._imageFolderDAO.allItemsAsListWithEqualsGivenField(
              projectId: ProjectHandler().getCurrentProjectId(),
              field: Constants.MAP_FOLDER_DATE,
              predicate: date.millisecondsSinceEpoch,
            );
    if (result == null || result.isEmpty) {
      return null;
    } else {
      return result.first;
    }
  }

  ///
  /// Get desired [ImageFolder] according to given id from current [Project]
  ///
  Future<ImageFolder> getFolderByID(String id) async {
    if (id == null || id.isEmpty) {
      return null;
    }
    return await this._imageFolderDAO.getById(
        currentProject: ProjectHandler().getCurrentProjectId(), id: id);
  }

  ///
  /// pre loads all data from [DailyInfoHandler] when entering a chosen [Project]
  ///
  Future<void> preLoadDataForProject(String projectId) async {
    await _workArrangementDAO.allItemsAsList(projectId: projectId);
    await _driveArrangementDAO.allItemsAsList(projectId: projectId);
    await _imageFolderDAO.allItemsAsList(projectId: projectId);
  }

  @override
  Future<String> resetForTests({String projectId}) async {
    String projectToDeleteFrom =
        projectId != null ? projectId : ProjectHandler().getCurrentProjectId();
    final msg1 = await this
        ._driveArrangementDAO
        .deleteAllItemsForTestOnly(projectToDeleteFrom);
    final msg2 = await this
        ._workArrangementDAO
        .deleteAllItemsForTestOnly(projectToDeleteFrom);
    return "$msg1$msg2";
  }

  ///
  /// get all imagesReferences as Stream
  ///
  Stream<List<ImageReference>> allImageReferencesStream(
      String currentProjectId, String folderId) {
    return _imageFolderDAO.allImageReferencesFromFolderAsStream(
        currentProjectId: currentProjectId, id: folderId);
  }
}

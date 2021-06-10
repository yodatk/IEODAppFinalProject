import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;
import '../logic/ProjectHandler.dart';
import '../logic/handler.dart';
import '../models/plot.dart';
import '../models/project.dart';
import '../models/site.dart';
import '../models/strip.dart';
import '../models/stripStatus.dart';
import '../services/DAO/FireStoreDAO/firestore_plot_dao.dart';
import '../services/DAO/FireStoreDAO/firestore_site_dao.dart';
import '../services/DAO/FireStoreDAO/firestore_strip_dao.dart';
import '../services/DAO/interfacesDAO/plot_dao.dart';
import '../services/DAO/interfacesDAO/site_dao.dart';
import '../services/DAO/interfacesDAO/strip_dao.dart';
import 'entity_updater.dart';
import 'stateNotifiers/entityNotifier.dart';

///
/// Class to handle all the [Plot] and [Strip] data manipulation and logic procedures
///
class FieldHandler extends Handler with EntityUpdater {
  ///
  /// [FieldHandler] singleton instance
  ///
  static final FieldHandler _instance = FieldHandler._internal();

  ///
  /// DAO for [Plot]
  ///
  PlotDAO _plotDAO;

  ///
  /// DAO for [Site]
  ///
  SiteDAO _siteDAO;

  ///
  /// DAO for [Strip]
  ///
  StripDAO _stripDAO;

  ///
  /// strips from current plot which have the status of [StripStatus.NONE]
  ///
  Set<Strip> currentNoneStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.IN_FIRST]
  ///
  Set<Strip> currentInFirstStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.FIRST_DONE]
  ///
  Set<Strip> currentFirstDoneStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.IN_SECOND]
  ///
  Set<Strip> currentInSecondStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.SECOND_DONE]
  ///
  Set<Strip> currentSecondDoneStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.IN_REVIEW]
  ///
  Set<Strip> currentInReviewStrips;

  ///
  /// strips from current plot which have the status of [StripStatus.FINISHED]
  ///
  Set<Strip> currentFinishedStrips;

  ///
  /// [EntityController] for the current chosen [plot]
  ///
  EntityController<Plot> _currentPlotController;

  ///
  /// [EntityController] for the current chosen [plot]
  ///
  EntityController<Site> _currentSiteController;

  ///
  /// getter to the singleton Instance
  ///
  factory FieldHandler() => _instance;

  ///
  /// Private Constructor for [FieldHandler]
  ///
  FieldHandler._internal() {
    init();
    this._currentPlotController = EntityController<Plot>(
        id: null, streamFunction: this.getPlotByIdAsStream);
    this._currentSiteController =
        EntityController<Site>(id: null, streamFunction: this.getSiteById);
  }

  @override
  void initWithFirebase() {
    this._siteDAO = FireStoreSiteDAO();
    this._plotDAO = FireStorePlotDAO();
    this._stripDAO = FireStoreStripDAO();
  }

  ///
  /// Reset the current [Plot] with the given [plotId]
  /// if given id is null, will reset the current plot to null
  ///
  Future<void> resetCurrentPlot(String plotId) async {
    await _currentPlotController?.reset(plotId);
    this.currentNoneStrips = null;
    this.currentInFirstStrips = null;
    this.currentFirstDoneStrips = null;
    this.currentInSecondStrips = null;
    this.currentSecondDoneStrips = null;
    this.currentInReviewStrips = null;
    this.currentFinishedStrips = null;
  }

  ///
  /// Get all Strips in the current plot. if there is no current plot will return an empty set
  ///
  Set<Strip> getAllCurrentStrips() => {
        ...(this.currentNoneStrips ?? {}),
        ...(this.currentInFirstStrips ?? {}),
        ...(this.currentFirstDoneStrips ?? {}),
        ...(this.currentInSecondStrips ?? {}),
        ...(this.currentSecondDoneStrips ?? {}),
        ...(this.currentInReviewStrips ?? {}),
        ...(this.currentFinishedStrips ?? {}),
      };

  ///
  /// Get the current [Plot]
  ///
  Plot readCurrentPlot() {
    return _currentPlotController?.read();
  }

  ///
  /// Reset the current [Site] with the given [siteId]
  /// if given id is null, will reset the current plot to null
  ///
  Future<void> resetCurrentSite(String siteId) async {
    await _currentSiteController?.reset(siteId);
  }

  ///
  /// get the current [Site]
  ///
  Site readCurrentSite() {
    return _currentSiteController?.read();
  }

  ///
  /// Adding [toAdd] Plot to the project with [projectId] and updates the data base
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> addPlotToSite({Plot toAdd, String projectId}) async {
    if (toAdd == null) {
      return _handleError("addPlotToSite", "cant add empty plot");
    } else if (!toAdd.validateMustFields()) {
      return _handleError("addPlotToSite", "some of the field are invalid");
    } else if (projectId == null || projectId.isEmpty) {
      return _handleError("addPlotToSite", "invalid Project Id");
    }
    return this._plotDAO.updateWithOverride(
          toUpdate: toAdd,
          currentProjectId: ProjectHandler().getCurrentProjectId(),
        );
  }

  ///
  /// Update [toUpdate] Plot in the project with [projectId] and updates the data base
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> updatePlot(
      {@required Plot toUpdate, @required String projectId}) async {
    if (toUpdate == null) {
      return _handleError("updatePlot", "cant update empty plot");
    } else if (!toUpdate.validateMustFields()) {
      return _handleError("updatePlot", "some of the field are invalid");
    } else if (projectId == null || projectId.isEmpty) {
      return _handleError("updatePlot", "invalid Project Id");
    }
    updateEntityModifiedTime(toUpdate);
    return _plotDAO.update(
        toUpdate: toUpdate,
        data: toUpdate.toJson(),
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Deletes [toDelete] Plot from the project with [projectId] and updates the data base
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> deletePlot(
      {@required Plot toDelete, @required String projectId}) async {
    if (toDelete == null) {
      return _handleError("deletePlot", " cannot delete an null plot");
    } else if (projectId == null || projectId.isEmpty) {
      return _handleError("deletePlot", "project id is invalid");
    }
    return _plotDAO.deleteWithId(
        toDeleteId: toDelete.id, currentProject: projectId);
  }

  ///
  /// Adds [strip] to the current project and updates the data base.
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> addStrip({@required Strip strip}) async {
    if (strip == null) {
      return _handleError("addStrip", "cannot add an null strip");
    } else if (!strip.validateMustFields()) {
      return _handleError("addStrip", "some of the fields are invalid");
    }
    return _stripDAO.updateWithOverride(
        toUpdate: strip,
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Adding Multiple [Strip] to a certain [Plot]
  ///
  Future<String> addMultipleStrips({@required List<Strip> toAdd}) async {
    if (toAdd == null || toAdd.isEmpty) {
      Logger.error("'addMultipleStrips': cannot add null or empty Strips");
      return "ארעה שגיאה";
    }
    return await _stripDAO.addMultipleStrips(
        toAdd: toAdd, projectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Gets a [Strip] that matches the [stripId] in the [Project] with [projectId]
  ///
  Future<Strip> getStripById({
    @required String stripId,
    @required String projectId,
  }) {
    if (stripId == null || stripId.isEmpty) {
      _handleError('getStripById', "strip id cannot be null or empty");
      return null;
    }
    if (stripId == null || stripId.isEmpty) {
      _handleError('getStripById', "project id cannot be null or empty");
      return null;
    }
    return _stripDAO.getById(currentProject: projectId, id: stripId);
  }

  ///
  /// Edit [strip] in the current project and updates the data base
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> editStrip(
      {@required Strip strip, @required Map<String, dynamic> changes}) async {
    if (strip == null) {
      return _handleError("editStrip", "cannot edit an null strip");
    } else if (!strip.validateMustFields()) {
      return _handleError("editStrip", "some of the fields are invalid");
    }
    if (changes == null || changes.isEmpty) {
      return _handleError("editStrip", "changes cannot be null or empty");
    }
    updateEntityModifiedTime(strip);
    changes[Constants.ENTITY_MODIFIED] =
        strip.timeModified.millisecondsSinceEpoch;
    return _stripDAO.update(
        toUpdate: strip,
        data: changes,
        currentProjectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Deletes [strip] from the current project and updates the data base
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> deleteStrip({@required Strip strip}) async {
    if (strip == null) {
      Logger.error("'deleteStrip': cannot delete an null strip");
      return "ארעה שגיאה";
    }
    return _stripDAO.deleteWithId(
        toDeleteId: strip.id,
        currentProject: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// gets all [Strip] from [Plot] with given [plotId] and with the given [status] as Stream
  ///
  Stream<List<Strip>> getAllStripsOfPlotFromGivenStatusAsStream(
      {@required String plotId, @required StripStatus status}) {
    if (plotId == null || plotId.isEmpty) {
      Logger.error(
          "'getAllStripsOfPlotFromGivenStatusAsStream': plotId is invalid");
      return null;
    }
    if (status == null) {
      Logger.error(
          "'getAllStripsOfPlotFromGivenStatusAsStream': status is invalid");
      return null;
    }
    return _stripDAO.allItemsFilteredByFieldsAsStream(
      projectId: ProjectHandler().getCurrentProjectId(),
      fields: {
        Constants.STRIP_PLOT_ID: plotId,
        Constants.STRIP_STATUS: describeEnum(status)
      },
    );
  }

  ///
  /// Get all [Plot] of a certain [Site] with [siteId] from project with [projectId] as Stream
  ///
  Stream<List<Plot>> getAllPlotsOfSiteAsStream({
    @required String siteId,
    @required String projectId,
  }) {
    return _plotDAO.allItemsFilteredByFieldsAsStream(
        projectId: projectId, fields: {Constants.PLOT_SITE_ID: siteId});
  }

  ///
  /// Get [Plot] with the given [plotId] from the data base
  ///
  Future<Plot> getPlotById(String plotId) async {
    if (plotId == null || plotId.isEmpty) {
      Logger.error("'getPlotById': given plotId is null or empty");
      return null;
    }
    return await _plotDAO.getById(
        currentProject: ProjectHandler().getCurrentProjectId(), id: plotId);
  }

  ///
  /// Get [Plot] with the given [plotId] from the data base as Stream
  ///
  Stream<Plot> getPlotByIdAsStream(String plotId) {
    if (plotId == null || plotId.isEmpty) {
      Logger.error("'getPlotByIdAsStream': given plotId is null or empty");
      return null;
    }
    return _plotDAO.getByIdAsStream(
        currentProject: ProjectHandler().getCurrentProjectId(), id: plotId);
  }

  ///
  /// Get all [Plot] as stream from data base
  ///
  Stream<List<Plot>> getAllPlots() {
    return _plotDAO.allItemsAsStream(
        projectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// get all [Strip] of a [Plot] with given [plotId] in a [Project] with the given [projectId]
  ///
  Stream<List<Strip>> getAllStripsOfPlot(String plotId, String projectId) {
    if (plotId == null || plotId == "") {
      Logger.error("'getAllStripsOfPlot': given plotId is null or empty");
      return null;
    }
    if (projectId == null || projectId.isEmpty) {
      Logger.error("'getAllStripsOfPlot': given projectId is null or empty");
      return null;
    }
    return _stripDAO.allItemsFilteredByFieldsAsStream(
        projectId: projectId, fields: {Constants.STRIP_PLOT_ID: plotId});
  }

  ///
  /// get all [Strip] of a [Plot] with the given [plotId] in a [Project] with the given [projectId]
  ///
  Future<List<Strip>> getAllStripsOfGivenPlotAsList({
    @required String plotId,
    @required String projectId,
  }) async {
    if (plotId == null || plotId.isEmpty) {
      Logger.error(
          "'getAllStripsOfGivenPlotAsList': given plotId is null or empty");
      return [];
    }
    if (projectId == null || projectId.isEmpty) {
      Logger.error(
          "'getAllStripsOfGivenPlotAsList': given projectId is null or empty");
      return [];
    }
    return _stripDAO.allItemsAsListWithEqualsGivenField(
      projectId: ProjectHandler().getCurrentProjectId(),
      field: Constants.STRIP_PLOT_ID,
      predicate: plotId,
    );
  }

  ///
  /// Get all [Site] of a [Project] with given [projectId] as stream from database
  ///
  Stream<List<Site>> getAllSitesOfProjectAsStream() {
    return _siteDAO.allItemsAsStream(
        projectId: ProjectHandler().getCurrentProjectId());
  }

  ///
  /// Get [Site] with the given [siteId] from database.
  ///
  Stream<Site> getSiteById(String siteId) {
    if (siteId == null || siteId.isEmpty) {
      Logger.error("'getSiteById': cannot use empty or null site id");
      return null;
    }

    return _siteDAO.getByIdAsStream(
        currentProject: ProjectHandler().getCurrentProjectId(), id: siteId);
  }

  ///
  /// Get [Site] with the given [siteId] from database.
  ///
  Future<Site> getSiteByIdOnce(String siteId) async {
    if (siteId == null || siteId.isEmpty) {
      Logger.error("'getSiteById': cannot use empty or null site id");
      return null;
    }

    return _siteDAO.getById(
        currentProject: ProjectHandler().getCurrentProjectId(), id: siteId);
  }

  ///
  /// Adds given [toAdd] to the [Project] with given [projectId] to database
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> addSite({
    @required Site toAdd,
    @required String projectId,
  }) async {
    if (toAdd == null) {
      return _handleError('addSite', " can't add null Site");
    } else if (!toAdd.validateMustFields()) {
      return _handleError('addSite', "site includes invalid values");
    }
    if (projectId == null) {
      return _handleError('addSite', "project id cannot be null");
    }
    return _siteDAO.updateWithOverride(
        currentProjectId: projectId, toUpdate: toAdd);
  }

  ///
  /// Deletes given [toDelete] from the [Project] with given [projectId] to database
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> deleteSite({
    @required Site toDelete,
    @required String projectId,
  }) async {
    if (toDelete == null) {
      return _handleError('deleteSite', "can't delete null Site");
    }
    if (projectId == null) {
      return _handleError('deleteSite', 'project id cannot be null');
    }
    return _siteDAO.removeSite(toRemove: toDelete, projectId: projectId);
  }

  ///
  /// Updates given [toUpdate] in the [Project] with given [projectId] to database
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> updateSite({
    @required Site toUpdate,
    @required String projectId,
  }) async {
    if (toUpdate == null) {
      return _handleError('updateSite', "can't update null Site");
    } else if (!toUpdate.validateMustFields()) {
      return _handleError('updateSite', 'site includes invalid values');
    }
    if (projectId == null) {
      return _handleError('updateSite', 'project id cannot be null');
    }
    return _siteDAO.updateSite(toUpdate: toUpdate, projectId: projectId);
  }

  ///
  /// Gets all available [Strip] in a [Project] with the [projectId]
  ///
  Future<List<Strip>> getAllStripsOfProject(String projectId) async =>
      await _stripDAO.allItemsAsList(projectId: projectId);

  ///
  /// preloads all needed data of [Site] , [Plot] and [Strip] from a [Project] with the given [projectId]
  ///
  Future<void> preLoadDataForProject(String projectId) async {
    await _siteDAO.allItemsAsList(projectId: projectId);
    await _plotDAO.allItemsAsList(projectId: projectId);
    await _stripDAO.allItemsAsList(projectId: projectId);
  }

  @override
  Future<String> resetForTests({String projectId}) async {
    String projectToDeleteFrom =
        projectId != null ? projectId : ProjectHandler().getCurrentProjectId();
    final msg1 =
        await this._siteDAO.deleteAllItemsForTestOnly(projectToDeleteFrom);
    final msg2 =
        await this._plotDAO.deleteAllItemsForTestOnly(projectToDeleteFrom);
    final msg3 =
        await this._stripDAO.deleteAllItemsForTestOnly(projectToDeleteFrom);
    return "$msg1$msg2$msg3";
  }
}

String _handleError(String funcName, errorMsg) {
  Logger.error("'$funcName': $errorMsg");
  return "ארעה שגיאה";
}

///
/// State Provider for current [Plot]
///
final currentPlotProvider = StateNotifierProvider<EntityController<Plot>>(
    (ref) => FieldHandler()._currentPlotController);

///
/// State Provider for current [Site]
///
final currentSiteProvider = StateNotifierProvider<EntityController<Site>>(
    (ref) => FieldHandler()._currentSiteController);

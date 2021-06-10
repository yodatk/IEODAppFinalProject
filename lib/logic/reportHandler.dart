import 'package:IEODApp/logic/handler.dart';
import 'package:flutter/foundation.dart';

import '../constants/ExampleTemplates.dart';
import '../constants/constants.dart' as Constants;
import '../logger.dart' as Logger;
import '../models/project.dart';
import '../models/reports/Report.dart';
import '../models/reports/templates/Template.dart';
import '../services/DAO/FireStoreDAO/firestore_report_template_dao.dart';
import '../services/DAO/interfacesDAO/report_template_dao.dart';
import 'ProjectHandler.dart';
import 'entity_updater.dart';

///
/// Class to handle all the [Report] and [Template] data manipulation and logic procedures
///
class ReportHandler extends Handler with EntityUpdater {
  ///
  /// Singleton instance
  ///
  static final ReportHandler _instance = ReportHandler._internal();

  ///
  /// DAO for [Report] and [Template]
  ///
  ReportTemplateDAO _reportTemplateDAO;

  ///
  /// Getter of the singleton Instance
  ///
  factory ReportHandler() => _instance;

  ///
  /// Private constructor for [ReportHandler]
  ///
  ReportHandler._internal() {
    init();
  }

  @override
  void initWithFirebase() {
    this._reportTemplateDAO = FireStoreReportTemplateDAO();
  }

  ///
  /// Deletes the given [toDelete] report from the [Project] with the given [projectId]
  ///
  Future<String> deleteReport({
    @required Report toDelete,
    @required String projectId,
  }) async {
    if (toDelete == null) {
      Logger.error('deleteReport: cant delete a null report');
      return "ארעה שגיאה";
    }
    if (projectId == null || projectId.isEmpty) {
      Logger.error('deleteReport: projectId is invalid');
      return "ארעה שגיאה";
    }
    return this._reportTemplateDAO.deleteWithId(
        currentProject: ProjectHandler().getCurrentProjectId(),
        toDeleteId: toDelete.id);
  }

  ///
  /// Get most updated report [Template] from database by type
  ///
  Future<Template> fetchReportTemplateByType(TemplateTypeEnum type) async {
    return await _reportTemplateDAO.fetchReportTemplateByType(type);
  }

  ///
  /// Uploads a Template from the exampleTempltes files by the given [type], and returns the template that was uploaded
  ///
  Future<Template> uploadNewTemplateByType(TemplateTypeEnum type) async {
    if (templateToFunctionMap.containsKey(type)) {
      Template newTemplate = templateToFunctionMap[type]() as Template;
      await uploadTemplate(newTemplate);
      return newTemplate;
    } else {
      return null;
    }
  }

  ///
  /// Get most updated manual report [Template] from database
  ///
  Future<Report> retrieveReportData(String projectId, String id) async {
    if (projectId == null || projectId.isEmpty) {
      Logger.error("retrieveReportData: null or empty project id");
      return null;
    }
    if (id == null || id.isEmpty) {
      Logger.error("retrieveReportData: null or empty report id");
      return null;
    }
    return await _reportTemplateDAO.retrieveReportData(
        projectId: projectId, id: id);
  }

  ///
  /// Upload to the database [report] to a [Project] with given [projectId]
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> uploadUpdateReport(String projectId, Report report) async {
    if (projectId == null || projectId.isEmpty) {
      Logger.error(
          "uploadUpdateReport: cant upload report to null or empty project");
      return Constants.FAIL;
    }
    if (report == null) {
      Logger.error("uploadUpdateReport: can't upload null report");
      return Constants.FAIL;
    }
    if (!report.validateMustFields()) {
      Logger.error("uploadUpdateReport: some of the fields are invalid");
      return Constants.FAIL;
    }
    updateEntityModifiedTime(report);
    return await _reportTemplateDAO.updateWithOverride(
        currentProjectId: projectId, toUpdate: report);
  }

  ///
  /// Upload to the database [template] to be used when new [Report] are created.
  /// if procedure was successful, will return an empty string result.
  /// otherwise will return string message with description of the error
  ///
  Future<String> uploadTemplate(Template template) async {
    return await _reportTemplateDAO.uploadTemplate(template: template);
  }

  ///
  /// Fetching all [Report] from a given [TemplateTypeEnum] type, of a [Plot] with the given [plotName] in the [Project] with the given [projectId]
  ///
  Stream<List<Report>> getAllReportsInProjectByTypeByPlot(
      String plotName, TemplateTypeEnum reportType) {
    if (reportType == null) {
      Logger.error(
          "getAllReportsInProjectByTypeByPlot: reportType cant be null");
      return null;
    }
    if (plotName == null || plotName.isEmpty) {
      Logger.error(
          "getAllReportsInProjectByTypeByPlot: given plot name is invalid");
      return null;
    }
    final stream = _reportTemplateDAO.getAllReportsInProjectByTypeByPlot(
        ProjectHandler().getCurrentProjectId(), plotName, reportType);
    return stream;
  }

  ///
  /// Fetching all [Report] from a given [TemplateTypeEnum] type, in the [Project] with the given [projectId]
  ///
  Stream<List<Report>> getAllReportsInProjectByType(
      TemplateTypeEnum reportType) {
    if (reportType == null) {
      Logger.error(
          "getAllReportsInProjectByTypeByPlot: reportType cant be null");
      return null;
    }
    final stream = _reportTemplateDAO.getAllReportsInProjectByType(
        ProjectHandler().getCurrentProjectId(), reportType);
    return stream;
  }

  ///
  /// loading all relevant data of [Report] and [Template] for a [Project] with the given [projectId]
  ///
  Future<void> preLoadDataForProject(String projectId) async {
    await this._reportTemplateDAO.getAllReportsInProject(projectId);
  }

  ///
  /// get all relevant data of [Report] and [Template] for a [Project] with the given [projectId] and the given [date]
  ///
  Future<List<Report>> getAllReportsInProjectByDate(DateTime date) async {
    List<Report> reports = await this
        ._reportTemplateDAO
        .getAllReportsInProjectByDate(
            ProjectHandler().getCurrentProjectId(), date);
    if (reports == null || reports.isEmpty) {
      return [];
    } else {
      return reports;
    }
  }

  @override
  Future<String> resetForTests({String projectId}) async {
    String projectToDeleteFrom =
        projectId != null ? projectId : ProjectHandler().getCurrentProjectId();
    final msg = await this
        ._reportTemplateDAO
        .deleteAllItemsForTestOnly(projectToDeleteFrom);
    return msg;
  }
}

import 'package:flutter/foundation.dart';

import '../../../models/reports/Report.dart';
import '../../../models/reports/templates/Template.dart';
import 'entity_dao.dart';

///
/// Specific DAO for the [Report] and [Template] Entities
///
abstract class ReportTemplateDAO extends EntityDAO<Report> {
  ///
  /// Fetches the latest [Template] of Report Template by Keyword
  ///
  Future<Template> fetchReportTemplateByType(TemplateTypeEnum type);

  ///
  /// Fetches the [Report] with the given [id] from [Project] with given [projectId]
  ///
  Future<Report> retrieveReportData(
      {@required String projectId, @required String id});

  ///
  /// Uploads a new [Template] object (given [template])
  /// if procedure was successful, return empty [String]
  /// otherwise return a [String] with the error message
  ///
  Future<String> uploadTemplate({@required Template template});

  ///
  /// Returns [Stream] of [Report] according to given [plotName], [reportType], and [projectId]
  ///
  Stream<List<Report>> getAllReportsInProjectByTypeByPlot(
      String projectId, String plotName, TemplateTypeEnum reportType);

  ///
  /// Returns [Stream] of [Report] according to given [reportType], and [projectId]
  ///
  Stream<List<Report>> getAllReportsInProjectByType(
      String projectId, TemplateTypeEnum reportType);

  ///
  /// Returns all [Report] from [Project] with given [projectId]
  ///
  Future<List<Report>> getAllReportsInProject(String projectId);

  ///
  /// Returns all [Report] from [Project] of a specific [date] with given [projectId]
  ///
  Future<List<Report>> getAllReportsInProjectByDate(
      String projectId, DateTime date);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/ExampleTemplates.dart';
import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../models/reports/Report.dart';
import '../../../models/reports/templates/Template.dart';
import '../../services_firebase/firebase_data_service.dart';
import '../interfacesDAO/report_template_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Report] and [Template] DAO with Firestore
///
class FireStoreReportTemplateDAO extends FireStoreEntityDAO<Report>
    implements ReportTemplateDAO {
  FireStoreReportTemplateDAO()
      : super(
            collectionName: Constants.REPORTS_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Report.fromJson(id: id, data: data));

  ///
  /// Fetching the latest [Template] of Report Template by Keyword
  ///
  Future<Template> fetchReportTemplateByType(TemplateTypeEnum type) async {
    DocumentReference parentRef = FireStoreDataService()
        .getRoot()
        .collection(Constants.TEMPLATE_COLLECTION_NAME)
        .doc(describeEnum(type));
    final DocumentSnapshot parentDoc = await parentRef.get();
    if (parentDoc == null || !parentDoc.exists) {
      return null;
    } else {
      Map<String, dynamic> parentData = parentDoc.data();
      DocumentReference templateRef =
          parentData[Constants.TEMPLATE_LATEST_NAME] as DocumentReference;
      if (templateRef == null) {
        return null;
      } else {
        final templateDoc = await templateRef.get();
        if (templateDoc == null || !templateDoc.exists) {
          return null;
        } else {
          return Template.fromJson(
              id: templateDoc.id, data: templateDoc.data());
        }
      }
    }
  }

  ///
  /// Fetching the [Report] with the given [id] from [Project] with given [projectId]
  ///
  Future<Report> retrieveReportData(
      {@required String projectId, @required String id}) async {
    DocumentSnapshot reportDoc = await FireStoreDataService()
        .getRoot()
        .collection(Constants.PROJECTS)
        .doc(projectId)
        .collection(Constants.REPORTS_COLLECTION_NAME)
        .doc(id)
        .get();
    if (reportDoc == null || !reportDoc.exists) {
      return null;
    } else {
      return await reportRefToDoc(reportDoc);
    }
  }

  ///
  /// Converts [Report] with [Template] reference to proper [Report] object
  ///
  Future<Report> reportRefToDoc(DocumentSnapshot reportDoc) async {
    Map<String, dynamic> reportData = reportDoc.data();
    DocumentReference templateRef =
        reportData[Constants.REPORT_TEMPLATE] as DocumentReference;
    final DocumentSnapshot templateDoc = await templateRef.get();
    if (templateDoc == null || !templateDoc.exists) {
      return null;
    } else {
      Map<String, dynamic> templateData = templateDoc.data();
      Template template =
          Template.fromJson(id: templateDoc.id, data: templateData);
      reportData[Constants.REPORT_TEMPLATE] = template;
      return fromJson(id: reportDoc.id, data: reportData);
    }
  }

  ///
  /// Upload [toUpdate] from [Project] with id of [currentProjectId]
  /// if procedure was successful, return an empty [String]
  /// otherwise returns a [String] with the error message.
  ///
  Future<String> updateWithOverride(
      {@required String currentProjectId, @required Report toUpdate}) async {
    Template template = toUpdate.template;
    DocumentReference templateDoc = fetchTemplateDoc(template);
    Map<String, dynamic> entry = toUpdate.toJson();
    entry[Constants.REPORT_TEMPLATE] = templateDoc;
    String reportID = toUpdate.id != "" ? toUpdate.id : null; // for path

    getNewBatch();
    try {
      final docRef = FireStoreDataService()
          .getRoot()
          .collection(Constants.PROJECTS)
          .doc(currentProjectId)
          .collection(Constants.REPORTS_COLLECTION_NAME)
          .doc(reportID);
      writeBatch.set(docRef, entry);
      writeBatch.commit();
      if (reportID == null) toUpdate.id = docRef.id;
      return toUpdate.id;
    } catch (e) {
      Logger.error(e.toString());
      return Constants.FAIL;
    }
  }

  ///
  /// Get the Document reference of [Template]
  ///
  DocumentReference fetchTemplateDoc(Template template) {
    final collectionReference = FireStoreDataService()
        .getRoot()
        .collection(Constants.TEMPLATE_COLLECTION_NAME);
    final parentRef =
        collectionReference.doc(describeEnum(template.templateType));
    final docRef = parentRef
        .collection('All ${describeEnum(template.templateType)}')
        .doc(template.id);
    return docRef;
  }

  DocumentReference setLatestForTemplateType(TemplateTypeEnum type) {
    final templateToUpload = templateToFunctionMap[type]();
    if (templateToUpload == null) {
      Logger.critical("not valid type : $type");
      throw Exception("not valid type : $type");
    }
    final collectionReference = FireStoreDataService()
        .getRoot()
        .collection(Constants.TEMPLATE_COLLECTION_NAME);
    final parentRef = collectionReference.doc(describeEnum(type));
    final docRef = parentRef
        .collection('All ${describeEnum(type)}')
        .doc(Constants.TEMPLATE_LATEST_NAME);
    return docRef;
  }

  ///
  /// Upload a new [Template] object (given [template])
  /// if procedure was successful, return empty [String]
  /// otherwise return a [String] with the error message
  ///
  Future<String> uploadTemplate({@required Template template}) async {
    getNewBatch();
    try {
      final collectionReference = FireStoreDataService()
          .getRoot()
          .collection(Constants.TEMPLATE_COLLECTION_NAME);
      final parentRef =
          collectionReference.doc(describeEnum(template.templateType));
      final childCollectionRef =
          getTemplateCollectionByType(template.templateType);
      DocumentReference newTemplateRef = childCollectionRef.doc();
      template.id = newTemplateRef.id;
      Map<String, dynamic> parentData = {
        Constants.TEMPLATE_LATEST_NAME: newTemplateRef
      };
      Map<String, dynamic> entry = template.toJson();
      writeBatch.set(newTemplateRef, entry, SetOptions(merge: true));
      writeBatch.set(parentRef, parentData, SetOptions(merge: true));
      await writeBatch.commit();
      return "";
    } catch (e) {
      Logger.error(e.toString());
      return Constants.FAIL;
    }
  }

  Future<Map<String, Template>> getAllTemplatesFromType(
      TemplateTypeEnum reportType) async {
    try {
      final templatesCollection = getTemplateCollectionByType(reportType);
      final allTemplateSnapshots = await templatesCollection.get();
      final output = allTemplateSnapshots.docs.fold(Map<String, Template>(),
          (Map<String, Template> previousValue, element) {
        previousValue[element.id] =
            Template.fromJson(id: element.id, data: element.data());
        return previousValue;
      });
      if (output.isEmpty) {
        //if list of templates is empty then create the latest based on example list
        final function = templateToFunctionMap[reportType];
        if (function == null) {
          return Map<String, Template>();
        }
        Template newTemplate = templateToFunctionMap[reportType]() as Template;
        await uploadTemplate(template: newTemplate);
        return {newTemplate.id: newTemplate};
      }
      return output;
    } catch (error, stack) {
      Logger.error(error.toString());
      Logger.error(stack.toString());
      throw error;
    }
  }

  CollectionReference getTemplateCollectionByType(TemplateTypeEnum reportType) {
    final reportTypeString = describeEnum(reportType);
    final collectionReference = FireStoreDataService()
        .getRoot()
        .collection(Constants.TEMPLATE_COLLECTION_NAME);
    final parentRef = collectionReference.doc(reportTypeString);
    return parentRef.collection('All $reportTypeString');
  }

  DocumentReference getTemplateDocByType(TemplateTypeEnum reportType) {
    final reportTypeString = describeEnum(reportType);
    final collectionReference = FireStoreDataService()
        .getRoot()
        .collection(Constants.TEMPLATE_COLLECTION_NAME);
    return collectionReference.doc(reportTypeString);
  }

  Stream<List<Report>> getAllReportsInProjectByTypeByPlot(
      String projectId, String plotName, TemplateTypeEnum reportType) async* {
    // 1. retrieve all relevant templates
    Map<String, Template> allTemplatesOfType =
        await getAllTemplatesFromType(reportType);
    final allRelevantReportsQuery =
        this.allItemsAsQuerySnapShotFilteredByFields(
      projectId: projectId,
      fields: {
        Constants.REPORT_ATTR + "." + Constants.PLOT_ID: plotName,
        Constants.REPORT_NAME: describeEnum(reportType),
      },
    );
    // 2. retrieve all relevant reports, and zip them with the matching template
    final result = allRelevantReportsQuery.map((snapshot) {
      return snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data();
            Template t = allTemplatesOfType[
                (data[Constants.REPORT_TEMPLATE] as DocumentReference).id];

            if (t == null) {
              //This means template was erased or changed and there is an inconsistency --> default to "latest"
              return null;
            }
            data[Constants.REPORT_TEMPLATE] = t;
            return Report.fromJson(id: doc.id, data: data);
          })
          .toList()
          .where((element) => element != null)
          .toList(); //removes nulls
    });

    yield* result;
  }

  Stream<List<Report>> getAllReportsInProjectByType(
      String projectId, TemplateTypeEnum reportType) async* {
    // 1. retrieve all relevant templates
    Map<String, Template> allTemplatesOfType =
        await getAllTemplatesFromType(reportType);
    final allRelevantReportsQuery =
        this.allItemsAsQuerySnapShotFilteredByFields(
      projectId: projectId,
      fields: {
        Constants.REPORT_NAME: describeEnum(reportType),
      },
    );
    // 2. retrieve all relevant reports, and zip them with the matching template
    final result = allRelevantReportsQuery.map((snapshot) {
      return snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data();
            Template t = allTemplatesOfType[
                (data[Constants.REPORT_TEMPLATE] as DocumentReference).id];

            if (t == null) {
              return null;
            }
            data[Constants.REPORT_TEMPLATE] = t;
            return fromJson(id: doc.id, data: data);
          })
          .where((element) => element != null)
          .toList();
    });
    yield* result;
  }

  Future<List<Report>> getAllReportsInProject(String projectId) async {
    // 1. retrieve all relevant templates
    final allTypes = Map<String, Map<String, Template>>();
    TemplateTypeEnum.values.forEach((element) async {
      final allTemplatesDocRef = getTemplateDocByType(element);
      final allTemplatesDoc = await allTemplatesDocRef.get();
      final currentLatest = (allTemplatesDoc.data() ??
              Map<String, dynamic>())[Constants.TEMPLATE_LATEST_NAME]
          as DocumentReference;
      if (currentLatest == null) {
        try {
          Template newTemplate = templateToFunctionMap[element]();
          await this.uploadTemplate(template: newTemplate);
        } catch (error, stack) {
          print("element is:$element");
        }
      }
      allTypes[describeEnum(element)] = await getAllTemplatesFromType(element);
    });
    // 2. retrieve all relevant reports, and zip them with the matching template
    final allRelevantReportsQuery =
        await this.allItemsAsDocumentSnapshotList(projectId: projectId);
    final result = allRelevantReportsQuery
        .map((doc) {
          Map<String, dynamic> data = doc.data();
          if (data == null) {
            return null;
          }
          final temp = allTypes[data[Constants.REPORT_NAME]];
          if (temp == null) {
            return null;
          }
          Template t =
              temp[(data[Constants.REPORT_TEMPLATE] as DocumentReference).id];

          if (t == null) {
            return null;
          }
          data[Constants.REPORT_TEMPLATE] = t;
          return fromJson(id: doc.id, data: data);
        })
        .where((element) => element != null)
        .toList();
    return result;
  }

  Future<List<Report>> getAllReportsInProjectByDate(
      String projectId, DateTime date) async {
    // 1. retrieve all relevant templates
    final allTypes = Map<String, Map<String, Template>>();
    TemplateTypeEnum.values.forEach((element) async {
      allTypes[describeEnum(element)] = await getAllTemplatesFromType(element);
    });
    // 2. retrieve all relevant reports, and zip them with the matching template
    final allRelevantReportsQuery =
        // await this.allItemsAsDocumentSnapshotList(projectId: projectId);
        await this.allItemsAsDocListWithEqualsGivenField(
            field: Constants.ENTITY_CREATED,
            predicate: date.millisecondsSinceEpoch,
            projectId: projectId);
    final result = allRelevantReportsQuery
        .map((doc) {
          Map<String, dynamic> data = doc.data();
          if (data == null) {
            return null;
          }
          final temp = allTypes[data[Constants.REPORT_NAME]];
          if (temp == null) {
            return null;
          }
          Template t =
              temp[(data[Constants.REPORT_TEMPLATE] as DocumentReference).id];

          if (t == null) {
            return null;
          }
          data[Constants.REPORT_TEMPLATE] = t;
          return Report.fromJson(id: doc.id, data: data);
        })
        // .where((element) => element.timeCreated.)
        .where((element) => element != null)
        .toList();
    return result;
  }
}

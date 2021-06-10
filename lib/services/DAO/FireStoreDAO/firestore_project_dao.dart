import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../models/project.dart';
import '../interfacesDAO/project_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Project] DAO with Firestore
///
class FireStoreProjectDAO extends FireStoreEntityDAO<Project>
    implements ProjectDAO {
  FireStoreProjectDAO()
      : super(
            collectionName: Constants.PROJECTS,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Project.fromJson(id: id, data: data));

  Future<List<DocumentSnapshot>> getAllEmployeesFromIdList(
      List<String> ids) async {
    List<DocumentSnapshot> output;
    final collectionRef = FireStoreDataService()
        .getRoot()
        .collection(Constants.EMPLOYEE_COLLECTION_NAME);
    if (ids.length < 10) {
      // less than 10 -> can use one query
      final tempQuery =
          await collectionRef.where(FieldPath.documentId, whereIn: ids).get();
      output = tempQuery.docs;
    } else {
      // more than 10 -> unfortunately need to query one by one
      output = [];
      for (String id in ids) {
        final currentEmp = await FireStoreDataService()
            .getRoot()
            .collection(Constants.EMPLOYEE_COLLECTION_NAME)
            .doc(id)
            .get();
        output.add(currentEmp);
      }
    }
    return output;
  }

  @override
  Future<String> addProject(Project toAdd) async {
    try {
      List<DocumentSnapshot> employeesToAdd =
          await getAllEmployeesFromIdList(toAdd.employees.toList());

      this.getNewBatch();
      for (DocumentSnapshot doc in employeesToAdd) {
        final projects = doc.data()[Constants.EMPLOYEE_PROJECTS] ?? [];
        (projects as List<dynamic>).add(toAdd.id);
        writeBatch.update(doc.reference, {
          Constants.EMPLOYEE_PROJECTS: projects,
        });
      }
      await updateWithOverrideLogic(toAdd, null);

      await this.commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "addProject");
    }
  }

  @override
  Future<String> deleteProject(Project toDelete) async {
    try {
      final relevantEmployees = await FireStoreDataService()
          .getRoot()
          .collection(Constants.EMPLOYEE_COLLECTION_NAME)
          .where(Constants.EMPLOYEE_PROJECTS, arrayContains: toDelete.id)
          .get();
      this.getNewBatch();
      for (DocumentSnapshot doc in relevantEmployees.docs) {
        final projects = doc.data()[Constants.EMPLOYEE_PROJECTS] ?? [];
        (projects as List<dynamic>).remove(toDelete.id);
        this.writeBatch.update(doc.reference, {
          Constants.EMPLOYEE_PROJECTS: projects,
        });
      }
      await this.deleteLogic(null, toDelete.id);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "deleteProject");
    }
  }

  @override
  Future<String> editProject(
      {@required Project toEdit,
      @required List<String> employeesToRemove,
      @required List<String> employeesToAdd}) async {
    try {
      this.getNewBatch();
      final employeesToRemoveDocs =
          (employeesToRemove == null || employeesToRemove.isEmpty)
              ? <DocumentSnapshot>[]
              : await getAllEmployeesFromIdList(employeesToRemove);
      final employeesToAddDocs =
          (employeesToAdd == null || employeesToAdd.isEmpty)
              ? <DocumentSnapshot>[]
              : await getAllEmployeesFromIdList(employeesToAdd);
      employeesToRemoveDocs.forEach((doc) {
        final projects = doc.data()[Constants.EMPLOYEE_PROJECTS] ?? [];
        (projects as List<dynamic>).remove(toEdit.id);
        this.writeBatch.update(doc.reference, {
          Constants.EMPLOYEE_PROJECTS: projects,
        });
      });
      employeesToAddDocs.forEach((doc) {
        final projects = doc.data()[Constants.EMPLOYEE_PROJECTS] ?? [];
        (projects as List<dynamic>).add(toEdit.id);
        this.writeBatch.update(doc.reference, {
          Constants.EMPLOYEE_PROJECTS: projects,
        });
      });
      await updateLogic(toEdit, toEdit.toJson(), null);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "editProject");
    }
  }

  String generateProjectId() {
    return FireStoreDataService().generateDocId();
  }
}

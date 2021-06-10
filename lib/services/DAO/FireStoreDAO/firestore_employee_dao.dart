import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../logic/result.dart';
import '../../../models/Employee.dart';
import '../../../models/project.dart';
import '../../services_firebase/firebase_data_service.dart';
import '../interfacesDAO/employee_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [Employee] DAO with Firestore
///
class FireStoreEmployeeDAO extends FireStoreEntityDAO<Employee>
    implements EmployeeDAO {
  FireStoreEmployeeDAO()
      : super(
            collectionName: Constants.EMPLOYEE_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                Employee.fromJson(id: id, data: data));

  Stream<Employee> getCurrentEmployeeStream(String id) {
    final users = getCollectionReference(projectId: null);
    try {
      final stream = users.doc(id).snapshots().map((doc) {
        if (doc.data() == null) {
          return null;
        }
        Employee currentEmployee = fromJson(id: doc.id, data: doc.data());
        List<String> newDetails = [];
        currentEmployee.toMap().forEach((key, value) {
          newDetails.add("\t$key -> ${value.toString()}");
        });
        Logger.infoList(["Current Logged In Employee Changed:", ...newDetails]);

        return currentEmployee;
      });
      return stream;
    } on FirebaseException catch (e) {
      Logger.info("error_code:${e.code}");
      return Stream<Employee>.value(null);
    } catch (error) {
      Logger.info(error.runtimeType.toString());
      Logger.info("error\n$error");
      throw error;
    }
  }

  Future<Result<Employee>> checkValidityOfLogin(String id, String email) async {
    try {
      CollectionReference employees = getCollectionReference(projectId: null);
      final employee = await employees.doc(id).get();
      if (employee == null || !employee.exists) {
        Logger.critical(
            "=================ERROR=================\ntried to log in with a user with the email : '$email' that exists in another ENV\n=================ERROR=================");
        return Result<Employee>(null, Constants.NOT_IN_ENV_ERROR, false);
      }
      return Result<Employee>(
          Employee.fromJson(id: employee.id, data: employee.data()), "", true);
    } catch (error) {
      Logger.error(error.toString());
      return Result<Employee>(null, Constants.GENERAL_ERROR_MSG, false);
    }
  }

  Future<String> registerEmployee(
      {@required Employee newEmployee, @required Project toAddTo}) async {
    try {
      getNewBatch();
      if (toAddTo != null) {
        // need to also update the list of employees in project
        toAddTo.employees.add(newEmployee.id);
        final docRef = FireStoreDataService()
            .getRoot()
            .collection(Constants.PROJECTS)
            .doc(toAddTo.id);
        this.writeBatch.update(docRef, {
          Constants.PROJECT_EMPLOYEES: toAddTo.employees.toList(),
        });
      }
      await updateWithOverrideLogic(newEmployee, null);
      await commit();
      return "";
    } catch (error) {
      toAddTo.employees.remove(newEmployee.id);
      return handleGeneralError(error, "'registerEmployee'");
    }
  }

  @override
  Future<String> deleteEmployee({@required Employee toDelete}) async {
    try {
      final relevantProjectsRegularEmployees = await FireStoreDataService()
          .getRoot()
          .collection(Constants.PROJECTS)
          .where(Constants.PROJECT_EMPLOYEES, arrayContains: toDelete.id)
          .get();
      final relevantProjectAsManager = await FireStoreDataService()
          .getRoot()
          .collection(Constants.PROJECTS)
          .where(Constants.PROJECT_MANAGER_ID, isEqualTo: toDelete.id)
          .get();
      if (relevantProjectAsManager.docs.length > 0) {
        // can't delete a manager from the project
        String msg = "list:\t";
        for (DocumentSnapshot doc in relevantProjectAsManager.docs) {
          msg += "${doc.data()[Constants.PROJECT_NAME]}\t";
        }
        return msg;
      }
      this.getNewBatch();
      // updating all relevant project
      for (DocumentSnapshot doc in relevantProjectsRegularEmployees.docs) {
        List<dynamic> newEmployees =
            doc.data()[Constants.PROJECT_EMPLOYEES] as List<dynamic> ??
                <dynamic>[];
        newEmployees.remove(toDelete.id);
        this.writeBatch.update(doc.reference, {
          Constants.PROJECT_EMPLOYEES: newEmployees,
        });
      }
      await deleteLogic(null, toDelete.id);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "'deleteEmployee'");
    }
  }

  Future<String> deleteEmployeesByEmails({
    @required List<String> emailsToDelete,
  }) async {
    try {
      final relevantEmployees = await FireStoreDataService()
          .getRoot()
          .collection(Constants.EMPLOYEE_COLLECTION_NAME)
          .where(Constants.EMPLOYEE_EMAIL, whereIn: emailsToDelete)
          .get();
      getNewBatch();
      for (var doc in relevantEmployees.docs) {
        this.writeBatch.delete(doc.reference);
      }
      this.writeBatch.commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "'deleteEmployeesByEmails'");
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../logic/result.dart';
import '../../../models/Employee.dart';
import '../../../models/project.dart';
import 'entity_dao.dart';

///
/// Specific DAO for  [Employee] entities
///
abstract class EmployeeDAO extends EntityDAO<Employee> {
  ///
  /// Get the [Employee] object that matching the given [id].
  ///
  Stream<Employee> getCurrentEmployeeStream(String id);

  ///
  /// Check the current [Employee] with give [id] has data in the database.
  /// if login is valid, will return the [Result] with data from the data base.
  /// else -> will return null
  ///
  Future<Result<Employee>> checkValidityOfLogin(String id, String email);

  ///
  /// Adds new [Employee] to system. if [toAddTo] is not null, will add the4 given new employee to the given project
  ///
  Future<String> registerEmployee(
      {@required Employee newEmployee, @required Project toAddTo});

  ///
  /// Adds new [Employee] to system. if [toAddTo] is not null, will add the4 given new employee to the given project
  ///
  Future<String> deleteEmployee({
    @required Employee toDelete,
  });

  ///
  /// for testing purposes - deletes all [Employee] with the given [emailsToDelete]
  ///
  Future<String> deleteEmployeesByEmails({
    @required List<String> emailsToDelete,
  });
}

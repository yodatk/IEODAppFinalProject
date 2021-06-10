import 'Employee.dart';

abstract class Editable {
  void setLastEditor(EmployeeForDocs newEmployee);

  void updateLastModified();

  bool isNew();
}

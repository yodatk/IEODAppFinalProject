import '../logger.dart' as Logger;
import '../models/Employee.dart';
import '../models/editable.dart';
import '../models/entity.dart';
import 'EmployeeHandler.dart';

///
/// Updates modified time and any other field needed every time when the given [Entity] is updated
///
class EntityUpdater {
  ///
  /// Updating the last editor of the [Entity] which must implement [Editable]
  ///
  Future<void> updateEditorAndModifiedTime(Editable entity) async {
    final currentUser = EmployeeHandler().readCurrentEmployee();
    if (currentUser != null) {
      entity.setLastEditor(EmployeeForDocs(currentUser.name, currentUser.id));
      entity.updateLastModified();
    } else {
      Logger.error("Unexpected: couldn't retrieve retrieve current Employee");
    }
  }

  void updateEntityModifiedTime(Entity e) {
    e.timeModified = DateTime.now();
  }
}

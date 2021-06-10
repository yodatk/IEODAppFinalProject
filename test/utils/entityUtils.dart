import 'package:IEODApp/models/entity.dart';
import 'package:test/test.dart';
import 'package:IEODApp/constants/constants.dart' as Constants;

void compareTwoEntities(Entity a, Entity b) {
  expect(a.id, b.id);
  expect(a.timeModified, b.timeModified);
  expect(a.timeCreated, b.timeCreated);
}

void toJsonEntityCheck(Map<String, dynamic> json, Entity toCheck) {
  expect(json[Constants.ENTITY_MODIFIED],
      toCheck.timeModified.millisecondsSinceEpoch);
  expect(json[Constants.ENTITY_CREATED],
      toCheck.timeCreated.millisecondsSinceEpoch);
}

void fromJsonEntityCheck(Map<String, dynamic> json, Entity toCheck) {
  expect(toCheck.timeModified.millisecondsSinceEpoch,
      json[Constants.ENTITY_MODIFIED]);
  expect(toCheck.timeCreated.millisecondsSinceEpoch,
      json[Constants.ENTITY_CREATED]);
}

Map<String, dynamic> toJsonEntity() {
  final now = DateTime.now();
  return {
    Constants.ENTITY_CREATED: now.millisecondsSinceEpoch,
    Constants.ENTITY_MODIFIED: now.millisecondsSinceEpoch,
  };
}

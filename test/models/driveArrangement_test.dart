import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/arrangementUtils.dart';
import '../utils/employeeUtils.dart';
import '../utils/entityUtils.dart';

void main() {
  runDriveArrangementTests();
}

void runDriveArrangementTests() {
  group('DriveArrangement test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomDriveArrangement();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.lastEditor.toJson(), json[Constants.DA_LAST_EDITOR]);
      expect(toCheck.date.millisecondsSinceEpoch, json[Constants.DA_DATE]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final now = DateTime.now();
      final json = {
        Constants.DA_DATE: now.millisecondsSinceEpoch,
        Constants.DA_VEHICLES: generateRandomVehicles().map(
            (key, value) => MapEntry<String, dynamic>(key, value.toJson())),
        Constants.DA_LAST_EDITOR: generateLastEditor().toJson(),
        ...toJsonEntity(),
      };
      DriveArrangement toCheck =
          DriveArrangement.fromJson(id: faker.guid.guid(), data: json);
      fromJsonEntityCheck(json, toCheck);
      expect(json[Constants.DA_LAST_EDITOR], toCheck.lastEditor.toJson());
      expect(json[Constants.DA_DATE], toCheck.date.millisecondsSinceEpoch);
    });

    test('clone', () {
      final toCheck = generateRandomDriveArrangement();
      final cloned = toCheck.clone() as Arrangement;
      compareTwoArrangements(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomDriveArrangement();
      final cloned = DriveArrangement.copy(toCheck);
      compareTwoArrangements(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomDriveArrangement();
      expect(toCheck.validateMustFields(), true);
      toCheck.date = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.date = DateTime.now();
      expect(toCheck.validateMustFields(), true);
    });
  });
}

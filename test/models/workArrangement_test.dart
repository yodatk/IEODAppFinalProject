import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/arrangementUtils.dart';
import '../utils/employeeUtils.dart';
import '../utils/entityUtils.dart';

void main() {
  runWorkArrangementTests();
}

void runWorkArrangementTests() {
  group('WorkArrangement test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomWorkArrangement();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.lastEditor.toJson(), json[Constants.WA_LAST_EDITOR]);
      expect(toCheck.date.millisecondsSinceEpoch, json[Constants.WA_DATE]);
      expect(toCheck.freeTextInfo, json[Constants.WA_FREE_TEXT_INFO]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final now = DateTime.now();
      final json = {
        Constants.WA_DATE: now.millisecondsSinceEpoch,
        Constants.WA_FREE_TEXT_INFO: faker.lorem.sentence(),
        Constants.DA_LAST_EDITOR: generateLastEditor().toJson(),
        ...toJsonEntity(),
      };
      WorkArrangement toCheck =
          WorkArrangement.fromJson(id: faker.guid.guid(), data: json);
      fromJsonEntityCheck(json, toCheck);
      expect(json[Constants.WA_LAST_EDITOR], toCheck.lastEditor.toJson());
      expect(json[Constants.WA_DATE], toCheck.date.millisecondsSinceEpoch);
      expect(json[Constants.WA_FREE_TEXT_INFO], toCheck.freeTextInfo);
    });

    test('clone', () {
      final toCheck = generateRandomWorkArrangement();
      final cloned = toCheck.clone() as Arrangement;
      compareTwoArrangements(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomWorkArrangement();
      final cloned = WorkArrangement.copy(toCheck);
      compareTwoArrangements(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomWorkArrangement();
      expect(toCheck.validateMustFields(), true);
      toCheck.date = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.date = DateTime.now();
      toCheck.freeTextInfo = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.freeTextInfo = faker.lorem.sentence();
      expect(toCheck.validateMustFields(), true);
    });
  });
}

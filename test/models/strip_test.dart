import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/entityUtils.dart';
import '../utils/fieldUtils.dart';

void main() {
  runStripTests();
}

void runStripTests() {
  group('Strip test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomStrip();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.plotId, json[Constants.STRIP_PLOT_ID]);
      expect(toCheck.name, json[Constants.STRIP_NAME]);
      expect(toCheck.first?.toJson(), json[Constants.STRIP_FIRST_JOB]);
      expect(toCheck.second?.toJson(), json[Constants.STRIP_SECOND_JOB]);
      expect(toCheck.third?.toJson(), json[Constants.STRIP_THIRD_JOB]);
      expect(toCheck.notes, json[Constants.STRIP_NOTES]);
      expect(toCheck.mineCount, json[Constants.STRIP_MINE_COUNT]);
      expect(toCheck.depthTargetCount, json[Constants.STRIP_DEPTH_COUNT]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final json = {
        Constants.STRIP_PLOT_ID: faker.guid.guid(),
        Constants.STRIP_NAME: faker.company.name(),
        Constants.STRIP_NOTES: faker.lorem.sentence(),
        Constants.STRIP_DEPTH_COUNT: 0,
        Constants.STRIP_MINE_COUNT: 0,
        ...toJsonEntity(),
      };
      Strip toCheck = Strip.fromJson(id: faker.guid.guid(), data: json);
      toJsonEntityCheck(json, toCheck);
      expect(toCheck.plotId, json[Constants.STRIP_PLOT_ID]);
      expect(toCheck.name, json[Constants.STRIP_NAME]);
      expect(toCheck.first?.toJson(), json[Constants.STRIP_FIRST_JOB]);
      expect(toCheck.second?.toJson(), json[Constants.STRIP_THIRD_JOB]);
      expect(toCheck.third?.toJson(), json[Constants.STRIP_THIRD_JOB]);
      expect(toCheck.notes, json[Constants.STRIP_NOTES]);
      expect(toCheck.mineCount, json[Constants.STRIP_MINE_COUNT]);
      expect(toCheck.depthTargetCount, json[Constants.STRIP_DEPTH_COUNT]);
    });

    test('clone', () {
      final toCheck = generateRandomStrip();
      final cloned = toCheck.clone() as Strip;
      compareTwoStrips(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomStrip();
      final cloned = Strip.copy(toCheck);
      compareTwoStrips(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomStrip();
      expect(toCheck.validateMustFields(), true);
      toCheck.plotId = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.plotId = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.plotId = faker.guid.guid();
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = faker.company.name();
      expect(toCheck.validateMustFields(), true);
      toCheck.mineCount = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.mineCount = 0;
      toCheck.depthTargetCount = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.depthTargetCount = 0;
      expect(toCheck.validateMustFields(), true);
    });
  });
}

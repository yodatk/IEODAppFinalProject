import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/entityUtils.dart';
import '../utils/fieldUtils.dart';

void main() {
  runSiteTests();
}

void runSiteTests() {
  group('Plot test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomSite();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.name, json[Constants.SITE_NAME]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final json = {
        Constants.SITE_NAME: faker.company.name(),
        ...toJsonEntity(),
      };
      Site toCheck = Site.fromJson(id: faker.guid.guid(), data: json);
      fromJsonEntityCheck(json, toCheck);
      expect(json[Constants.PLOT_NAME], toCheck.name);
    });

    test('clone', () {
      final toCheck = generateRandomSite();
      final cloned = toCheck.clone() as Site;
      compareTwoSites(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomSite();
      final cloned = Site.copy(toCheck);
      compareTwoSites(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomPlot();
      expect(toCheck.validateMustFields(), true);
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = faker.company.name();
      expect(toCheck.validateMustFields(), true);
    });
  });
}

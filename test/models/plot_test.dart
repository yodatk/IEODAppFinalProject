import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/entityUtils.dart';
import '../utils/fieldUtils.dart';

void main() {
  runPlotTests();
}

void runPlotTests() {
  group('Plot test', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomPlot();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(toCheck.siteId, json[Constants.PLOT_SITE_ID]);
      expect(toCheck.name, json[Constants.PLOT_NAME]);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final json = {
        Constants.PLOT_SITE_ID: faker.guid.guid(),
        Constants.PLOT_NAME: faker.company.name(),
        ...toJsonEntity(),
      };
      Plot toCheck = Plot.fromJson(id: faker.guid.guid(), data: json);
      fromJsonEntityCheck(json, toCheck);
      expect(json[Constants.PLOT_SITE_ID], toCheck.siteId);
      expect(json[Constants.PLOT_NAME], toCheck.name);
    });

    test('clone', () {
      final toCheck = generateRandomPlot();
      final cloned = toCheck.clone() as Plot;
      compareTwoPlot(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomPlot();
      final cloned = Plot.copy(toCheck);
      compareTwoPlot(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomPlot();
      expect(toCheck.validateMustFields(), true);
      toCheck.siteId = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.siteId = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.siteId = faker.guid.guid();
      toCheck.name = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.name = "";
      expect(toCheck.validateMustFields(), false);
      toCheck.name = faker.company.name();
      expect(toCheck.validateMustFields(), true);
    });
  });
}

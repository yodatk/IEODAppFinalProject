import 'package:IEODApp/constants/constants.dart' as Constants;
import 'package:IEODApp/models/all_models.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import '../utils/entityUtils.dart';
import '../utils/imageFolderUtils.dart';

void main() {
  runImageFolderTests();
}

void runImageFolderTests() {
  group('ImageFolder tests', () {
    /// checks all fields of to json results
    test('toJson', () {
      final toCheck = generateRandomImageFolder();
      final json = toCheck.toJson();
      fromJsonEntityCheck(json, toCheck);
      expect(
          toCheck.date.millisecondsSinceEpoch, json[Constants.MAP_FOLDER_DATE]);
      expect(toCheck.numberOfImages, 0);
    });

    /// checks that the object is created properly from valid dictionary
    test('fromJson', () {
      final now = DateTime.now();
      final json = {
        Constants.MAP_FOLDER_DATE: now.millisecondsSinceEpoch,
        Constants.MAP_FOLDER_NUM_OF_IMAGES: 0,
        Constants.MAP_FOLDER_REFERENCES: [
          generateRandomImageReferencePath(),
          generateRandomImageReferencePath(),
        ],
        ...toJsonEntity(),
      };
      ImageFolder toCheck =
          ImageFolder.fromJson(id: faker.guid.guid(), data: json);
      fromJsonEntityCheck(json, toCheck);
      expect(
          toCheck.date.millisecondsSinceEpoch, json[Constants.MAP_FOLDER_DATE]);
      expect(toCheck.numberOfImages, json[Constants.MAP_FOLDER_NUM_OF_IMAGES]);
    });

    test('clone', () {
      final toCheck = generateRandomImageFolder();
      final cloned = toCheck.clone() as ImageFolder;
      compareTwoImageFolders(toCheck, cloned);
    });

    test('copy', () {
      final toCheck = generateRandomImageFolder();
      final cloned = ImageFolder.copy(toCheck);
      compareTwoImageFolders(toCheck, cloned);
    });

    test('validateMustFields', () {
      final toCheck = generateRandomImageFolder();
      expect(toCheck.validateMustFields(), true);
      toCheck.date = null;
      expect(toCheck.validateMustFields(), false);
      toCheck.date = DateTime.now();
      expect(toCheck.validateMustFields(), true);
    });
  });
}

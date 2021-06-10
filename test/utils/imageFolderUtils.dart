import 'dart:math';

import 'package:IEODApp/models/all_models.dart';
import 'package:IEODApp/models/image_folder.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'entityUtils.dart';

final rnd = Random();

String generateRandomImageReferencePath() => faker.lorem.word();

ImageFolder generateRandomImageFolder() {
  return ImageFolder(
    id: faker.guid.guid(),
    date: DateTime.now(),
    numberOfImages: 0,
  );
}

void compareTwoImageFolders(ImageFolder a, ImageFolder b) {
  expect(a.date, b.date);
  compareTwoEntities(a, b);
}

import 'dart:math';

import 'package:IEODApp/logic/initializer.dart';
import 'package:flutter_test/flutter_test.dart';
void runTest(void Function() toRun) {
  Initializer().init(null, isTest: true).then((value) {
    if (value) {
      Future.delayed(Duration(seconds: 2)).then((value) => toRun());
    } else {
      fail("init failed");
    }
  });
}


String randomPhoneNumber() {
  final rnd = Random();
  String output = "054";
  for (int i = 0; i < 7; i++) {
    output += rnd.nextInt(10).toString();
  }
  return output;
}


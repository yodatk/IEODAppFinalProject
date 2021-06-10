import 'package:flutter/material.dart';

import '../logger.dart' as Logger;

///
/// function to print the given [error] and [stack] trace, to be printed in the log, and show an error widget.
///
Widget printAndShowErrorWidget(error, stack) {
  Logger.errorList([
    "Unexpected Error",
    error.toString(),
    stack.toString(),
  ]);
  return Center(
    child: Column(
      children: [
        const Text("אירעה שגיאה"),
        const CircularProgressIndicator(),
      ],
    ),
  );
}

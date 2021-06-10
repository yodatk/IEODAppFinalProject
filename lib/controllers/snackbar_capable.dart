import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../constants/style_constants.dart' as StyleConstants;
import '../logger.dart' as Logger;

///
/// Interface class for all classes that needs to show snackbarMessage after submitting a form
///
class SnackBarCapable {
  ///
  /// showing proper snackbar on screen according to given [msg]: if [msg] is empty -> showing the message written in [successMessage] otherwise, showing the given [msg]
  /// [ctx] is context object for showing snack bar in the right place and time.
  ///
  void showMessageOnSnackBar({
    String msg = "",
    String successMessage = "המשימה בוצעה בהצלחה",
    @required GlobalKey<ScaffoldState> key,
  }) {
    if (msg == null || successMessage == null) {
      return;
    }
    final snackBarToShow = SnackBar(
      duration: Duration(milliseconds: 1500),
      backgroundColor:
          msg == "" ? StyleConstants.accentColor : StyleConstants.errorColor,
      content: Text(
        msg == "" ? successMessage : msg,
        textAlign: TextAlign.right,
      ),
    );

    if (key == null || key.currentState == null) {
      Logger.error("CANNOT SHOW SNACKBAR");
    } else {
      key.currentState.hideCurrentSnackBar();
      key.currentState.showSnackBar(snackBarToShow);
    }
  }
}

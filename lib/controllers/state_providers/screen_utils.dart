import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../snackbar_capable.dart';

class ScreenUtilsController with SnackBarCapable {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void showOnSnackBar({
    @required String msg,
    String successMsg: "המשימה בוצעה בהצלחה",
  }) {
    this.showMessageOnSnackBar(
        key: this._scaffoldKey, msg: msg, successMessage: successMsg);
  }
}

class ScreenUtilsControllerForList<T> extends ScreenUtilsController {
  final ValueNotifier<T> query;
  final String editSuccessMessage;
  final String deleteSuccessMessage;

  ScreenUtilsControllerForList({
    @required this.query,
    @required this.editSuccessMessage,
    @required this.deleteSuccessMessage,
  });

  void handleEditResult(EditResult result) {
    if (result != null) {
      this.showOnSnackBar(
        msg: result.msg,
        successMsg: result.isDelete ? deleteSuccessMessage : editSuccessMessage,
      );
    }
  }
}

class EditResult {
  final String msg;
  final bool isDelete;

  EditResult(this.msg, this.isDelete);
}

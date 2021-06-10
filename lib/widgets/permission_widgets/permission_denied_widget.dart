import 'package:flutter/material.dart';

///
/// [Widget] to show in the middle when the current user does not have the [Permission] to enter a specific screen
///
class PermissionDeniedWidget extends StatelessWidget {
  ///
  /// Message to show if the user was denied because of the [Permission] level
  ///
  static const PERMISSION_DENIED_MSG = "אין לך הרשאה לעמוד זה";

  ///
  /// Message to show if the user was denied because the project it was in was invalid (inactive, or didn't include it)
  ///
  static const INVALID_PROJECT_MSG = "פרויקט זה כבר איננו זמין";

  ///
  /// Message to show in the middle of the [Widget]
  ///
  final String msg;

  PermissionDeniedWidget({this.msg = PERMISSION_DENIED_MSG});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        const Icon(
          Icons.error_outline,
          size: 50,
        ),
        Text(this.msg),
      ],
    ));
  }
}

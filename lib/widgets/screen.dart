import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'navigation/app_drawer.dart';

///
/// Generic Screen to be used in most scenarios in the app.
/// containing an app bar with the default [AppDrawer], and a place for a given widget [body]
/// NOTICE - this widget is a scaffold, there for the [body] widget cannot be a scaffold or bigger.
///
class NormalScreen extends StatelessWidget {
  ///
  /// [Widget] to show in underneath the appBar.
  ///
  final Widget body;

  ///
  /// [title] to show on the app bar
  ///
  final String title;

  ///
  /// Scaffold key to show messages on snackbar, and get the updated context.
  ///
  final GlobalKey<ScaffoldState> scaffoldKey;

  NormalScreen({
    @required this.body,
    @required this.title,
    @required this.scaffoldKey,
  });

  ///
  /// Constructor for Normal screen without given [scaffoldKey]
  ///
  NormalScreen.withoutKey({@required String title, @required Widget body})
      : this(
            title: title,
            body: body,
            scaffoldKey: new GlobalKey<ScaffoldState>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this.scaffoldKey,
      endDrawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            this.title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: body,
    );
  }
}

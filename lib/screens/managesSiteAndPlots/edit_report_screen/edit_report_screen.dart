import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logger.dart' as Logger;
import '../../../models/permission.dart';
import '../../../models/reports/Report.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../constants/keys.dart' as Keys;
import 'controllers/controllers.dart';

///
/// Edit a chosen [Report]. will use a [OutputBuilder] to build the given report using all of its [Template] bricks
///
class EditReportScreen extends HookWidget {
  ///
  /// Text to show on the submit button
  ///
  static const SUBMIT_TEXT = "שמור";

  ///
  /// Route to navigate this screen
  ///
  static const routeName = '/edit_report';

  ///
  /// Title to show on this screen
  ///
  static const title = 'עריכת דו״ח';

  ///
  /// Message to show when a report is successfully edited
  ///
  static const successMessageOnSubmit = 'דו״ח נערך בהצלחה';

  ///
  /// Message to show when a report is successfully deleted
  ///
  static const successMessageOnDelete = 'דו״ח נמחק בהצלחה';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editReportViewModel);
    final reportFuture =
        (ModalRoute.of(context).settings.arguments as Future<Report>);
    return PermissionScreenWithAppBar(
      title: title,
      permissionLevel: Permission.MANAGER,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: FutureBuilder<Report>(
        future: reportFuture,
        builder: (constext, snapshot) {
          if (snapshot.hasError) {
            Logger.error(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final report = snapshot.data;
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Card(
                              margin: const EdgeInsets.all(20),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: viewModel.buildForm(context, report),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                    key: Key(Keys.SUBMIT_REPORT_BTN),
                                    color: Theme.of(context).accentColor,
                                    child: const Text(
                                      EditReportScreen.SUBMIT_TEXT,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    shape: StadiumBorder(),
                                    onPressed: () {
                                      if (viewModel.formKey.currentState
                                          .saveAndValidate())
                                        viewModel.submit(context, report);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants/constants.dart' as Constants;
import '../controllers/snackbar_capable.dart';
import '../logic/ProjectHandler.dart';
import '../logic/reportHandler.dart';
import '../models/reports/builders/PDFBuilder.dart';
import '../models/reports/templates/Template.dart';

///
/// FOR EXPERIMENTING ONLY -> NOT FOR PRODUCTION USE
///
class DebugScreen3 extends StatefulWidget {
  static const SUBMIT_TEXT = "Submit";

  static const routeName = "/debug3";
  static const title = "debug3";
  final ReportHandler reportHandler = ReportHandler();

  void submit(
      {BuildContext context,
      Map<String, dynamic> attributeMap,
      Template template}) {
    reportHandler
        .retrieveReportData(ProjectHandler().getCurrentProjectId(), "test")
        .then((report) {
      print(report.toJson());
      print(report.template.toJson());
      PDFBuilder().visit(report);
    });
  }

  @override
  _DebugScreenState3 createState() => _DebugScreenState3();
}

class _DebugScreenState3 extends State<DebugScreen3> with SnackBarCapable {
  void _trySubmit(BuildContext context) {
    widget.submit(context: context);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider logo = AssetImage(Constants.LOGO_IEOD_ASSET);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Image(
                    image: logo,
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: const Text(DebugScreen3.SUBMIT_TEXT),
                            onPressed: () {
                              _trySubmit(context);
                            }),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DebugScreen3());
}

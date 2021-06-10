import 'package:IEODApp/models/reports/Report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants/ExampleTemplates.dart' as Templates;
import '../constants/constants.dart' as Constants;
import '../controllers/snackbar_capable.dart';
import '../logic/reportHandler.dart';
import '../models/reports/templates/Template.dart';

///
/// FOR EXPERIMENTING ONLY -> NOT FOR PRODUCTION USE
///
class DebugScreen2 extends StatefulWidget {
  static const SUBMIT_TEXT = "Submit";

  static const routeName = "/debug2";
  static const title = "debug2";
  final ReportHandler reportHandler = ReportHandler();

  void submit(
      {BuildContext context,
      Map<String, dynamic> attributeMap,
      Template template}) {
    Report report = Report(
        id: "test2",
        name: template.name,
        attributeValues: attributeMap,
        template: template);
    print(report.toJson());
    reportHandler.uploadTemplate(template);
    reportHandler.uploadUpdateReport(Constants.TEST_PROJECT, report);
  }

  @override
  _DebugScreenState2 createState() => _DebugScreenState2();
}

class _DebugScreenState2 extends State<DebugScreen2> with SnackBarCapable {
  final Map<String, dynamic> attributeMap = {"test": "test value"};

  Template mech = Templates.buildMechTemplate();

  void _trySubmit(BuildContext context) {
    widget.submit(attributeMap: attributeMap, context: context, template: mech);
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
                            child: const Text(DebugScreen2.SUBMIT_TEXT),
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

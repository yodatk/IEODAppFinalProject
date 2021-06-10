import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../constants/ExampleTemplates.dart' as Templates;
import '../constants/constants.dart' as Constants;
import '../controllers/snackbar_capable.dart';
import '../logic/ProjectHandler.dart';
import '../logic/reportHandler.dart';
import '../models/reports/Report.dart';
import '../models/reports/builders/widgetFormBuilder.dart';
import '../models/reports/templates/Template.dart';

///
/// FOR EXPERIMENTING ONLY -> NOT FOR PRODUCTION USE
///
class DebugScreen extends StatefulWidget {
  static const SUBMIT_TEXT = "Submit";

  static const routeName = "/debug";
  static const title = "debug";
  final ReportHandler reportHandler = ReportHandler();

  void submit(
      {BuildContext context,
      Map<String, dynamic> attributeMap,
      Template template}) {
    Report report = Report(
        id: DateTime.now().toIso8601String(),
        name: template.name,
        attributeValues: attributeMap,
        template: template);
    print(report.toJson());
    print(reportHandler.uploadTemplate(template));
    print(reportHandler.uploadUpdateReport(
        ProjectHandler().getCurrentProjectId(), report));
  }

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> with SnackBarCapable {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<String, dynamic> attributeMap = new Map();

  Template mech = Templates.buildMechTemplate();
  Template qual = Templates.buildQualControl();

  void _trySubmit(BuildContext context) {
    widget.submit(attributeMap: attributeMap, context: context, template: qual);
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
                      Card(
                        margin: EdgeInsets.all(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildForm(context),
                        ),
                      ),
                      Center(
                        child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: const Text(DebugScreen.SUBMIT_TEXT),
                            onPressed: () {
                              if (_formKey.currentState.saveAndValidate()) {
                                _trySubmit(context);
                              }
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

  Widget buildForm(BuildContext context) {
    WidgetFormBuilder builder = WidgetFormBuilder(_formKey, attributeMap);
    return builder.visit(context, qual);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../models/reports/Report.dart';
import '../../specific_daily_report_screen/controllers/controllers.dart';

///
/// List tile to Represents a given [Report] as Tile
///
class DailyReportListTile extends HookWidget {
  ///
  /// [Report] to show
  ///
  final Report report;

  DailyReportListTile({@required this.report});

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificDailyReportScreenViewModel);
    return Center(
      child: ExpansionTile(
        key: UniqueKey(),
        title: Text(
          report.getTitle(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(report.getSubtitle()),
        children: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  height: 60.0,
                  color: Colors.green,
                  onPressed: () =>
                      viewModel.generateAndShareReport(context, report),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'שתף',
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FlatButton(
                  textColor: Colors.white,
                  height: 60.0,
                  color: Colors.orange,
                  onPressed: () =>
                      viewModel.navigateAndPushEditReport(context, report),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ערוך',
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FlatButton(
                  textColor: Colors.white,
                  height: 60.0,
                  color: Theme.of(context).errorColor,
                  onPressed: () {
                    viewModel.deleteReport(context, report);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'מחק',
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

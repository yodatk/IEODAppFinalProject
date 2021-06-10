import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/plot.dart';
import '../../../../models/reports/Report.dart';
import '../../../../models/reports/templates/Template.dart';
import '../../../../utils/datetime_utils.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';
import 'report_list_tile.dart';

const PLOT_NAME = "plotName";
const TEMPLATE_TYPE = "templateType";

///
/// Main widget of the specific report screen. convert stream of all relevant reports to list of list tile widget.
///
///
class SpecificReportList extends HookWidget {
  ///
  /// the [Plot] that all of the reports belong to. if null - it's not belong to any plot
  ///
  final Plot plot;

  ///
  /// Type of the report in the list
  ///
  final TemplateTypeEnum reportType;

  SpecificReportList(this.reportType, this.plot);

  @override
  Widget build(BuildContext context) {
    final args = ArgsForAllRelevantReportStream(plot.name, reportType);
    final viewModel = useProvider(specificReportScreenViewModel);
    final allReportsStreamValue = useProvider(allRelevantReports(args));
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(width: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: FormBuilderDateTimePicker(
                    name: "date",
                    inputType: InputType.date,
                    onChanged: (value) =>
                        viewModel.screenUtils.query.value = value,
                    decoration: const InputDecoration(
                        labelText: "חיפוש דוחות",
                        hintText: "חיפוש דוחות",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                SizedBox(width: 5),
                ValueListenableBuilder(
                  valueListenable: viewModel.screenUtils.isLoading,
                  child: const CircularProgressIndicator(),
                  builder:
                      (BuildContext context, bool isLoading, Widget child) =>
                          isLoading
                              ? child
                              : RaisedButton(
                                  key: Key(Keys.ADD_REPORT),
                                  onPressed: () =>
                                      viewModel.navigateAndPushCreateReport(
                                          context, reportType),
                                  color: Theme.of(context).accentColor,
                                  shape: CircleBorder(),
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                ),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 10),
            allReportsStreamValue.when(
              data: (allReports) {
                return ValueListenableBuilder<DateTime>(
                  valueListenable: viewModel.screenUtils.query,
                  builder:
                      (BuildContext context, DateTime query, Widget child) {
                    final total = List<Report>.from(allReports);
                    final filteredReports = query == null
                        ? total
                        : total
                            .where((item) =>
                                item.timeCreated != null &&
                                dateToString(item.timeCreated) ==
                                    dateToString(query))
                            .toList();
                    total.sort(
                        (r1, r2) => r2.timeCreated.compareTo(r1.timeCreated));

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: filteredReports.isEmpty
                          ? child
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: filteredReports.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(),
                                    itemBuilder: (context, index) {
                                      return ReportListTile(
                                        report: filteredReports[index],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                  child: Center(
                    child: Text(
                      "לא נמצאו דוחות",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                );
              },
              loading: loadingDataWidget,
              error: printAndShowErrorWidget,
            )
          ],
        ),
      ),
    );
  }
}

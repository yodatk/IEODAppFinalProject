import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../models/reports/templates/Template.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../../../widgets/loading_widget.dart';
import '../../../../../widgets/unexpected_error_widget.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';
import 'daily_report_list_tile.dart';

const PLOT_NAME = "plotName";
const TEMPLATE_TYPE = "templateType";

///
/// List of all [Report] of a given daily [Template] type
///
class SpecificDailyReportList extends HookWidget {
  ///
  /// Report type to show
  ///
  final TemplateTypeEnum reportType;

  SpecificDailyReportList(this.reportType);

  @override
  Widget build(BuildContext context) {
    final args = ArgsForAllDailyReportStream(reportType);
    final viewModel = useProvider(specificDailyReportScreenViewModel);
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
                  builder: (BuildContext context, bool isLoading,
                          Widget child) =>
                      isLoading
                          ? child
                          : RaisedButton(
                              key: Key(Keys.ADD_DAILY_REPORT),
                              onPressed: () =>
                                  viewModel.navigateAndPushCreateReport(
                                      context, reportType),
                              color: Theme.of(context).accentColor,
                              shape: const CircleBorder(),
                              child: const Icon(Icons.add, color: Colors.white),
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
                    final filteredReports = query == null
                        ? allReports
                        : allReports
                            .where((item) =>
                                item.timeCreated != null &&
                                dateToString(item.timeCreated) ==
                                    dateToString(query))
                            .toList();
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
                                      return DailyReportListTile(
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

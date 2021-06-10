import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../logic/EmployeeHandler.dart';
import '../../../../../models/all_models.dart';
import '../../../../../models/arrangement_type.dart';
import '../../../../../models/permission.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../../../widgets/loading_widget.dart';
import '../../../../../widgets/unexpected_error_widget.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';
import 'arrangement_tile.dart';

///
/// Shows all [Arrangement] of a given type as a List
///
class ArrangementList extends HookWidget {
  ///
  /// Type of [Arrangement] to show (Drive or Work)
  ///
  final ArrangementType arrangementType;

  ArrangementList(this.arrangementType);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allArrangementsViewModel);
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final allArrangementsValue =
        useProvider(allArrangementsOfProjectStream(this.arrangementType));
    String searchText, unfoundText;
    if (arrangementType == ArrangementType.DRIVE) {
      searchText = "חיפוש סידורי נסיעה";
      unfoundText = "לא נמצאו סידורי נסיעה";
    } else {
      searchText = "חיפוש סידורי עבודה";
      unfoundText = "לא נמצאו סידורי עבודה";
    }

    List<Widget> withAdd = [
      SizedBox(
        width: 5,
      ),
      ValueListenableBuilder<bool>(
        valueListenable: viewModel.screenUtils.isLoading,
        builder: (BuildContext context, bool isLoading, Widget child) =>
            isLoading
                ? child
                : RaisedButton(
                    key: Key(Keys.ADD_ARRANGEMENT),
                    onPressed: () {
                      viewModel.handleAddPress(context, arrangementType);
                    },
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
        child: const CircularProgressIndicator(),
      ),
      SizedBox(
        width: 5,
      ),
    ];
    final isWithAdd = currentEmployee.isPermissionOk(Permission.MANAGER);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      (isWithAdd ? 0.7 : 0.9),
                  child: FormBuilderDateTimePicker(
                    name: "Search",
                    inputType: InputType.date,
                    initialValue: viewModel.screenUtils.query.value,
                    locale: Localizations.localeOf(context),
                    onChanged: (value) =>
                        viewModel.screenUtils.query.value = value,
                    decoration: InputDecoration(
                        labelText: searchText,
                        hintText: searchText,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                if (isWithAdd) ...withAdd,
              ],
            ),
            allArrangementsValue.when(
                data: (allArrangements) {
                  return ValueListenableBuilder<DateTime>(
                    child: Text(unfoundText,
                        style: Theme.of(context).textTheme.headline6),
                    valueListenable: viewModel.screenUtils.query,
                    builder:
                        (BuildContext context, DateTime query, Widget child) {
                      final filteredArrangements = query == null
                          ? allArrangements
                          : allArrangements
                              .where((element) =>
                                  element.date != null &&
                                  (dateToString(element.date)
                                      .contains(dateToString(query))))
                              .toList();

                      filteredArrangements
                          .sort((d1, d2) => d2.date.compareTo(d1.date));

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: filteredArrangements.isEmpty
                            ? child
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredArrangements.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(),
                                      itemBuilder: (context, index) {
                                        return ArrangementTile(
                                          arrangement:
                                              filteredArrangements[index],
                                          arrangementType: arrangementType,
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                      );
                    },
                  );
                },
                loading: loadingDataWidget,
                error: printAndShowErrorWidget),
          ],
        ),
      ),
    );
  }
}

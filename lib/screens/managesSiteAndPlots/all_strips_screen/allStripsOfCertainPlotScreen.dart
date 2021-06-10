import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/all_models.dart';
import '../../../models/permission.dart';
import '../../../models/plot.dart';
import '../../../widgets/permission_widgets/screen_with_permission.dart';
import '../constants/keys.dart' as Keys;
import 'controllers/controllers.dart';
import 'widgets/status_strip_list_tile.dart';

///
/// Screen to show all [Strip] of a given [Plot]
///
class AllStripsOfSpecificPlotScreen extends HookWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = '/all_strips_of_certain_plot';

  ///
  /// Title of this screen
  ///
  static const title = " כל הסטריפים של חלקה ";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allStripsViewModel);
    final plot = (ModalRoute.of(context).settings.arguments as Plot);
    return PermissionScreen(
      title: title + plot.name,
      permissionLevel: Permission.MANAGER,
      body: Scaffold(
        key: viewModel.screenUtils.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              title + plot.name,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.pie_chart),
              onPressed: () {
                viewModel.showStatistics(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.note_add),
              onPressed: () async {
                await viewModel.generateManualReport();
              },
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        onChanged: (value) =>
                            viewModel.screenUtils.query.value = value,
                        decoration: const InputDecoration(
                            labelText: "חיפוש סטריפים",
                            hintText: "חיפוש סטריפים",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)))),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    ValueListenableBuilder(
                      valueListenable: viewModel.screenUtils.isLoading,
                      child: const CircularProgressIndicator(),
                      builder: (BuildContext context, bool isLoading,
                              Widget child) =>
                          isLoading
                              ? child
                              : RaisedButton(
                                  key: Key("${Keys.ADD_STRIP_BTN}${plot.name}"),
                                  onPressed: () {
                                    viewModel.openAddStripDialog(context, plot);
                                  },
                                  color: Theme.of(context).accentColor,
                                  shape: CircleBorder(),
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                Container(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            // separatorBuilder: (context, index) => Divider(),
                            children: getRelevantStrips(plot),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      withProject: true,
    );
  }

  ///
  /// get all [Strip] lists by their status.
  ///
  List<Widget> getRelevantStrips(Plot plot) {
    final tempList = [
      StatusStripListTile(status: StripStatus.NONE, plot: plot),
      StatusStripListTile(status: StripStatus.IN_FIRST, plot: plot),
      StatusStripListTile(status: StripStatus.FIRST_DONE, plot: plot),
      StatusStripListTile(status: StripStatus.IN_SECOND, plot: plot),
      StatusStripListTile(status: StripStatus.SECOND_DONE, plot: plot),
      StatusStripListTile(status: StripStatus.IN_REVIEW, plot: plot),
      StatusStripListTile(status: StripStatus.FINISHED, plot: plot),
    ];

    return tempList;
  }
}

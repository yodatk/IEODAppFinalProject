import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/snackbar_capable.dart';
import '../../../../models/all_models.dart';
import '../../../../models/plot.dart';
import '../../../../models/site.dart';
import '../controllers/controllers.dart';
import 'plot_list_tile.dart';

///
/// List Tile to show all [Plot] of a given Site
///
class SiteListTile extends HookWidget with SnackBarCapable {
  ///
  /// Site of this tile
  ///
  final Site site;

  ///
  /// List of all plots of this tile
  ///
  final List<Plot> plots;

  ///
  /// current logged in [Employee]
  ///
  final Employee currentUser;

  SiteListTile({
    @required this.site,
    @required this.plots,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    plots.sort((d1, d2) => d1.name.compareTo(d2.name));
    final expanded = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: plots.length,
                separatorBuilder: (context, index) => SizedBox.shrink(),
                itemBuilder: (context, index) {
                  return PlotListTile(
                    plot: plots[index],
                  );
                },
              ),
            ),
          ],
        ));
    return getRightExpansion(
        context, plots, expanded, currentUser.permission == Permission.ADMIN);
  }

  ///
  /// shows/not shows the edit and add [Plot] button
  ///
  Widget getRightExpansion(
      BuildContext context, List<Plot> plots, Widget expanded, bool asAdmin) {
    final viewModel = useProvider(allSitesAndPlotViewModel);
    final plotTitle = Text(
      'חלקות',
      style: Theme.of(context).textTheme.headline6,
    );
    final addPlotButton = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        plotTitle,
        // add plot button
        IconButton(
          key: Key("addPlotBtnIn_${this.site.name}"),
          icon: Icon(Icons.add),
          onPressed: () {
            viewModel.navigateAndPushAddPlot(context, site);
          },
          tooltip: "הוסף חלקה",
        ),
      ],
    );
    List<Widget> finalChildrenList = [
      asAdmin ? addPlotButton : plotTitle,
      const SizedBox(height: 3),
      (plots.isNotEmpty) ? expanded : const Text('כרגע אין חלקות לאתר זה'),
    ];

    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpansionTile(
          key: UniqueKey(),
          title: Text(
            site.toString(),
            style: Theme.of(context).textTheme.headline5,
          ),
          leading: (asAdmin)
              ? IconButton(
                  key: Key("editSite_${site.name}"),
                  icon: Icon(Icons.edit),
                  tooltip: "ערוך אתר",
                  onPressed: () {
                    viewModel.navigateAndPushEditSite(context, site);
                  },
                )
              : null,
          children: finalChildrenList,
        ),
      ],
    ));
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../controllers/snackbar_capable.dart';
import '../../../../models/permission.dart';
import '../../../../models/plot.dart';
import '../../../../widgets/permission_widgets/permission_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// List tile to represent a [Plot]. you can navigate from it to report of that [Plot] or to go to the [Strip] of this [Plot]
///
class PlotListTile extends HookWidget with SnackBarCapable {
  final Plot plot;

  PlotListTile({
    @required this.plot,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allSitesAndPlotViewModel);
    final children = <Widget>[
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              key: Key("manualPlot_${plot.name}"),
              textColor: Colors.white,
              height: 60.0,
              color: Colors.amber,
              onPressed: () {
                viewModel.navigateAndPushHandWorkScreen(context, plot);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      StyleConstants.ICON_HAND_WORK,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'חלקה ידנית',
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            FlatButton(
              key: Key("plotMechReports_${plot.name}"),
              textColor: Colors.white,
              height: 60.0,
              color: Colors.cyan,
              onPressed: () {
                viewModel.navigateAndPushPlotReports(context, plot);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      StyleConstants.ICON_REPORT,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'דוחות החלקה',
                  )
                ],
              ),
            ),
          ],
        ),
      )
    ];
    return Center(
      child: PermissionWidget(
        permissionLevel: Permission.ADMIN,
        withPermission: ExpansionTile(
          key: UniqueKey(),
          title: Text(
            plot.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(plot.getSubs()),
          leading: IconButton(
            key: Key("${Keys.EDIT_PLOT_BTN}${plot.name}"),
            icon: Icon(StyleConstants.ICON_EDIT),
            tooltip: "ערוך חלקה",
            onPressed: () {
              viewModel.navigateAndPushEditPlot(context, plot);
            },
          ),
          children: children,
        ),
        withoutPermission: ExpansionTile(
          key: UniqueKey(),
          title: Text(
            plot.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(plot.getSubs()),
          children: children,
        ),
      ),
    );
  }
}

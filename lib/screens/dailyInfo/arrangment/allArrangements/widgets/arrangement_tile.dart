import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../../models/all_models.dart';
import '../../../../../models/arrangement_type.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../../../widgets/permission_widgets/permission_widget.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Represents a given [Arrangement] as a list tile
///
class ArrangementTile extends HookWidget {
  ///
  /// [Arrangement] to show
  ///
  final Arrangement arrangement;

  ///
  /// Type of the arrangement (Drive or Work)
  ///
  final ArrangementType arrangementType;

  ArrangementTile({@required this.arrangement, @required this.arrangementType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ExpansionTile(
        key: Key(
            "${dateToString(arrangement.date)}_${arrangement.lastEditor.name}"),
        title: Text(
          arrangement.generateTitle(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          arrangement.getSubtitle(),
        ),
        children: <Widget>[
          Center(
              child: PermissionWidget(
            permissionLevel: Permission.MANAGER,
            withPermission: getRightRow(context: context, isViewOnly: false),
            withoutPermission: getRightRow(context: context, isViewOnly: true),
          ))
        ],
      ),
    );
  }

  ///
  /// gets the matching row according to the current user Permission  - only Managers and Admins can add a drive Arrangement
  ///
  Widget getRightRow({
    @required BuildContext context,
    @required bool isViewOnly,
  }) {
    final viewModel = context.read(allArrangementsViewModel);
    final watchIcon = arrangementType == ArrangementType.WORK
        ? StyleConstants.ICON_WORK_ARRANGEMENT
        : StyleConstants.ICON_DRIVE_ARRANGEMENT;

    final children = !isViewOnly
        ? <Widget>[
            FlatButton(
              key: Key(
                  "${Keys.EDIT_CURRENT_ARRANGEMENT}_${dateToString(arrangement.date)}"),
              textColor: Colors.white,
              height: 60.0,
              color: Colors.green,
              onPressed: () {
                viewModel.navigateAndPushEditArrangement(
                    context, arrangement, arrangementType);
              },
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
              key: Key(
                  "${Keys.DELETE_CURRENT_ARRANGEMENT}_${dateToString(arrangement.date)}"),
              textColor: Colors.white,
              height: 60.0,
              color: Theme.of(context).errorColor,
              onPressed: () {
                viewModel.deleteArrangement(
                    context, arrangement, arrangementType);
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
          ]
        : [
            FlatButton(
              key: Key(
                  "${Keys.WATCH_CURRENT_ARRANGEMENT}_${dateToString(arrangement.date)}"),
              textColor: Colors.white,
              height: 60.0,
              color: Colors.amber,
              onPressed: () {
                viewModel.navigateAndPushEditArrangement(
                  context,
                  arrangement,
                  arrangementType,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      watchIcon,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'צפה',
                  ),
                ],
              ),
            )
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

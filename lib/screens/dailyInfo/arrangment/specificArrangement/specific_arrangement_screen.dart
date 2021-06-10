import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../models/arrangement.dart';
import '../../../../models/arrangement_type.dart';
import '../../../../models/drive_arrangement.dart';
import '../../../../models/permission.dart';
import '../../../../models/work_arrangement.dart';
import '../../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../../../../widgets/permission_widgets/permission_widget.dart';
import '../specificArrangement/widgets/drive_arrangment_form.dart';
import '../specificArrangement/widgets/work_arrangment_form.dart';
import 'controllers/controllers.dart';

///
/// Shows a specific Edit Form of [DriveArrangement] or [WorkArrangement]
///
class ArrangementScreen extends HookWidget {
  ///
  /// Route to get to this screen
  ///
  static const routeName = "/arrangement";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificArrangementViewModel);
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    WorkArrangement updateWorkArrangement;
    DriveArrangement updateDriveArrangement;
    String title;
    Arrangement arrangement = arguments['arrangement'] as Arrangement;
    ArrangementType arrangementType = arguments['type'] as ArrangementType;
    Widget withPermissionWid, withoutPermissionWid;
    if (arrangementType == ArrangementType.WORK) {
      updateWorkArrangement = arrangement as WorkArrangement;
      title = Constants.ARRANGEMENT_TYPE_WORK;
      withoutPermissionWid = WorkArrangementForm(
        isEditable: false,
        toEdit: updateWorkArrangement,
      );
      withPermissionWid = WorkArrangementForm(
        isEditable: true,
        toEdit: updateWorkArrangement,
      );
    } else {
      updateDriveArrangement = arrangement as DriveArrangement;
      title = Constants.ARRANGEMENT_TYPE_DRIVE;
      withoutPermissionWid = DriveArrangementForm(
        isEditable: false,
        toEdit: updateDriveArrangement,
      );
      withPermissionWid = DriveArrangementForm(
        isEditable: true,
        toEdit: updateDriveArrangement,
      );
    }
    return PermissionScreenWithAppBar(
      title: title,
      permissionLevel: Permission.REGULAR,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                PermissionWidget(
                  permissionLevel: Permission.MANAGER,
                  withPermission: withPermissionWid,
                  withoutPermission: withoutPermissionWid,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

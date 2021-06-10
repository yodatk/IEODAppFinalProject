import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './controllers/controllers.dart';
import '../../../../constants/constants.dart' as Constants;
import '../../../../models/arrangement_type.dart';
import '../../../../models/permission.dart';
import '../../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'widgets/arrangement_list.dart';

///
/// Shows all the [Arrangement] of a given project (Drive ot Work, according to the given arguments)
///
class AllArrangementsScreen extends HookWidget {
  static const routeName = '/all_arrangements';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allArrangementsViewModel);
    final title = ModalRoute.of(context).settings.arguments as String;
    final arrangementType = title == Constants.WORK_ARRANGEMENT_TITLE
        ? ArrangementType.WORK
        : ArrangementType.DRIVE;
    return PermissionScreenWithAppBar(
      title: title,
      permissionLevel: Permission.REGULAR,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: ArrangementList(arrangementType),
    );
  }
}

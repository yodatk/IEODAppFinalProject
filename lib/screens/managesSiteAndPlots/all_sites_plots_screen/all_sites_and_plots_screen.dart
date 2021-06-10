import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../constants/keys.dart' as Keys;
import 'controllers/controllers.dart';
import 'widgets/sites_list.dart';

///
/// Screen to show all available [Site] and their [Plot]
///
class AllSitesAndPlotsScreen extends HookWidget {
  /// Route to this screen
  static const routeName = '/sites_and_plots_management';

  ///
  /// Title of this screen
  ///
  static const title = "אתרים וחלקות";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allSitesAndPlotViewModel);
    return PermissionScreenWithAppBar(
      permissionLevel: Permission.MANAGER,
      title: title,
      body: SafeArea(
        child: SiteList(
          key: Key(Keys.SITE_LIST_LOCATION),
        ),
      ),
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
    );
  }
}

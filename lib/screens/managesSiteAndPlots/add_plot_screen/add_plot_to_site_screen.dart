import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../models/site.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/add_plot_form.dart';

///
/// Screen to add a new [Site]
///
class AddPlotToSite extends HookWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = '/add_plot_to_site';

  ///
  /// Title of this Screen
  ///
  static const title = 'הוספת חלקה חדשה';

  ///
  /// Message to show when the [Site] was added succesfully
  ///
  static const successMessageOnSubmit = 'החלקה נוספה בהצלחה';

  @override
  Widget build(BuildContext context) {
    Site site = (ModalRoute.of(context).settings.arguments as Site);
    final viewModel = useProvider(addPlotViewModel);
    return PermissionScreenWithAppBar(
      permissionLevel: Permission.ADMIN,
      title: title,
      body: SafeArea(
        child: Center(
          child: AddNewPlotToSiteForm(site),
        ),
      ),
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
    );
  }
}

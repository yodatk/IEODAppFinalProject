import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../models/plot.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/edit_plot_form.dart';

///
/// Screen to edit the [Plot] entity
///
class EditPlotScreen extends HookWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = '/edit_plot';

  ///
  /// Title of this screen
  ///
  static const title = 'עריכת חלקה';

  ///
  /// Message to show when a plot is successfully edited
  ///
  static const successMessageOnSubmit = 'החלקה נערכה בהצלחה';

  ///
  /// Message to show when a plot is successfully deleted
  ///
  static const successMessageOnDelete = 'החלקה נמחקה בהצלחה';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editPlotViewModel);
    Plot plot = (ModalRoute.of(context).settings.arguments as Plot);
    return PermissionScreenWithAppBar(
      permissionLevel: Permission.ADMIN,
      title: title,
      body: SafeArea(
        child: Center(
          child: EditPlotForm(plot),
        ),
      ),
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
    );
  }
}

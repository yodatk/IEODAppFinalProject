import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../models/site.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/edit_site_form.dart';

///
/// Screen to edit a chosen [Site]
///
class EditSiteScreen extends HookWidget {
  static const routeName = '/edit_site';
  static const title = 'עריכת אתר';
  static const successMessageOnSubmit = 'האתר נערך בהצלחה';
  static const successMessageOnDelete = 'האתר נמחק בהצלחה';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editSiteViewModel);
    Site site = (ModalRoute.of(context).settings.arguments as Site);
    return PermissionScreenWithAppBar(
      permissionLevel: Permission.ADMIN,
      title: title,
      body: SafeArea(
        child: Center(
          child: EditSiteForm(site),
        ),
      ),
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
    );
  }
}

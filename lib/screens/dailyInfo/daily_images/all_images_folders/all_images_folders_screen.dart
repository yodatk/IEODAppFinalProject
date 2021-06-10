import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/all_models.dart';
import '../../../../models/permission.dart';
import '../../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/images_folders_list.dart';

///
/// Shows all [ImageFolder] available in the [Project]
///
class AllImagesFoldersScreen extends HookWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = '/all_images_folders';

  ///
  /// Title of this screen
  ///
  static const title = 'תמונות יומיות';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allImagesFoldersViewModel);
    return PermissionScreenWithAppBar(
      title: AllImagesFoldersScreen.title,
      permissionLevel: Permission.REGULAR,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: ImageFolderList(),
    );
  }
}

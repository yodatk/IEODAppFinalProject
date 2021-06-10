import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../logic/EmployeeHandler.dart';
import '../../../../logic/ProjectHandler.dart';
import '../../../../models/image_folder.dart';
import '../../../../models/image_reference.dart';
import '../../../../models/permission.dart';
import '../../../../widgets/permission_widgets/permission_denied_widget.dart';
import '../../../../widgets/permission_widgets/screen_with_permission.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import 'controllers/controllers.dart';
import 'widgets/images_grid.dart';

///
/// Screen to show all images that were taken in a given day (from the [ImageFolder]
///
class SpecificImagesFolderScreen extends StatefulHookWidget {
  ///
  /// Route to this Screen
  ///
  static const routeName = "/specific_folder";

  @override
  _SpecificImagesFolderScreenState createState() =>
      _SpecificImagesFolderScreenState();
}

class _SpecificImagesFolderScreenState
    extends State<SpecificImagesFolderScreen> {
  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final currentProject = useProvider(currentProjectProvider.state);
    final folder = (ModalRoute.of(context).settings.arguments as ImageFolder);
    final viewModel = useProvider(specificFolderScreenViewModel);
    final allImagesStreamValue = useProvider(allImagesOfFolderStream(folder));
    final dateAsString = folder.generateTitle();
    final title = "תמונות מתאריך $dateAsString";
    return !ProjectHandler().projectIsValid(currentProject, currentEmployee)
        ? PermissionDeniedScreen(
            title: title,
            msg: PermissionDeniedWidget.INVALID_PROJECT_MSG,
          )
        : allImagesStreamValue.when(
            data: (images) {
              final allImages = List<ImageReference>.from(images);
              return Scaffold(
                key: viewModel.screenUtils.scaffoldKey,
                appBar: AppBar(title: Text(title), actions: <Widget>[
                  if (currentEmployee != null &&
                      currentEmployee.isPermissionOk(Permission.MANAGER))
                    ValueListenableBuilder<bool>(
                      valueListenable: viewModel.screenUtils.isLoading,
                      child: const Center(
                          child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: const CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ))),
                      builder: (BuildContext context, bool isLoading,
                              Widget child) =>
                          isLoading
                              ? child
                              : IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    viewModel.openAddImageDialog(
                                        context, allImages, folder);
                                  },
                                ),
                    )
                ]),
                body: SafeArea(
                  child: ImagesGrid(allImages, folder),
                ),
              );
            },
            loading: () => const Scaffold(
                  body: const CircularProgressIndicator(),
                ),
            error: (error, stack) {
              final child = printAndShowErrorWidget(error, stack);
              return Scaffold(body: child);
            });
  }
}

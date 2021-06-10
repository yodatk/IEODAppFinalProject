import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../../models/image_folder.dart';
import '../../../../../models/permission.dart';
import '../../../../../widgets/permission_widgets/permission_widget.dart';
import '../controllers/controllers.dart';

///
/// Single [ImageFolderTile] in the ImageFolderList
///
class ImageFolderTile extends HookWidget {
  ///
  /// Current [ImageFolder]
  ///
  final ImageFolder imageFolder;

  ///
  /// List of all available folders in project(to avoid same date on two folders)
  ///
  final List<ImageFolder> allFolders;

  ImageFolderTile({@required this.imageFolder, @required this.allFolders});

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allImagesFoldersViewModel);
    return Center(
      child: ExpansionTile(
        key: UniqueKey(),
        leading: const Icon(Icons.folder),
        title: Text(
          imageFolder.generateTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          this.imageFolder.numberOfImages == 0
              ? "תיקייה ריקה"
              : this.imageFolder.numberOfImages == 1
                  ? "תמונה אחת"
                  : "מספר תמונות: " + "${this.imageFolder.numberOfImages}",
        ),
        children: [
          Center(
            child: PermissionWidget(
              permissionLevel: Permission.MANAGER,
              withPermission: getRightRow(
                context: context,
                isViewOnly: false,
                viewModel: viewModel,
              ),
              withoutPermission: getRightRow(
                context: context,
                isViewOnly: true,
                viewModel: viewModel,
              ),
            ),
          )
        ],
      ),
    );
  }

  ///
  /// Get right row of search bar - only [Employee] with [Permission.MANAGER] and upwards can add an folder
  ///
  Widget getRightRow(
      {@required BuildContext context,
      @required bool isViewOnly,
      @required allImagesFolderViewModel viewModel}) {
    final children = !isViewOnly
        ? <Widget>[
            FlatButton(
              textColor: Colors.white,
              height: 60.0,
              color: Colors.green,
              onPressed: () {
                viewModel.renameFolder(context, imageFolder, allFolders);
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
              textColor: Colors.white,
              height: 60.0,
              color: Colors.amber,
              onPressed: () {
                viewModel.navigateAndPushSpecificFolderScreen(
                    context, this.imageFolder);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      StyleConstants.ICON_DAILY_IMAGES,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'צפה בתמונות',
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            FlatButton(
              textColor: Colors.white,
              height: 60.0,
              color: Theme.of(context).errorColor,
              onPressed: () {
                viewModel.deleteMapFolder(context, this.imageFolder);
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
              textColor: Colors.white,
              height: 60.0,
              color: Colors.amber,
              onPressed: () {
                viewModel.navigateAndPushSpecificFolderScreen(
                    context, this.imageFolder);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      StyleConstants.ICON_DAILY_IMAGES,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'צפה',
                  )
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

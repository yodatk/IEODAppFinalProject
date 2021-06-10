import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../../models/image_folder.dart';
import '../../../../../models/image_reference.dart';
import '../../../../../models/permission.dart';
import '../../../../../widgets/permission_widgets/permission_widget.dart';
import '../../specific_image_screen/specific_image_screen.dart';
import '../controllers/controllers.dart';

///
/// Single tile to show a Single Image from the [ImageFolder] in the image Grid
///
class ImageTile extends HookWidget {
  ///
  /// Image to show
  ///
  final ImageReference image;

  ///
  /// List of all available Images, to avoid naming to images with the same name
  ///
  final List<ImageReference> allImages;

  ///
  /// [ImageFolder] where this Image is belonging to
  ///
  final ImageFolder folder;

  ImageTile(this.image, this.allImages, this.folder);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificFolderScreenViewModel);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              SpecificImageScreen.routeName,
              arguments: image,
            );
          },
          child: Hero(
            tag: image.id,
            child: FadeInImage(
              placeholder: AssetImage(StyleConstants.PLACE_HOLDER_IMAGE),
              image: CachedNetworkImageProvider(image.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: PermissionWidget(
          permissionLevel: Permission.MANAGER,
          withoutPermission: GridTileBar(
            backgroundColor: Colors.white70,
            title: Text(
              image.name,
              textAlign: TextAlign.center,
            ),
          ),
          withPermission: Container(
            color: Colors.white70,
            child: ExpansionTile(
              key: UniqueKey(),
              title: Text(
                image.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      height: 60.0,
                      color: Colors.green,
                      onPressed: () {
                        viewModel.showEditNameOfImageDialog(
                            context, image, allImages, folder);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'ערוך',
                            style: const TextStyle(color: Colors.white),
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
                        viewModel.sharePictureFunction(context, image);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'שתף',
                            style: const TextStyle(color: Colors.white),
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
                        viewModel.showDeleteImageDialog(context, image, folder);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'מחק',
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

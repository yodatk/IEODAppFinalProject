import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../../models/image_folder.dart';
import '../../../../../models/image_reference.dart';
import 'image_tile.dart';

///
/// Shows all images of a given [ImageFolder] as grid
///
class ImagesGrid extends HookWidget {
  ///
  /// All images of a given folder
  ///
  final List<ImageReference> images;

  ///
  /// [ImageFolder] to show images of
  ///
  final ImageFolder folder;

  ImagesGrid(this.images, this.folder);

  @override
  Widget build(BuildContext context) {
    images.sort((a, b) => b.timeModified.compareTo(a.timeModified));
    return images.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: images.length,
            itemBuilder: (ctx, i) => ImageTile(images[i], images, folder),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                ),
                Text(
                  "אין תמונות בתיקייה זו",
                  style: Theme.of(context).textTheme.headline6,
                )
              ],
            ),
          );
  }
}

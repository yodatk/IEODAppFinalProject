import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../models/with_image.dart';

///
/// Screen to show a given Image
///
class SpecificImageScreen extends StatelessWidget {
  ///
  /// Route to show a given Image
  ///
  static const routeName = '/specific_image_screen';

  SpecificImageScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final imageRef = ModalRoute.of(context).settings.arguments as WithImage;
    final provider = (imageRef != null &&
                imageRef.getUrl() != null &&
                imageRef.getUrl().isNotEmpty
            ? CachedNetworkImageProvider(imageRef.getUrl())
            : AssetImage(StyleConstants.EMPLOYEE_PLACE_HOLDER))
        as ImageProvider<Object>;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        body: Hero(
          tag: imageRef.getId(),
          child: PhotoView(
            imageProvider: provider,
            loadingBuilder: (context, progress) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: progress == null
                      ? null
                      : progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes,
                ),
              ),
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 10,
          ),
        ),
      ),
    );
  }
}

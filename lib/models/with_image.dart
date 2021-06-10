import 'entity.dart';

///
/// Define an [Entity] that contain an image
///
abstract class WithImage {
  ///
  /// Gets the url of the entity image
  ///
  String getUrl();

  ///
  /// Returns 'true' if this [Entity]  has an image, 'false' otherwise
  ///
  bool isWithImage();

  ///
  /// Gets the id of this [Entity]
  ///
  String getId();

  ///
  /// Gets the path of the image in the storage service of this [Entity]
  ///
  String getPath();
}

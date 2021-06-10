import 'package:flutter/foundation.dart';

import '../../../models/image_folder.dart';
import '../../../models/image_reference.dart';
import 'entity_dao.dart';

///
/// Specific DAO for the [ImageFolder] entity
///
abstract class ImageFolderDAO extends EntityDAO<ImageFolder> {
  ///
  /// Updates the given [imageRefs] in the give [imageFolder]
  ///
  Future<String> updateReferences({
    @required ImageFolder imageFolder,
    @required Map<String, ImageReference> imageRefs,
    @required String currentProjectId,
  });

  ///
  /// Adds [imageRefs] to the given [imageFolder]
  ///
  Future<String> addReferences({
    @required ImageFolder imageFolder,
    @required Map<String, ImageReference> imageRefs,
    @required String currentProjectId,
  });

  ///
  /// Deletes a given [ImageReference] to delete
  ///
  Future<String> deleteImage({
    @required ImageFolder imageFolder,
    @required ImageReference toDelete,
    @required String currentProjectId,
  });

  ///
  /// Gets All [ImageReference] of a given folder
  ///
  Stream<List<ImageReference>> allImageReferencesFromFolderAsStream(
      {@required String currentProjectId, @required String id});

  ///
  /// Gets number of all Images in a [ImageFolder] with the given id
  ///
  Stream<int> getFolderImageCountAsStream({String currentProjectId, String id});

  ///
  /// Gets all images from a [ImageFolder] with the given [id] as list
  ///
  Future<List<ImageReference>> allImageReferencesFromFolderAsList(
      {@required String currentProjectId, @required String id});
}

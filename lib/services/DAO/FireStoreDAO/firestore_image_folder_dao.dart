import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../models/image_folder.dart';
import '../../../models/image_reference.dart';
import '../interfacesDAO/image_folder_dao.dart';
import 'firestore_entity_dao.dart';

///
/// Implementation of [ImageFolder] DAO with Firestore
///
class FireStoreImageFolderDAO extends FireStoreEntityDAO<ImageFolder>
    implements ImageFolderDAO {
  FireStoreImageFolderDAO()
      : super(
            collectionName: Constants.MAP_FOLDER_COLLECTION_NAME,
            fromJson: ({
              @required String id,
              @required Map<String, dynamic> data,
            }) =>
                ImageFolder.fromJson(id: id, data: data));

  ///
  /// Converts [ImageFolder] with image collection reference to proper [ImageFolder] object
  ///
  Future<ImageFolder> imageFolderRefToDoc(
      DocumentReference imageFolderRef) async {
    final DocumentSnapshot imageFolderDoc = await imageFolderRef.get();
    if (imageFolderDoc == null || !imageFolderDoc.exists) {
      return null;
    }
    Map<String, dynamic> imageFolderData = imageFolderDoc.data();
    return fromJson(id: imageFolderRef.id, data: imageFolderData);
  }

  @override
  Future<String> addReferences(
      {@required ImageFolder imageFolder,
      @required Map<String, ImageReference> imageRefs,
      @required String currentProjectId}) async {
    try {
      DocumentReference docRef = getByIdAsDocumentReference(
          currentProject: currentProjectId, id: imageFolder.id);
      final CollectionReference imageCollectionRef =
          docRef.collection(Constants.MAP_FOLDER_IMAGES);
      return await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        try {
          final folderDoc = await transaction.get(docRef);
          for (ImageReference image in imageRefs.values) {
            var imageID =
                image != null && image.id != null && image.id.isNotEmpty
                    ? image.id
                    : null;
            DocumentReference imageRef = imageCollectionRef.doc(imageID);
            await transaction.set(imageRef, image.toJson());
          }
          final currentValue =
              (folderDoc.data()[Constants.MAP_FOLDER_NUM_OF_IMAGES] ?? 0)
                  as int;

          final afterCount = {
            Constants.MAP_FOLDER_NUM_OF_IMAGES:
                (currentValue < 0 ? 0 : currentValue) + imageRefs.length,
            Constants.ENTITY_MODIFIED: DateTime.now().millisecondsSinceEpoch,
          };

          await transaction.update(docRef, afterCount);
          return "";
        } catch (error) {
          Logger.error(error.toString());
          return Constants.FAIL;
        }
      });
    } catch (e) {
      Logger.error(e.toString());
      return Constants.FAIL;
    }
  }

  Future<String> updateReferences({
    @required ImageFolder imageFolder,
    @required Map<String, ImageReference> imageRefs,
    @required String currentProjectId,
  }) async {
    try {
      DocumentReference docRef = getByIdAsDocumentReference(
          currentProject: currentProjectId, id: imageFolder.id);
      final CollectionReference imageCollectionRef =
          docRef.collection(Constants.MAP_FOLDER_IMAGES);
      return await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        try {
          for (ImageReference image in imageRefs.values) {
            var imageID =
                image != null && image.id != null && image.id.isNotEmpty
                    ? image.id
                    : null;
            DocumentReference imageRef = imageCollectionRef.doc(imageID);
            await transaction.set(imageRef, image.toJson());
          }
          return "";
        } catch (error) {
          Logger.error(error.toString());
          return Constants.FAIL;
        }
      });
    } catch (e) {
      Logger.error(e.toString());
      return Constants.FAIL;
    }
  }

  @override
  Future<String> deleteImage(
      {@required ImageFolder imageFolder,
      @required ImageReference toDelete,
      @required String currentProjectId}) async {
    try {
      final folderReference = getByIdAsDocumentReference(
          currentProject: currentProjectId, id: imageFolder.id);

      DocumentReference imageRef = folderReference
          .collection(Constants.MAP_FOLDER_IMAGES)
          .doc(toDelete.id);

      return await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        final folderDoc = await transaction.get(folderReference);
        await transaction.delete(imageRef);

        final currentValue =
            (folderDoc.data()[Constants.MAP_FOLDER_NUM_OF_IMAGES] ?? 1) as int;

        final afterCount = {
          Constants.ENTITY_MODIFIED: DateTime.now().millisecondsSinceEpoch,
          Constants.MAP_FOLDER_NUM_OF_IMAGES:
              (currentValue < 1 ? 1 : currentValue) - 1,
        };
        await transaction.update(folderReference, afterCount);
        return "";
      });
    } catch (e) {
      Logger.error(e.toString());
      return Constants.FAIL;
    }
  }

  @override
  Future<String> deleteWithEntity({
    @required String currentProject,
    @required ImageFolder toDelete,
  }) async {
    try {
      final currentFolderReference = getByIdAsDocumentReference(
          currentProject: currentProject, id: toDelete.id);
      final imagesOfFolderCollection = await currentFolderReference
          .collection(Constants.MAP_FOLDER_IMAGES)
          .get();
      return await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        try {
          for (final image in imagesOfFolderCollection.docs) {
            await transaction.delete(image.reference);
          }
          await transaction.delete(currentFolderReference);
          return "";
        } catch (e) {
          Logger.error(e.toString());
          return Constants.FAIL;
        }
      });
    } catch (error) {
      Logger.error(error.toString());
      return Constants.FAIL;
    }
  }

  Future<List<ImageFolder>> allItemsAsListWithEqualsGivenField({
    @required String projectId,
    @required String field,
    @required dynamic predicate,
  }) async {
    List<DocumentSnapshot> docs = await allItemsAsDocListWithEqualsGivenField(
        field: field, predicate: predicate, projectId: projectId);
    return await docsToImageFolders(docs);
  }

  Future<List<ImageFolder>> docsToImageFolders(
      List<DocumentSnapshot> temp) async {
    return Future.wait(
        temp.map((doc) async => await imageFolderRefToDoc(doc.reference)));
  }

  Future<List<ImageFolder>> allItemsAsList({@required String projectId}) async {
    final List<DocumentSnapshot> docs =
        await this.allItemsAsDocumentSnapshotList(projectId: projectId);
    return await docsToImageFolders(docs);
  }

  Stream<List<ImageFolder>> allItemsAsStream({@required String projectId}) {
    Stream<QuerySnapshot> itemsAsQuerySnapShot =
        allItemsAsQuerySnapShot(projectId: projectId);
    return itemsAsQuerySnapShot
        .asyncMap((snapshot) => docsToImageFolders(snapshot.docs));
  }

  @override
  Stream<List<ImageReference>> allImageReferencesFromFolderAsStream(
      {String currentProjectId, String id}) {
    CollectionReference colRef =
        getByIdAsDocumentReference(currentProject: currentProjectId, id: id)
            .collection(Constants.MAP_FOLDER_IMAGES);
    Stream<QuerySnapshot> imageQuery = colRef.snapshots();
    return imageQuery.map((snapshot) => snapshot.docs
        .map((doc) => ImageReference.fromJson(doc.id, doc.data()))
        .toList());
  }

  @override
  Future<List<ImageReference>> allImageReferencesFromFolderAsList(
      {String currentProjectId, String id}) async {
    final colRef = await getByIdAsDocumentReference(
            currentProject: currentProjectId, id: id)
        .collection(Constants.MAP_FOLDER_IMAGES)
        .get();
    return colRef.docs
        .map((doc) => ImageReference.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<int> getFolderImageCountAsStream(
      {String currentProjectId, String id}) {
    CollectionReference colRef =
        getByIdAsDocumentReference(currentProject: currentProjectId, id: id)
            .collection(Constants.MAP_FOLDER_IMAGES);
    return colRef.snapshots().map((event) => event.docs.length);
  }
}

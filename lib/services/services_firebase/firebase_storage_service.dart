import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../logger.dart' as Logger;
import '../services_interfaces/storage_service.dart';

///
/// Class to handle all data traffic of files from an to FirebaseStorage. implementing [StorageService]
///
class FirebaseStorageService implements StorageService {
  ///
  /// singleton instance of the [FirebaseStorageService]
  ///
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();

  ///
  ///  Public getter for the instance
  ///
  factory FirebaseStorageService() {
    return _instance;
  }

  ///
  /// private constructor
  ///
  FirebaseStorageService._internal();

  ///
  /// delete file in from storage in the given [fullPath]
  ///
  Future<void> deleteFile(String fullPath) async {
    final ref = FirebaseStorage.instance.ref(fullPath);
    await ref.delete();
  }

  ///
  /// Upload given [File] to storage to address in  [fullPath].
  /// Returns the DownloadUrl of the file
  ///
  Future<String> uploadFile(String fullPath, File toUpload) async {
    final ref = FirebaseStorage.instance.ref(fullPath);
    final uploadTask = ref.putFile(toUpload);
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      Logger.info("UploadTask-$fullPath}");
      Logger.info(
          "Progress ${snapshot.bytesTransferred}/${snapshot.totalBytes}");
    }, onError: (error) {
      Logger.error("snapshot:\n${uploadTask.snapshot}.\nerror:\n$error");
    });
    await uploadTask;
    return await ref.getDownloadURL();
  }
}

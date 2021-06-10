import 'dart:io';

///
/// Class to handle all data traffic of files from an to Storage service.
///
abstract class StorageService {
  ///
  /// Deletes file in from storage in the given [fullPath]
  ///
  Future<void> deleteFile(String fullPath);

  ///
  /// Upload given [File] to storage to address in  [fullPath].
  /// Returns the DownloadUrl of the file
  ///
  Future<String> uploadFile(String fullPath, File toUpload);
}

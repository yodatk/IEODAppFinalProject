///
/// Class to represent the interface that needs to be implemented for the DataService. mainly used for configuration tasks
///
abstract class DataService {
  ///
  /// Changing the current dataBase environment for Testing
  ///
  void changeEnvironmentForTesting();

  ///
  /// Changing the current dataBase environment for developing
  ///
  void changeEnvironmentForDevelopment();

  ///
  /// Return 'True' if the database is in test mode. 'false' otherwise
  ///
  bool isTestEnv();

  ///
  /// Generate new Id for New document to upload to server
  ///
  String generateDocId();
}

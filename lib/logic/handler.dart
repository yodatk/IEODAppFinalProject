import 'initializer.dart';

///
/// Interface that includes methods that all logic Handlers must implement
///
abstract class Handler {
  ///
  /// init all [Handler] DAO to Firebase type DAO
  ///
  void initWithFirebase();

  ///
  /// init DAO dependencies
  ///
  void init() {
    switch (Initializer().daoType) {
      case DaoType.FIREBASE:
      default:
        initWithFirebase();
    }
  }

  ///
  /// Function for tests only. to reset the test env to another tests
  ///
  Future<String> resetForTests({String projectId});
}

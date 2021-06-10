import 'package:cloud_firestore/cloud_firestore.dart';

import '../services_interfaces/data_service.dart';

///
/// Name of the 'development' branch in the database root
/// this branch is for development experiment and testing in 'develop' branch
/// before merging to client version
///
const DEVELOPMENT_ENV = 'Development';

///
/// Name of the 'production' branch in the database root.
/// this branch is for the *CLIENT ONLY*
///
const PRODUCTION_ENV = 'Production';

///
/// Name of the 'Test' branch in the database root.
/// This Branch is for the automatic Tests
///
const TEST_ENV = 'Test';

///
/// Handle all the configuration with Firestore daabase. implements [DataService]
///
class FireStoreDataService implements DataService {
  ///
  /// singleton instance of the DataGateway
  ///
  static final FireStoreDataService _instance =
      FireStoreDataService._internal();

  FireStoreDataService._internal();

  ///
  ///  Public getter for the instance
  ///
  factory FireStoreDataService() => _instance;

  ///
  /// current database environment
  ///
  static var environment = DEVELOPMENT_ENV;

  final envs = 'Environments';

  ///
  /// Changing the current dataBase environment to Test Env
  ///
  void changeEnvironmentForTesting() {
    environment = TEST_ENV;
  }

  ///
  /// Changing the current dataBase environment to Development Env
  ///
  void changeEnvironmentForDevelopment() {
    environment = DEVELOPMENT_ENV;
  }

  bool isTestEnv() => environment == TEST_ENV;

  ///
  /// Get Current Environment of Database
  ///
  DocumentReference getRoot() {
    return FirebaseFirestore.instance.collection(envs).doc(environment);
  }

  @override
  String generateDocId() {
    return FirebaseFirestore.instance.collection(envs).doc().id;
  }
}

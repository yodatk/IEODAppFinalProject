import 'package:IEODApp/services/services_firebase/firebase_data_service.dart';

abstract class IntegrationTestSuite {
  Future<void> runTests({Map<String, String> args = null}) async {
    FireStoreDataService().changeEnvironmentForTesting();
  }
}

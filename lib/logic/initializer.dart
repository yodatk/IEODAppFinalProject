import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart' as PathProvider;

import '../constants/constants.dart' as Constants;
import '../constants/style_constants.dart' as StyleConstants;
import '../logger.dart' as Logger;
import '../services/services_firebase/firebase_auth_service.dart';
import '../services/services_firebase/firebase_data_service.dart';
import '../services/services_firebase/firebase_storage_service.dart';
import '../services/services_interfaces/auth_service.dart';
import '../services/services_interfaces/data_service.dart';
import '../services/services_interfaces/storage_service.dart';
import 'EmployeeHandler.dart';
import 'ProjectHandler.dart';
import 'dailyInfoHandler.dart';

///
/// All Types of DAO types available
///
enum DaoType {
  FIREBASE,
}

///
/// In charge of initializing all the logic layer when starting the app
///
class Initializer {
  ///
  /// singleton instance of the Initializer
  ///
  static final Initializer _instance = Initializer._internal();

  ///
  ///  Public getter for the instance
  ///
  factory Initializer() => _instance;

  ///
  /// For DAO Injection in Logic handlers
  ///
  final DaoType daoType = DaoType.FIREBASE;

  ///
  /// Data Service of this app
  ///
  DataService _dataService;

  ///
  /// Authentication Service of this app
  ///
  AuthService _authService;

  ///
  /// Storage Service of this App
  ///
  StorageService _storageService;

  /// private Constructor
  Initializer._internal() {
    this._dataService = FireStoreDataService();
    this._authService = FirebaseAuthService();
    this._storageService = FirebaseStorageService();
  }

  ///
  /// Get The current Storage Service
  ///
  StorageService getStorageService() {
    return this._storageService;
  }

  ///
  /// Initializing all imported data and services
  ///
  Future<bool> init(BuildContext context, {bool isTest = false}) async {
    await Firebase.initializeApp();
    final appDirectory = await PathProvider.getApplicationDocumentsDirectory();
    Hive.init(appDirectory.path);
    if (!isTest) {
      await initializeImages(context);
    } else {
      FireStoreDataService().changeEnvironmentForTesting();
    }
    EmployeeHandler()
        .initEmployeeHandler(this._authService, this._storageService);
    await ProjectHandler().initProjectHandler(this._storageService);
    DailyInfoHandler().initDailyInfoHandler(this._storageService);
    Logger.info("Finish Initializing");
    return true;
  }

  ///
  /// Initializing all images to appear in the app
  ///
  Future<void> initializeImages(BuildContext context) async {
    await precacheImage(
        AssetImage(StyleConstants.ICON_IMAGE_PATH_JPG), context);
    await precacheImage(
        AssetImage(StyleConstants.ICON_IMAGE_PATH_PNG), context);
    await precacheImage(AssetImage(Constants.LOGO_IEOD_ASSET), context);
    await precacheImage(AssetImage(Constants.LOGO_IMAG_ASSET), context);
    await precacheImage(AssetImage(StyleConstants.PLACE_HOLDER_IMAGE), context);
    await precacheImage(
        AssetImage(StyleConstants.EMPLOYEE_PLACE_HOLDER), context);
  }

  ///
  /// return 'true' if currently  the app is in test mode, 'false' otherwise
  ///
  bool isTestEnv() => this._dataService.isTestEnv();
}

///
/// Future Provider of the initialize method
///
final initProvider = FutureProvider.family<bool, BuildContext>(
    (ref, context) => Initializer().init(context));

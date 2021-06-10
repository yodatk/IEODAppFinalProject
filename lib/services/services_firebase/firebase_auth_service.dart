import '../services_interfaces/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../constants/constants.dart' as Constants;
import '../../logic/result.dart';
import '../../logger.dart' as Logger;

///
/// Handle all Authintication use cases with FirebaseAuth. implementing [AuthService]
///
class FirebaseAuthService implements AuthService {
  ///
  /// singleton instance of the DataGateway
  ///
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  ///
  ///  Public getter for the instance
  ///
  factory FirebaseAuthService() {
    return _instance;
  }

  ///
  /// Private Constructor
  ///
  FirebaseAuthService._internal();

  ///
  /// Register user to the app with the given [email] and [password].
  /// if registration is successful, will return the [Employee] Id.
  /// otherwise -> will return [String] with error description.
  ///
  Future<Result<String>> registerEmployee(String email, String password) async {
    FirebaseApp app;
    try {
      app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);

      await app.delete();
      return Result<String>(userCredential.user.uid, "", true);
    } on FirebaseAuthException catch (e) {
      if (app != null) {
        await app.delete();
      }
      if (e.code == 'weak-password') {
        Logger.warning('The password provided is too weak.');
        return Result<String>(null, Constants.WEAK_PASSWORD_MSG, false);
      } else if (e.code == 'email-already-in-use') {
        Logger.warning('The account already exists for that email.');
        return Result<String>(null, Constants.EMPLOYEE_EXISTS_MSG, false);
      }
      return Result<String>(null, Constants.GENERAL_ERROR_MSG, false);
    } catch (error) {
      if (app != null) {
        await app.delete();
      }
      Logger.error("unexpected Error in 'registerUser':\n$error");
      return Result<String>(null, Constants.GENERAL_ERROR_MSG, false);
    }
  }

  ///
  /// Logging in an employee with [email] and [password]
  ///
  Future<Result<String>> loginEmployee({String email, String password}) async {
    try {
      final userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final employeeId = userCred.user.uid;
      return Result<String>(employeeId, "", true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Logger.warning("No user found for that email");
      } else if (e.code == 'wrong-password') {
        Logger.warning("Wrong password");
      }
      return Result<String>(null, Constants.LOGIN_FAILED_MSG, false);
    } catch (error) {
      Logger.error("Error in 'loginEmployee':\n$error");
      return Result<String>(null, Constants.GENERAL_ERROR_MSG, false);
    }
  }

  ///
  /// Get Id of the logged in User
  ///
  Future<String> currentLoggedIn() async {
    if (FirebaseAuth.instance.currentUser == null ||
        FirebaseAuth.instance.currentUser.uid == null) {
      // no user is currently logged in -> returns null
      return null;
    }
    return FirebaseAuth.instance.currentUser.uid;
  }

  ///
  /// Sends reset password link to the given [email] if a user with the given [email] exists
  ///
  Future<String> sendResetPasswordLinkToEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "";
    } catch (error) {
      Logger.warning(error.toString());
      return Constants.GENERAL_ERROR_MSG;
    }
  }

  ///
  /// logging out current user
  ///
  Future<String> logout() async {
    await FirebaseAuth.instance.signOut();
    return "";
  }

  ///
  /// return Stream to whether someone is currently logged in to the app or not
  ///
  Stream<String> isConnected() => FirebaseAuth.instance
      .authStateChanges()
      .map((user) => user != null ? user.uid : null);

  Future<Result<String>> deleteUser(String email) async {
    // todo - connect to firebase functions
    throw UnimplementedError();
  }
}

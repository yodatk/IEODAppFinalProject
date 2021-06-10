import '../../logic/result.dart';

///
/// Class to represents the interface to be implemented by any Auth Service.
/// Mainly used for authenticate users, and handle other authentication use cases
///
abstract class AuthService {
  ///
  /// Register user to the app with the given [email] and [password].
  /// if registration is successful, will return the [Employee] Id.
  /// otherwise -> will return [String] with error description.
  ///
  Future<Result<String>> registerEmployee(String email, String password);

  ///
  /// Logging in an employee with [email] and [password]
  ///
  Future<Result<String>> loginEmployee({String email, String password});

  ///
  /// Get Id of the logged in User
  ///
  Future<String> currentLoggedIn();

  ///
  /// Logging out current user
  ///
  Future<String> logout();

  ///
  /// Sends reset password link to the given [email] if a user with the given [email] exists
  ///
  Future<String> sendResetPasswordLinkToEmail(String email);

  ///
  /// Returns Stream to whether someone is currently logged in to the app or not
  /// Stream is of the current Employee Id
  ///
  Stream<String> isConnected();
}

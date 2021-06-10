///
/// [Exception] to throw when trying to call an function in an invalid state
///
class IllegalCallException implements Exception {
  String cause;

  IllegalCallException(this.cause);
}

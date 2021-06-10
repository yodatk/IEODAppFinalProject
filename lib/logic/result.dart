///
/// Class in charge of communication between the data layer to the logic layer
///
class Result<T extends dynamic> {
  ///
  /// requested Result of type T
  ///
  final T result;
  ///
  /// Additional message if necessary
  ///
  final String msg;
  ///
  /// Determines if the message was successful or not
  ///
  final bool isSuccessful;

  Result(this.result, this.msg, this.isSuccessful);
}

import '../constants/constants.dart' as Constants;

///
/// Class to describe a single action on a [Strip]
///
class StripJob {
  ///
  /// id of the [Employee] that worked on that [StripJob]
  ///
  String employeeId;

  ///
  /// name of the [Employee] that worked on that [StripJob]
  ///
  String employeeName;

  ///
  /// last time this [StripJob] was modified
  ///
  DateTime lastModifiedDate;

  ///
  /// 'true' if is this [StripJob] action is done, 'false' if it's still on works
  ///
  bool isDone;

  StripJob({
    this.employeeId,
    this.employeeName,
    this.lastModifiedDate,
    this.isDone = false,
  });

  @override
  String toString() {
    return "Strip job: $lastModifiedDate";
  }

  ///
  /// Copy constructor for [StripJob]
  ///
  StripJob.copy(StripJob other) {
    this.employeeId = other.employeeId;
    this.lastModifiedDate = other.lastModifiedDate;
    this.employeeName = other.employeeName;
    this.isDone = other.isDone;
  }

  ///
  /// Construct a [StripJob] from a given [id] and Json object [data]
  ///
  StripJob.fromJson(Map<String, dynamic> data) {
    DateTime now = new DateTime.now();
    this.employeeId = data[Constants.STRIP_JOB_EMPLOYEE_ID] as String ?? "";
    this.lastModifiedDate = data[Constants.STRIP_JOB_MODIFIED_DATE] != null
        ? (DateTime.fromMillisecondsSinceEpoch(
                data[Constants.STRIP_JOB_MODIFIED_DATE] as int))
            .toLocal()
        : DateTime(now.year, now.month, now.day).toLocal();
    this.employeeName = data[Constants.STRIP_JOB_EMPLOYEE_NAME] as String ?? "";
    this.isDone = data[Constants.STRIP_JOB_IS_DONE] as bool ?? false;
  }

  ///
  /// Part of 'toJson' function. convert this [StripJob] attributes to Json object
  ///
  Map<String, dynamic> toMap() {
    return {
      Constants.STRIP_JOB_EMPLOYEE_ID: this.employeeId,
      Constants.STRIP_JOB_MODIFIED_DATE:
          this.lastModifiedDate.millisecondsSinceEpoch,
      Constants.STRIP_JOB_EMPLOYEE_NAME: this.employeeName,
      Constants.STRIP_JOB_IS_DONE: this.isDone,
    };
  }

  ///
  /// Converts this [StripJob] to Json object
  ///
  Map<String, dynamic> toJson() {
    return {...toMap()};
  }

  @override
  int get hashCode =>
      (this.employeeId + this.employeeName + this.isDone.toString()).hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is StripJob) {
      return this.isDone == other.isDone &&
          this.employeeName == other.employeeName &&
          this.employeeId == other.employeeId &&
          this.lastModifiedDate == other.lastModifiedDate;
    } else {
      return false;
    }
  }
}

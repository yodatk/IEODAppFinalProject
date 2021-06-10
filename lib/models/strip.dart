import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import './stripStatus.dart';
import '../constants/constants.dart' as Constants;
import '../models/stripJob.dart';
import 'entity.dart';

///
/// [Entity] to describe a hand working Strip in a [Plot]
///
class Strip extends Entity {
  ///
  /// Max name length of a [Strip]
  ///
  static const MAX_STRIP_NAME_LENGTH = 20;

  ///
  /// Name of this [Strip]
  ///
  String name;

  ///
  /// describe the current status of this [Strip]
  ///
  StripStatus currentStatus;

  ///
  /// describe the type of this Strip
  ///
  String type;

  ///
  /// Describe all data for the first action on this [Strip]
  ///
  StripJob first;

  ///
  /// Describe all the data for the second action on this [Strip]
  ///
  StripJob second;

  ///
  /// Describe all the data for the review stage action on this [Strip]
  ///
  StripJob third;

  ///
  /// notes thee were taken on this [Strip]
  ///
  String notes;

  ///
  /// number of mines found in this [Strip]
  ///
  int mineCount;

  ///
  /// number of depth target found in this [Strip]
  ///
  int depthTargetCount;

  ///
  /// id of the [Plot] containing this [Strip]
  ///
  String plotId;

  Strip({
    String id = "",
    this.name,
    this.plotId,
    this.currentStatus = StripStatus.NONE,
    this.type,
    this.first,
    this.second,
    this.third,
    this.notes = "",
    this.mineCount = 0,
    this.depthTargetCount = 0,
  }) : super(id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  @override
  String toString() {
    return "סטריפ: " + "$name";
  }

  ///
  /// Copy Constructor for [Strip]
  ///
  Strip.copy(Strip other) : super.copy(other) {
    this.name = other.name;
    this.plotId = other.plotId;
    this.type = other.type;
    this.currentStatus = other.currentStatus;
    this.notes = other.notes;
    this.mineCount = other.mineCount;
    this.depthTargetCount = other.depthTargetCount;
    this.first = other.first != null ? StripJob.copy(other.first) : null;
    this.second = other.second != null ? StripJob.copy(other.second) : null;
    this.third = other.third != null ? StripJob.copy(other.third) : null;
    this.notes = other.notes;
  }

  ///
  /// Construct a [Strip] object from given [id] and Json object [data]
  ///
  Strip.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.plotId = data[Constants.STRIP_PLOT_ID] as String ?? "";
    this.name = data[Constants.STRIP_NAME] as String ?? "";
    this.plotId = data[Constants.STRIP_PLOT_ID] as String ?? "";
    this.type = data[Constants.STRIP_TYPE] as String ?? "";
    this.notes = data[Constants.STRIP_NOTES] as String ?? "";
    String status = data[Constants.STRIP_STATUS] as String ?? "";
    this.currentStatus = convertStringToStripJobStatus(status);
    if (data[Constants.STRIP_FIRST_JOB] != null) {
      this.first = StripJob.fromJson(
          data[Constants.STRIP_FIRST_JOB] as Map<String, dynamic>);
    } else {
      this.first = null;
    }

    if (data[Constants.STRIP_SECOND_JOB] != null) {
      this.second = StripJob.fromJson(
          data[Constants.STRIP_SECOND_JOB] as Map<String, dynamic>);
    } else {
      this.second = null;
    }

    if (data[Constants.STRIP_THIRD_JOB] != null) {
      this.third = StripJob.fromJson(
          data[Constants.STRIP_THIRD_JOB] as Map<String, dynamic>);
    } else {
      this.third = null;
    }

    this.mineCount = data[Constants.STRIP_MINE_COUNT] as int ?? 0;
    this.depthTargetCount = data[Constants.STRIP_DEPTH_COUNT] as int ?? 0;
  }

  ///
  /// Generate title for this [Strip] to show in a list
  ///
  String getTitle() {
    switch (this.currentStatus) {
      case StripStatus.NONE:
      case StripStatus.FIRST_DONE:
      case StripStatus.SECOND_DONE:
      case StripStatus.FINISHED:
        return this.name;
        break;
      case StripStatus.IN_FIRST:
        return "$name, ${this.first.employeeName}";
        break;
      case StripStatus.IN_SECOND:
        return "$name, ${this.second.employeeName}";
        break;
      case StripStatus.IN_REVIEW:
        return "$name, ${this.third.employeeName}";
        break;
      default:
        return this.name;
        break;
    }
  }

  ///
  /// Generate subtitles for this [Strip] to show on a list
  ///
  String getSubs() {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formatted = formatter.format(this.timeModified);
    final updatedInfo = "עודכן לאחרונה ב$formatted";
    return updatedInfo;
  }

  ///
  /// Convert this [Strip] to Json object
  ///
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// Part of the 'toJson' function. converts all this [Strip] attributes to Json object
  ///
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Constants.STRIP_PLOT_ID: plotId,
      Constants.STRIP_NAME: name,
      Constants.STRIP_TYPE: type,
      Constants.STRIP_STATUS: describeEnum(currentStatus),
      Constants.STRIP_NOTES: notes ?? "",
      Constants.STRIP_MINE_COUNT: mineCount,
      Constants.STRIP_DEPTH_COUNT: depthTargetCount,
      Constants.STRIP_FIRST_JOB:
          this.first != null ? this.first.toJson() : null,
      Constants.STRIP_SECOND_JOB:
          this.second != null ? this.second.toJson() : null,
      Constants.STRIP_THIRD_JOB:
          this.third != null ? this.third.toJson() : null,
    };
    return map;
  }

  @override
  Entity clone() {
    return Strip.copy(this);
  }

  ///
  /// returns True if this strip need to have the [StripStatus.NONE] status
  ///
  bool isNoneStatus() =>
      this.first == null && this.second == null && this.third == null;

  ///
  /// returns True if this strip need to have the [StripStatus.IN_FIRST] status
  ///
  bool isInFirst() =>
      (this.first != null && !this.first.isDone) &&
      this.second == null &&
      this.third == null;

  ///
  /// returns True if this strip need to have the [StripStatus.FIRST_DONE] status
  ///
  bool isFirstDone() =>
      (this.first != null && this.first.isDone) &&
      this.second == null &&
      this.third == null;

  ///
  /// returns True if this strip need to have the [StripStatus.IN_SECOND] status
  ///
  bool isInSecond() =>
      (this.first != null && this.first.isDone) &&
      (this.second != null && !this.second.isDone) &&
      this.third == null;

  ///
  /// returns True if this strip need to have the [StripStatus.SECOND_DONE] status
  ///
  bool isSecondDone() =>
      (this.first != null && this.first.isDone) &&
      (this.second != null && this.second.isDone) &&
      this.third == null;

  ///
  /// returns True if this strip need to have the [StripStatus.IN_REVIEW] status
  ///
  bool isInReview() =>
      (this.first != null && this.first.isDone) &&
      (this.second != null && this.second.isDone) &&
      (this.third != null && !this.third.isDone);

  ///
  /// returns True if this strip need to have the [StripStatus.FINISHED] status
  ///
  bool isFinished() =>
      (this.first != null && this.first.isDone) &&
      (this.second != null && this.second.isDone) &&
      (this.third != null && this.third.isDone);

  ///
  /// Update this [Strip] status according to it's [StripJob] attributes
  ///
  StripStatus updateStripStatus() {
    if (isNoneStatus()) {
      this.currentStatus = StripStatus.NONE;
    } else if (isInFirst()) {
      this.currentStatus = StripStatus.IN_FIRST;
    } else if (isFirstDone()) {
      this.currentStatus = StripStatus.FIRST_DONE;
    } else if (isInSecond()) {
      this.currentStatus = StripStatus.IN_SECOND;
    } else if (isSecondDone()) {
      this.currentStatus = StripStatus.SECOND_DONE;
    } else if (isInReview()) {
      this.currentStatus = StripStatus.IN_REVIEW;
    } else if (isFinished()) {
      this.currentStatus = StripStatus.FINISHED;
    } else {
      this.currentStatus = null;
    }
    return this.currentStatus;
  }

  int compareTo(Strip other) {
    final num1 = int.tryParse(this.name);
    final num2 = int.tryParse(other.name);
    if (num1 != null && num2 != null) {
      return num1 - num2;
    }
    if (num1 == null && num2 == null) {
      return this.name.compareTo(other.name);
    }
    return num1 == null ? 1 : -1;
  }

  @override
  bool validateMustFields() =>
      name != null &&
      name.isNotEmpty &&
      mineCount != null &&
      depthTargetCount != null &&
      plotId != null &&
      plotId.isNotEmpty &&
      this.updateStripStatus() != null;
}

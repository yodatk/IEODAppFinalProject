import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;
import '../utils/datetime_utils.dart';
import 'entity.dart';

///
/// [Entity] to describe folder of map for a given date in the system
///
class ImageFolder extends Entity {
  ///
  /// Date of the Map in the folder
  ///
  DateTime date;

  ///
  /// number of images in the folder
  ///
  int numberOfImages;

  ImageFolder({String id = "", @required this.date, this.numberOfImages = 0})
      : super(
          id: id,
          timeCreated: DateTime.now(),
          timeModified: DateTime.now(),
        ) {
    if (this.date == null) {
      this.date = this.timeCreated;
    }
  }

  ///
  /// Generates [String] title from this [ImageFolder] to show in list
  ///
  String generateTitle() {
    return dateToString(date);
  }

  @override
  String toString() {
    return dateToString(this.date);
  }

  ///
  /// Copy Constructor for [ImageFolder]
  ///
  ImageFolder.copy(ImageFolder other) : super.copy(other) {
    this.date = other.date;
    this.numberOfImages = other.numberOfImages;
  }

  ///
  /// Construct [ImageFolder] from given [id] and Json object [data]
  ///
  ImageFolder.fromJson(
      {@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.date = data[Constants.MAP_FOLDER_DATE] != null
        ? (DateTime.fromMillisecondsSinceEpoch(
                data[Constants.MAP_FOLDER_DATE] as int))
            .toLocal()
        : DateTime.now().toLocal();
    this.numberOfImages = data[Constants.MAP_FOLDER_NUM_OF_IMAGES] as int ?? 0;
  }

  @override
  Entity clone() {
    return ImageFolder.copy(this);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), ...toMap()};
  }

  ///
  /// Part of [toJson]. convert all attributes of this [ImageFolder] to Json object.
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.MAP_FOLDER_DATE: this.date.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      Constants.MAP_FOLDER_NUM_OF_IMAGES: this.numberOfImages ?? 0,
    };
  }

  @override
  bool validateMustFields() =>
      this.date != null &&
      this.numberOfImages != null &&
      this.numberOfImages >= 0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageFolder && this.id == other.id);
  }

  @override
  int get hashCode => this.id.hashCode;
}

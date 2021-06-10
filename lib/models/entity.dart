import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;

///
/// Class represents an object to be saved in database
///
abstract class Entity {
  ///
  /// ID of this [Entity]
  ///
  String id;

  ///
  /// The Time and Date this [Entity] was created
  ///
  DateTime timeCreated;

  ///
  /// The Time and Date this [Entity] was modified
  ///
  DateTime timeModified;

  Entity({this.id, this.timeCreated, this.timeModified}) {
    final now = DateTime.now();
    if (timeCreated == null || this.timeModified == null) {
      this.timeCreated = now;
      this.timeModified = now;
    }
  }

  ///
  /// Set [timeCreated] and [timeModified] time to current [DateTime] now
  ///
  void setTimeToNow() {
    final now = DateTime.now();
    this.timeCreated = now;
    this.timeModified = now;
  }

  ///
  /// Copy Constructor for this [Entity]
  ///
  Entity.copy(Entity other) {
    this.id = other.id;
    this.timeCreated = other.timeCreated;
    this.timeModified = other.timeModified;
  }

  ///
  /// Return deep copy of this [Entity]
  ///
  Entity clone();

  ///
  /// Construct a new [Entity] object from given [id] and json Object [data]
  ///
  Entity.fromJson({@required this.id, @required Map<String, dynamic> data}) {
    this.timeCreated = data[Constants.ENTITY_CREATED] != null
        ? (DateTime.fromMillisecondsSinceEpoch(
                data[Constants.ENTITY_CREATED] as int))
            .toLocal()
        : DateTime.now().toLocal();
    this.timeModified = data[Constants.ENTITY_MODIFIED] != null
        ? (DateTime.fromMillisecondsSinceEpoch(
                data[Constants.ENTITY_MODIFIED] as int))
            .toLocal()
        : DateTime.now().toLocal();
  }

  ///
  /// Converts this [Entity] to Json object
  ///
  Map<String, dynamic> toJson() {
    return {
      Constants.ENTITY_CREATED: this.timeCreated.millisecondsSinceEpoch,
      Constants.ENTITY_MODIFIED: this.timeModified.millisecondsSinceEpoch,
    };
  }

  ///
  /// Convert attributes of this [Entity] to Json object.
  ///
  Map<String, dynamic> toMap();

  ///
  /// Make Sure all necessary  fields are valid in this entity
  ///
  bool validateMustFields();
}

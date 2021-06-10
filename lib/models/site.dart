import 'package:flutter/foundation.dart';

import '../constants/constants.dart' as Constants;
import 'entity.dart';

///
/// [Entity] to describe Site in a de-mining Project
///
class Site extends Entity {
  String name;

  Site({
    String id = "",
    this.name,
  }) : super(id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  @override
  String toString() {
    return name;
  }

  ///
  /// Copy Constructor for [Site]
  ///
  Site.copy(Site other) : super.copy(other) {
    this.name = other.name;
  }

  ///
  /// Construct [Site] object from given [id] and Json object [data]
  ///
  Site.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.SITE_NAME] as String ?? "";
  }

  ///
  /// Converts this [Site] to Json object
  ///
  @override
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// Part of the 'toJson' function . converts this [Site] attributes to Json object.
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.SITE_NAME: this.name,
    };
  }

  ///
  /// Return deep copy of this [Site]
  ///
  @override
  Entity clone() {
    return Site.copy(this);
  }

  @override
  bool validateMustFields() => this.name != null && this.name.isNotEmpty;
}

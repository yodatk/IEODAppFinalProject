import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart' as Constants;
import 'entity.dart';

///
/// [Entity] to describe a Plot that need to be searched for mines(by hand, or by machinery)
///
class Plot extends Entity {
  ///
  /// Name of the plot
  ///
  String name;

  ///
  /// id of the [Site] that contain this [Plot]
  ///
  String siteId;

  Plot({
    String id = "",
    this.name,
    this.siteId,
  }) : super(id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  ///
  /// Specific Constructor for new [Plot]
  ///
  Plot.newPlot({String id = '', this.name, this.siteId})
      : super(
            id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  @override
  String toString() {
    return "חלקה: " + "$name";
  }

  ///
  /// Copy Constructor
  ///
  Plot.copy(Plot other) : super.copy(other) {
    this.name = other.name;
    this.siteId = other.siteId;
  }

  ///
  /// Construct a [Plot] object from
  ///
  Plot.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.PLOT_NAME] as String ?? "";

    this.siteId = data[Constants.PLOT_SITE_ID] as String ?? "";
  }

  ///
  /// Converts this [Plot] to Json object
  ///
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// part of the 'toJson' . convert all [Plot] attributes to Json object
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.PLOT_NAME: name,
      Constants.PLOT_SITE_ID: siteId,
    };
  }

  /// Get secondary data on this plot to be displayed as a list item
  String getSubs() {
    if (this.name == "") {
      return "";
    }

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formatted = formatter.format(this.timeModified);
    final updatedInfo = "עודכן לאחרונה ב$formatted";
    return updatedInfo;
  }

  @override
  Entity clone() {
    return Plot.copy(this);
  }

  @override
  bool validateMustFields() =>
      name != null && name.isNotEmpty && siteId != null && siteId.isNotEmpty;
}

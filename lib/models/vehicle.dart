import 'package:flutter/cupertino.dart';

import '../constants/constants.dart' as Constants;
import 'entity.dart';

///
/// [Entity] to describe a single vehicle from a DriveArrangement
///
class Vehicle extends Entity {
  String model;
  String driver;
  List<dynamic> passengers;
  String destination;

  Vehicle({
    String id = "",
    this.model,
    this.driver,
    this.passengers,
    this.destination = "",
  }) : super(id: id, timeCreated: DateTime.now(), timeModified: DateTime.now());

  @override
  String toString() {
    return '$model: ' + 'נהג: ' + driver + 'נוסעים: ' + '$passengers';
  }

  ///
  /// Copy Constructor for [Vehicle]
  ///
  Vehicle.copy(Vehicle other) : super.copy(other) {
    this.model = other.model;
    this.driver = other.driver;
    this.passengers = [];
    other.passengers.forEach((element) {
      this.passengers.add(element);
    });

    this.destination = other.destination;
  }

  ///
  /// Construct [Vehicle] from given [id] and Json object [data]
  ///
  Vehicle.fromJson({@required String id, @required Map<String, dynamic> data})
      : super.fromJson(id: id, data: data) {
    this.model = data[Constants.VEHICLE_MODEL] as String ?? "";
    this.driver = data[Constants.VEHICLE_DRIVER] as String ?? "";
    this.destination = data[Constants.VEHICLE_DESTINATION] as String ?? "";
    if (data[Constants.VEHICLE_PASSENGERS] == null) {
      this.passengers = [];
    } else {
      this.passengers = data[Constants.VEHICLE_PASSENGERS] as List<dynamic>;
    }
  }

  ///
  /// Convert this [Vehicle] to Json object
  ///
  @override
  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  ///
  /// Part of the 'toJson' function. Convert this [Vehicle] attributes to Json object.
  ///
  @override
  Map<String, dynamic> toMap() {
    return {
      Constants.VEHICLE_MODEL: model,
      Constants.VEHICLE_DRIVER: driver,
      Constants.VEHICLE_PASSENGERS: passengers,
      Constants.VEHICLE_DESTINATION: destination,
    };
  }

  @override
  Entity clone() {
    return Vehicle.copy(this);
  }

  @override
  bool validateMustFields() => true; // todo - check later if necessary

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is Vehicle) {
      if ((other.passengers == null && this.passengers == null) ||
          (other.passengers != null &&
              this.passengers != null &&
              other.passengers.toSet().containsAll(this.passengers.toSet()) &&
              this.passengers.toSet().containsAll(other.passengers.toSet()))) {
        return (other?.destination == this?.destination &&
            other?.driver == this?.driver &&
            other?.model == this?.model &&
            other.passengers.toSet().containsAll(this.passengers));
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  int get hashCode => this.model.hashCode;
}

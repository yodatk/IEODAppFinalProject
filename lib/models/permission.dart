import 'dart:math';

import 'package:flutter/foundation.dart';

///
/// Enum to describe different permission levels available for the [Employee]
///
enum Permission {
  ///
  /// Permission level for Admin, Project mangers, and GIS Employee
  ///
  ADMIN,

  ///
  /// Permission level for Team and subTeam Managers
  ///
  MANAGER,

  ///
  /// All other employees are with this level of permission
  ///
  REGULAR,
}

///
/// converts given [toConvert] to matching [Permission] enum.
/// returns null if none match
///
Permission convertStringToPermission(String toConvert) {
  return Permission.values
      .firstWhere((e) => describeEnum(e) == toConvert, orElse: null);
}

Permission randomPermission() => Permission.values[Random().nextInt(3)];

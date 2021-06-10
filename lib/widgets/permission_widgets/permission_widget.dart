import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../logic/EmployeeHandler.dart';
import '../../models/Employee.dart';
import '../../models/permission.dart';

///
/// [Widget] which showing only if the current given user is with the right permission
///
class PermissionWidget extends HookWidget {
  /// permission level necessary to see the screen
  final Permission permissionLevel;

  /// [Widget] to show if the current user is with the right permission
  final Widget withPermission;

  /// [Widget] to show if the current user is without the right permission
  final Widget withoutPermission;

  PermissionWidget({
    @required this.permissionLevel,
    @required this.withPermission,
    this.withoutPermission,
  });

  /// returns the right [Widget] according the the [Permission] level of the [currentUser]
  Widget stateAccordingToUser(Employee currentUser) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    } else if (currentUser.isPermissionOk(this.permissionLevel)) {
      return this.withPermission; // return the wanted widget
    } else {
      return this.withoutPermission == null
          ? const SizedBox.shrink()
          : this.withoutPermission; // return blank widget
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    return stateAccordingToUser(currentEmployee);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/Employee.dart';
import '../../../../models/permission.dart';
import '../../../../widgets/employee_avatar.dart';
import '../../../../widgets/permission_widgets/permission_widget.dart';
import '../../../dailyInfo/daily_images/specific_image_screen/specific_image_screen.dart';
import '../controllers/controllers.dart';

///
/// Represents a given [Employee] as a list tile
///
class EmployeeListTile extends HookWidget {
  ///
  /// Employee to show
  ///
  final Employee employee;

  EmployeeListTile(this.employee);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allEmployeesViewModel);
    final callButton = this.employee.phoneNumber != null &&
            this.employee.phoneNumber.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              viewModel.tryCallEmployee(this.employee);
            },
          )
        : SizedBox.shrink();
    return Container(
      child: PermissionWidget(
        permissionLevel: Permission.ADMIN,
        withPermission: ListTile(
          key: Key(employee.email),
          title: Text(employee.name),
          subtitle: Text(employee.getSubs()),
          leading: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  key: Key("edit_${employee.email}"),
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    viewModel.navigateAndPushEditUser(context, employee);
                  },
                ),
                Hero(
                  tag: employee.id,
                  child: EmployeeAvatar(
                    employee,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        SpecificImageScreen.routeName,
                        arguments: employee,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          trailing: callButton,
        ),
        withoutPermission: ListTile(
          title: Text(employee.name),
          subtitle: Text(employee.getSubs()),
          trailing: callButton,
          leading: Hero(
            tag: employee.id,
            child: EmployeeAvatar(
              employee,
              onTap: () {
                Navigator.of(context).pushNamed(
                  SpecificImageScreen.routeName,
                  arguments: employee,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

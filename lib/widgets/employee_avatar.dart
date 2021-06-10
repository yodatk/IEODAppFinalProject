import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/style_constants.dart' as StyleConstants;
import '../logger.dart' as Logger;
import '../models/Employee.dart';

///
/// [Widget] to show to profile Pictures of employees
/// if the [Employee] doesnt have an image, will show a place holder.
///
class EmployeeAvatar extends StatelessWidget {
  ///
  /// [Employee] to show Image of
  ///
  final Employee employee;

  ///
  /// function to execute when pressing the image.
  ///
  final void Function() onTap;

  EmployeeAvatar(this.employee, {this.onTap, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: CircleAvatar(
        backgroundImage: employee.isWithImage()
            ? CachedNetworkImageProvider(employee.imageUrl)
                as ImageProvider<Object>
            : AssetImage(StyleConstants.EMPLOYEE_PLACE_HOLDER),
        onBackgroundImageError: (error, stack) {
          Logger.errorList([
            "Unexpected Error:",
            error.toString(),
            stack.toString(),
          ]);
        },
      ),
    );
  }
}

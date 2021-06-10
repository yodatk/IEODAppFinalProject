import 'package:flutter/material.dart';

import '../../models/Employee.dart';

///
/// Wide Button used in major most of the menus in the app. will contain an icon, title, and a route to navigate to when pressed.
/// <<DEPRECATED>> -> using [NavigationRow] instead
///
class NavigationTile extends StatelessWidget {
  ///
  /// Route to navigate to when the [NavigationTile]
  ///
  final String route;

  ///
  /// Title of the navigation bar
  ///
  final String title;

  ///
  /// Color of the navigation bar
  ///
  final Color color;

  ///
  /// Icon to show on Navigation bar
  ///
  final IconData icon;

  ///
  /// Current Logged In [Employee]
  ///
  final Employee currentUser;

  NavigationTile({
    this.route,
    this.title,
    this.color,
    this.icon,
    this.currentUser,
  });

  ///
  /// Navigating the user to the route of this [NavigationTile]
  ///
  void goToPage(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(this.route, arguments: currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => goToPage(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.7),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

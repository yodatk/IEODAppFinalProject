import 'package:flutter/material.dart';

import '../../constants/constants.dart' as Constants;
import '../../models/all_models.dart';

///
/// Wide Button used in major most of the menus in the app. will contain an icon, title, and a route to navigate to when pressed.
///
///
class NavigationRow extends StatelessWidget {
  ///
  /// Unique [Key] of this button to identify(mainly for ui tests)
  ///
  final Key key;

  ///
  /// Route to navigate to when the [NavigationRow]
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
  /// Color of the text on the navigation bar
  ///
  final Color textColor;

  ///
  /// Icon to show on Navigation bar
  ///
  final IconData icon;

  ///
  /// Current Logged In [Employee]
  ///
  final Employee currentUser;

  ///
  /// Arguments to pass to the given [route]
  ///
  final dynamic args;

  NavigationRow({
    this.key,
    this.route,
    this.title,
    this.color,
    this.textColor = Colors.black,
    Employee currentUser,
    this.icon,
    dynamic args,
  })  : this.currentUser = currentUser,
        this.args = args ?? {Constants.CURRENT_USER: currentUser};

  ///
  /// Navigating the user to the route of this [NavigationRow]
  ///
  void goToPage(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(this.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.7),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: icon != null
            ? new LayoutBuilder(builder: (context, constraint) {
                return new Icon(
                  icon,
                  size: constraint.biggest.height,
                  color: textColor,
                );
              })
            : Container(),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor,
              fontSize: 26), //Theme.of(context).textTheme.headline5,
        ),
        onTap: () => goToPage(context),
      ),
    );
  }
}

library general_utils;

import 'package:IEODApp/constants/general_keys.dart' as GeneralKeys;
import 'package:IEODApp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/screens/constants/keys.dart' as MainScreensKeys;

///
/// Tooltip of the back button
///
const BACK = "הקודם";

///
/// Tooltip of the  main AppDrawer
///
const APP_DRAWER = 'פתיחה של תפריט הניווט';

///
/// key of the logout button in the app Drawer
///
const LOGOUT = 'signOut';

///
/// Employees Screen button key from the main menu
///
final Finder employeesPageNavigator =
    find.byKey(Key(MainScreensKeys.EMPLOYEES_SCREEN));

///
/// Plots and Sites Screen button key from the main menu
///
final Finder plotsAndSitesPageNavigator =
    find.byKey(Key(MainScreensKeys.PLOT_AND_SITE_SCREEN));

///
/// Daily info screen button key from the main menu
///
final Finder dailyInfoScreenPageNavigator =
    find.byKey(Key(MainScreensKeys.DAILY_INFO_SCREEN));

///
/// Use tester to go back
///
Future<void> pageBack(WidgetTester tester) async {
  return TestAsyncUtils.guard<void>(() async {
    Finder backButton = find.byTooltip(BACK);
    if (backButton.evaluate().isEmpty) {
      backButton = find.byType(CupertinoNavigationBarBackButton);
    }

    expectSync(backButton, findsOneWidget,
        reason: 'One back button expected on screen');

    await tester.tap(backButton);
    await tester.pumpAndSettle();
  });
}

///
/// Use [tester] to go back all the way to the homepage
///
Future<void> goToHomePage(WidgetTester tester) async {
  await tester.runAsync(() async {
    Finder navToolBarBtn;
    while (navToolBarBtn == null || navToolBarBtn.evaluate().isEmpty) {
      navToolBarBtn = find.byTooltip(APP_DRAWER);

      if (navToolBarBtn.evaluate().isEmpty) {
        await pageBack(tester);
        await tester.pumpAndSettle();
      }
    }
    await tester.pumpAndSettle();
  });
}

///
/// Use [tester] to logout
///
Future<void> logout(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpAndSettle();
    final Finder navToolBarBtn = find.byTooltip(APP_DRAWER);
    await tester.pumpAndSettle();
    await tester.tap(navToolBarBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key(LOGOUT)));
    await tester.pumpAndSettle();
  });
}

///
/// Use [tester] to go from any page to homepage, and logout
///
Future<void> logoutFromAnyPage(WidgetTester tester) async {
  await goToHomePage(tester);
  await tester.pumpAndSettle();
  await logout(tester);
  await tester.pumpAndSettle();
}

///
/// Returns the main widget to build the app for the current test
///
Widget getMainWidget() => MyApp();

///
/// Use [tester] to get into employee management page from home screen
///
Future<void> enterEmployeeManagementPageFromProjectMenu(
    WidgetTester tester) async {
  await enterSubScreenFromMainMenu(tester, employeesPageNavigator);
}

///
/// Use [tester] to get into employee management page from home screen
///
Future<void> enterEmployeeManagementPageFromAdminMenu(
    WidgetTester tester) async {
  final Finder navToolBarBtn = find.byTooltip(APP_DRAWER);
  await tester.pumpAndSettle();
  await tester.tap(navToolBarBtn);
  await tester.pumpAndSettle();
  final Finder adminsMenuBtn = find.byKey(Key(GeneralKeys.ADMIN_SETTINGS));
  await tester.tap(adminsMenuBtn);
  await tester.pumpAndSettle();
  final Finder employeesMenuBtn = find.byKey(Key(GeneralKeys.EMPLOYEES));
  await tester.tap(employeesMenuBtn);
  await tester.pumpAndSettle();
}

///
/// Use [tester] to get into plots and screen management page from home screen
///
Future<void> enterPlotsAndSiteScreen(WidgetTester tester) async {
  await enterSubScreenFromMainMenu(tester, plotsAndSitesPageNavigator);
}

///
/// Use [tester] to get into plots and screen management page from home screen
///
Future<void> enterDailyInfoScreen(WidgetTester tester) async {
  await enterSubScreenFromMainMenu(tester, dailyInfoScreenPageNavigator);
}

///
/// Use [tester] to get to the given screen navigator [currentNavigator]
///
Future<void> enterSubScreenFromMainMenu(
    WidgetTester tester, Finder currentNavigator) async {
  expect(find.byKey(Key(MainScreensKeys.MAIN_MENU_LIST)), findsOneWidget);
  await tester.pumpAndSettle();
  await tester.tap(currentNavigator);
  await tester.pumpAndSettle();
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './constants/constants.dart' as Constants;
import './constants/style_constants.dart' as StyleConstants;
import './screens/all_screens.dart';
import 'logger.dart' as Logger;
import 'logic/initializer.dart';
import 'screens/general_screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final theme = ThemeData(
  primarySwatch: StyleConstants.primaryColor,
  accentColor: StyleConstants.accentColor,
  errorColor: StyleConstants.errorColor,
  fontFamily: StyleConstants.FONT_FAMILY,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
final locals = [
  Locale('he'),
  Locale('eng'),
];
final localDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

///
/// Main App Widget. Start with the MainWidget, and include all the navigation routes needed in the project
///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: localDelegates,
        supportedLocales: locals,
        title: Constants.APP_NAME,
        theme: theme,
        routes: {
          '/': (ctx) => AppWidget(),
          NotImplementedPage.routeName: (ctx) =>
              NotImplementedPage(NotImplementedPage.screenTitle),
          AllSitesAndPlotsScreen.routeName: (ctx) => AllSitesAndPlotsScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          ProjectHomeScreen.routeName: (ctx) => ProjectHomeScreen(),
          DailyInfoScreen.routeName: (ctx) => DailyInfoScreen(),
          ArrangementScreen.routeName: (ctx) => ArrangementScreen(),
          AllEmployeesEditPage.routeName: (ctx) => AllEmployeesEditPage(),
          RegisterEmployeeScreen.routeName: (ctx) => RegisterEmployeeScreen(),
          EditEmployeeScreen.routeName: (ctx) => EditEmployeeScreen(),
          EditSiteScreen.routeName: (ctx) => EditSiteScreen(),
          AddPlotToSite.routeName: (ctx) => AddPlotToSite(),
          EditPlotScreen.routeName: (ctx) => EditPlotScreen(),
          PlotReportsScreen.routeName: (ctx) => PlotReportsScreen(),
          SpecificReportScreen.routeName: (ctx) => SpecificReportScreen(),
          EditReportScreen.routeName: (ctx) => EditReportScreen(),
          AllArrangementsScreen.routeName: (ctx) => AllArrangementsScreen(),
          AllStripsOfSpecificPlotScreen.routeName: (ctx) =>
              AllStripsOfSpecificPlotScreen(),
          SpecificImagesFolderScreen.routeName: (ctx) =>
              SpecificImagesFolderScreen(),
          AllImagesFoldersScreen.routeName: (ctx) => AllImagesFoldersScreen(),
          SpecificImageScreen.routeName: (ctx) => SpecificImageScreen(),
          AllProjectsScreen.routeName: (ctx) => AllProjectsScreen(),
          EditProjectScreen.routeName: (ctx) => EditProjectScreen(),
          ChooseProjectScreen.routeName: (ctx) => ChooseProjectScreen(),
          AdminMenuScreen.routeName: (ctx) => AdminMenuScreen(),
          DailyReportsScreen.routeName: (ctx) => DailyReportsScreen(),
          SpecificDailyReportScreen.routeName: (ctx) =>
              SpecificDailyReportScreen(),
        },
      ),
    );
  }
}

///
/// First Widget to be activated. with it's launch, starts the initialization process,
///
class AppWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initResult = useProvider(initProvider(context));
    return initResult.when(
      data: (_) => MainWidget(),
      loading: () => MySplashScreen(),
      error: (err, stack) {
        Logger.criticalList([
          "unexpected error:",
          err.toString(),
          stack.toString(),
          "error type: ${err.runtimeType.toString()}",
        ]);
        return MainWidget();
      },
    );
  }
}

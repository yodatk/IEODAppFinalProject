import 'package:flutter/material.dart';

import '../../../constants/style_constants.dart' as StyleConstants;
import '../../../models/permission.dart';
import '../../../models/plot.dart';
import '../../../models/reports/templates/Template.dart';
import '../../../widgets/navigation/navigation_row.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../constants/keys.dart' as Keys;
import '../specific_report_screen/specific_report_screen.dart';

///
/// Screen to show all available templates type for reports in a given [Plot]
/// Each button will navigate to a different List of reports according to the chosen type
///
class PlotReportsScreen extends StatelessWidget {
  static const routeName = '/plot_reports_screen';
  static const title = "דוחות חלקה";

  @override
  Widget build(BuildContext context) {
    Plot plot = (ModalRoute.of(context).settings.arguments as Plot);
    final header = "${PlotReportsScreen.title} ${plot.name}";
    return PermissionScreenWithAppBar(
      title: header,
      permissionLevel: Permission.MANAGER,
      scaffoldKey: GlobalKey<ScaffoldState>(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            NavigationRow(
              key: Key(Keys.GENERAL_MECHANICAL_REPORTS_BTN),
              route: SpecificReportScreen.routeName,
              title: "דוח מכאני",
              color: Colors.cyan,
              icon: StyleConstants.ICON_MACHINERY_WORK,
              args: {
                SpecificReportScreen.PLOT: plot,
                SpecificReportScreen.TEMPLATE_HEADER: 'דוחות מכאניים',
                SpecificReportScreen.TEMPLATE_TYPE:
                    TemplateTypeEnum.GeneralMechanical,
              },
            ),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
              key: Key(Keys.QUALITY_MECHANICAL_REPORTS_BTN),
              route: SpecificReportScreen.routeName,
              title: "דוח בקרה מכאני",
              color: Colors.cyan,
              icon: StyleConstants.ICON_SUPERVISION,
              args: {
                SpecificReportScreen.PLOT: plot,
                SpecificReportScreen.TEMPLATE_HEADER: 'דוחות בקרה מכאניים',
                SpecificReportScreen.TEMPLATE_TYPE:
                    TemplateTypeEnum.QualityControlForMechanical,
              },
            ),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
              key: Key(Keys.QUALITY_MANUAL_REPORTS_BTN),
              route: SpecificReportScreen.routeName,
              title: "דוח בקרת איכות ידני",
              color: Colors.cyan,
              icon: StyleConstants.ICON_HAND_QUALITY,
              args: {
                SpecificReportScreen.PLOT: plot,
                SpecificReportScreen.TEMPLATE_HEADER: 'דוחות בקרה ידניים',
                SpecificReportScreen.TEMPLATE_TYPE:
                    TemplateTypeEnum.QualityControlForManual,
              },
            ),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
                key: Key(Keys.BUNKERS_CLEARANCE_REPORTS_BTN),
                route: SpecificReportScreen.routeName,
                title: "דוח זיכוי בונקרים",
                color: Colors.cyan,
                icon: StyleConstants.ICON_BUNKER,
                args: {
                  SpecificReportScreen.PLOT: plot,
                  SpecificReportScreen.TEMPLATE_HEADER: 'דוחות זיכוי בונקרים',
                  SpecificReportScreen.TEMPLATE_TYPE:
                      TemplateTypeEnum.BunkersClearance,
                }),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
              key: Key(Keys.DEEP_TARGETS_REPORTS_BTN),
              route: SpecificReportScreen.routeName,
              title: "דוח מטרות עומק",
              color: Colors.cyan,
              icon: StyleConstants.ICON_DEEP_TARGET,
              args: {
                SpecificReportScreen.PLOT: plot,
                SpecificReportScreen.TEMPLATE_HEADER: "דוח מטרות עומק",
                SpecificReportScreen.TEMPLATE_TYPE: TemplateTypeEnum.DeepTarget,
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/permission.dart';
import '../../../models/reports/templates/Template.dart';
import '../../../widgets/navigation/navigation_row.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import '../constants/keys.dart' as Keys;
import 'specific_daily_report_screen/specific_daily_report_screen.dart';

///
/// Shows all typed of Daily Reports. each button will navigate to a list of reports of the chosen [Template] type
///
class DailyReportsScreen extends StatelessWidget {
  ///
  /// Route to navigate to this screen
  ///
  static const routeName = '/daily_reports_screen';

  ///
  /// Title of this screen
  ///
  static const title = "דוחות יומיים";

  @override
  Widget build(BuildContext context) {
    return PermissionScreenWithAppBar(
      title: title,
      permissionLevel: Permission.MANAGER,
      scaffoldKey: GlobalKey<ScaffoldState>(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            NavigationRow(
              key: Key(Keys.DAILY_CLEARANCE_BTN),
              route: SpecificDailyReportScreen.routeName,
              title: "דוח פינוי יומי",
              color: Colors.cyan,
              icon: Icons.calendar_today,
              args: {
                SpecificDailyReportScreen.TEMPLATE_HEADER: 'דוחות פינוי יומי',
                SpecificDailyReportScreen.TEMPLATE_TYPE:
                    TemplateTypeEnum.DailyClearance,
              },
            ),
            const SizedBox(
              height: 20,
            ),
            NavigationRow(
              key: Key(Keys.EMERGENCY_PRACTICE_DOCUMENTATION_BTN),
              route: SpecificDailyReportScreen.routeName,
              title: "תיעוד תרגול חירום",
              color: Colors.cyan,
              icon: Icons.support_rounded,
              args: {
                SpecificDailyReportScreen.TEMPLATE_HEADER: 'תיעוד תרגולי חירום',
                SpecificDailyReportScreen.TEMPLATE_TYPE:
                    TemplateTypeEnum.EmergencyPracticeDocumentation,
              },
            ),
          ],
        ),
      ),
    );
  }
}

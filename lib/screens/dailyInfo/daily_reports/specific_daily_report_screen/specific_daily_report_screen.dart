import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/permission.dart';
import '../../../../models/reports/templates/Template.dart';
import '../../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/specific_daily_report_list.dart';

///
/// Screen of Specific Type of Daily [Report].
/// This screen gets arguments to know which type of Report to show, and what the title supposed to be
///
class SpecificDailyReportScreen extends HookWidget {
  ///
  /// Route to navigate to this Screen
  ///
  static const routeName = '/specific_daily_report';
  static const TEMPLATE_TYPE = 'template_type';
  static const TEMPLATE_HEADER = 'template_header';

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificDailyReportScreenViewModel);
    Map<String, dynamic> args =
        (ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    TemplateTypeEnum templateType =
        (args[SpecificDailyReportScreen.TEMPLATE_TYPE] as TemplateTypeEnum);
    String templateHeader =
        args[SpecificDailyReportScreen.TEMPLATE_HEADER] as String;
    return PermissionScreenWithAppBar(
      title: templateHeader,
      permissionLevel: Permission.MANAGER,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: SafeArea(
        child: SpecificDailyReportList(templateType),
      ),
    );
  }
}

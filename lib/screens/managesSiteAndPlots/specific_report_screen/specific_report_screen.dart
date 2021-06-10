import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/permission.dart';
import '../../../models/plot.dart';
import '../../../models/reports/templates/Template.dart';
import '../../../widgets/permission_widgets/normal_permission_screen.dart';
import 'controllers/controllers.dart';
import 'widgets/specific_report_list.dart';

///
/// Screen to show all of the reports of a given template type.
/// the user can edit the showing report, delete them, generate files from them or create new reports
///
class SpecificReportScreen extends HookWidget {
  static const routeName = '/specific_plot_report';
  static const PLOT = "plot";
  static const TEMPLATE_TYPE = 'template_type';
  static const TEMPLATE_HEADER = 'template_header';

  // add site constants
  static const REQUIRED_ADD_SITE = 'שדה זה הכרחי להוספת אתר';
  static const SITE_NAME_MAX_LENGTH = 20;

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificReportScreenViewModel);
    Map<String, dynamic> args =
        (ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    Plot plot = args[SpecificReportScreen.PLOT] as Plot;
    TemplateTypeEnum templateType =
        (args[SpecificReportScreen.TEMPLATE_TYPE] as TemplateTypeEnum);
    String templateHeader =
        args[SpecificReportScreen.TEMPLATE_HEADER] as String;
    return PermissionScreenWithAppBar(
      title: "$templateHeader של חלקה ${plot.name}",
      permissionLevel: Permission.MANAGER,
      scaffoldKey: viewModel.screenUtils.scaffoldKey,
      body: SafeArea(
        child: SpecificReportList(templateType, plot),
      ),
    );
  }
}

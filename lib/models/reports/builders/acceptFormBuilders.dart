import 'package:flutter/widgets.dart';

import 'TemplateFormBuilder.dart';

///
/// part of the "BRICK WALL" pattern - to convert [TemplateBrick] to Widgets
///
abstract class AcceptFormBuilders {
  Widget acceptForm({
    BuildContext context,
    TemplateFormBuilder builder,
    String suffix,
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../bricks/ChoiceChipBrick.dart';
import '../bricks/ColumnBrick.dart';
import '../bricks/DateTimeBrick.dart';
import '../bricks/DropDownBrick.dart';
import '../bricks/EmptyBrick.dart';
import '../bricks/FunctionDropDownBrick.dart';
import '../bricks/PageBrick.dart';
import '../bricks/ReadOnlyTextBrick.dart';
import '../bricks/RowBrick.dart';
import '../bricks/TableBrick.dart';
import '../bricks/TextBrick.dart';
import '../bricks/TitleBrick.dart';
import '../templates/Template.dart';
import 'acceptFormBuilders.dart';

///
/// part of the "BRICK WALL" pattern - to convert each TemplateBrick to a visual component on the screen
///
abstract class TemplateFormBuilder {
  Widget visit(BuildContext context, AcceptFormBuilders element);

  FormBuilder buildForm(BuildContext context, Template template);

  Widget buildTextBrick(BuildContext context, TextBrick brick, String suffix);

  Widget buildReadOnlyTextBrick(
      BuildContext context, ReadOnlyTextBrick brick, String suffix);

  Widget buildChoiceChipBrick(
      BuildContext context, ChoiceChipBrick brick, String suffix);

  Widget buildDateBrick(
      BuildContext context, DateTimeBrick brick, String suffix);

  Widget buildRowBrick(BuildContext context, RowBrick brick);

  Widget buildColumnBrick(BuildContext context, ColumnBrick brick);

  Widget buildTableBrick(BuildContext context, TableBrick tableBrick);

  Widget buildTitleBrick(BuildContext context, TitleBrick brick);

  Widget buildDropDownBrick(
      BuildContext context, DropDownBrick brick, String suffix);

  Widget buildPageBrick(BuildContext context, PageBrick pageBrick);

  Widget buildEmptyBrick(BuildContext context, EmptyBrick brick);

  Widget buildFunctionDropDownBrick(
      BuildContext context, FunctionDropDownBrick brick, String suffix);
}

import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../plot.dart';
import '../../site.dart';
import '../../strip.dart';
import '../Report.dart';
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
import '../bricks/templateBrick.dart';
import 'acceptOutputBuilders.dart';

///
/// Part of the "BRICK WALL" pattern - to convert each brick to a output file(PDF) element
///
abstract class OutputBuilder<T> {
  dynamic visit(AcceptOutputBuilders element);

  Future<dynamic> generateReport(Report report);

  T buildTextBrick(TextBrick brick, String suffix, Map<String, dynamic> values);

  T buildReadOnlyTextBrick(
      ReadOnlyTextBrick brick, String suffix, Map<String, dynamic> values);

  T buildChoiceChipBrick(
      ChoiceChipBrick brick, String suffix, Map<String, dynamic> values);

  T buildDropDownBrick(
      DropDownBrick brick, String suffix, Map<String, dynamic> values);

  T buildFunctionDropDownBrick(
      FunctionDropDownBrick brick, String suffix, Map<String, dynamic> values);

  T buildDateBrick(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix);

  T buildRowBrick(RowBrick brick, Map<String, dynamic> values);

  T buildColumnBrick(ColumnBrick brick, Map<String, dynamic> values);

  T buildTableBrick(TableBrick tableBrick, Map<String, dynamic> values);

  T buildTitleBrick(TitleBrick brick);

  T buildEmptyBrick(EmptyBrick brick);

  T buildPageBrick(PageBrick pageBrick, Map<String, dynamic> values);

  String getTextStringValue(
      Map<String, dynamic> values, TemplateBrick brick, String suffix,
      {int rowLimit = Constants.TEXT_DEFAULT_ROW_LIMIT});

  String getMilliDateStringValue(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix);

  String getISO9601StringValue(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix);

  String getListStringValue(
      Map<String, dynamic> values, ChoiceChipBrick brick, String suffix);

  String getTitleStringValue(
      Map<String, dynamic> values, TitleBrick brick, String suffix);

  String getFileSuffix();

  Future<dynamic> buildManualReport(
      {@required List<Strip> strips,
      @required Plot plot,
      @required Site site,
      @required String employeeInChargeOfReport,
      String teamLeader,
      String projectManager});
}

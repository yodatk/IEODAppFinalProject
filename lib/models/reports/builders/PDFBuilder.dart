import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../constants/constants.dart' as Constants;
import '../../../logic/ProjectHandler.dart';
import '../../../models/reports/bricks/BrickType.dart';
import '../../../utils/datetime_utils.dart';
import '../../company.dart';
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
import '../bricks/parentBrick.dart';
import '../bricks/templateBrick.dart';
import '../builders/outputBuilder.dart';
import 'acceptOutputBuilders.dart';

///
/// Part of the "BRICK WALL" pattern -  Converts a given [Report] to a PDF file
///
class PDFBuilder extends OutputBuilder<pw.Widget> {
  pw.Document pdf;

  @override
  Future<pw.Document> visit(AcceptOutputBuilders element) {
    return element.acceptOutput(values: null, builder: this)
        as Future<pw.Document>;
  }

  @override
  Future<pw.Document> generateReport(Report report) async {
    pdf = pw.Document(
        title: report.name,
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(
              await rootBundle.load("assets/fonts/Assistant-Regular.ttf")),
          bold: pw.Font.ttf(
              await rootBundle.load("assets/fonts/Assistant-Bold.ttf")),
        ).copyWith(
          textAlign: pw.TextAlign.right,
          softWrap: true,
        ));

    pw.MemoryImage logo = await _loadImage();

    List<List<TemplateBrick>> allPages = _splitToPages(report);

    for (List<TemplateBrick> page in allPages) {
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (pw.Context context) => _buildHeader(context, logo),
          footer: _buildFooter,
          build: (pw.Context context) => <pw.Widget>[
                for (TemplateBrick child in page)
                  (child.acceptOutput(
                      values: report.attributeValues,
                      builder: this) as pw.Widget)
              ]));
    }

    return pdf;
  }

  Future<pw.MemoryImage> _loadImage() async {
    String logoAsset;
    switch (ProjectHandler().getCurrentProjectEmployer()) {
      case Company.IMAG:
        logoAsset = Constants.LOGO_IMAG_ASSET;
        break;
      case Company.IEOD:
        logoAsset = Constants.LOGO_IEOD_ASSET;
        break;
    }

    final logo = pw.MemoryImage(
      (await rootBundle.load(logoAsset)).buffer.asUint8List(),
    );
    return logo;
  }

  List<List<TemplateBrick>> _splitToPages(Report report) {
    // splitting bricks to pages
    final allPages = <List<TemplateBrick>>[];
    var currentPage = <TemplateBrick>[];
    for (TemplateBrick brick in report.template.templateBricks) {
      if (brick.brickType == BrickTypeEnum.PAGE_BRICK) {
        allPages.add(currentPage);
        currentPage = <TemplateBrick>[];
      } else {
        currentPage.add(brick);
      }
    }
    if (currentPage.isNotEmpty) {
      allPages.add(currentPage);
    }
    return allPages;
  }

  @override
  pw.Widget buildChoiceChipBrick(
      ChoiceChipBrick brick, String suffix, Map<String, dynamic> values) {
    String textValue = getListStringValue(values, brick, suffix);
    return attributeValueRow(brick.decoration ?? brick.attribute, textValue);
  }

  @override
  pw.Widget buildDropDownBrick(
      DropDownBrick brick, String suffix, Map<String, dynamic> values) {
    String textValue = getDropDownListStringValue(values, brick, suffix);
    return attributeValueRow(brick.decoration ?? brick.attribute, textValue);
  }

  @override
  pw.Widget buildFunctionDropDownBrick(
      FunctionDropDownBrick brick, String suffix, Map<String, dynamic> values) {
    String textValue =
        getFunctionDropDownListStringValue(values, brick, suffix);
    return attributeValueRow(brick.decoration ?? brick.attribute, textValue);
  }

  String getDropDownListStringValue(
      Map<String, dynamic> values, DropDownBrick brick, String suffix) {
    String textValue = values[brick.attribute + suffix] as String;
    return hebrewLineDecorator(textValue);
  }

  String getFunctionDropDownListStringValue(
      Map<String, dynamic> values, FunctionDropDownBrick brick, String suffix) {
    String textValue = values[brick.attribute + suffix] as String;
    return hebrewLineDecorator(textValue);
  }

  @override
  pw.Widget buildColumnBrick(ColumnBrick brick, Map<String, dynamic> values) {
    return pw.Column(children: buildChildrenBricks(brick, values));
  }

  List<pw.Widget> buildChildrenBricks(
      ParentBrick brick, Map<String, dynamic> values) {
    return [
      for (TemplateBrick child in brick.children)
        child.acceptOutput(values: values, builder: this) as pw.Widget
    ];
  }

  @override
  pw.Widget buildDateBrick(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix) {
    String textValue = getMilliDateStringValue(values, brick, suffix);
    return attributeValueRow(brick.decoration ?? brick.attribute, textValue);
  }

  pw.Widget attributeValueRow(String attribute, String textValue,
      [int lines = 1]) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
              hebrewLineDecorator(
                "$attribute: ",
              ),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Flexible(
            child: pw.Text(
              textValue,
              maxLines: lines,
              style: pw.TextStyle(
                decoration: pw.TextDecoration.underline,
              ),
            ),
          )
        ].reversed.toList());
  }

  @override
  pw.Widget buildPageBrick(PageBrick pageBrick, Map<String, dynamic> values) {
    return pw.SizedBox.shrink();
  }

  @override
  pw.Widget buildReadOnlyTextBrick(
      ReadOnlyTextBrick brick, String suffix, Map<String, dynamic> values) {
    String value = getTextStringValue(values, brick, suffix);
    return attributeValueRow(brick.decoration ?? brick.attribute, value);
  }

  @override
  pw.Widget buildRowBrick(RowBrick brick, Map<String, dynamic> values) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: <pw.Widget>[
          for (pw.Widget widget in buildChildrenBricks(brick, values))
            pw.Flexible(child: widget) // TODO: align to center
        ].reversed.toList());
  }

  @override
  pw.Widget buildTableBrick(TableBrick brick, Map<String, dynamic> values) {
    List<String> columns = [
      'מס״ד',
      for (TemplateBrick child in brick.children)
        (child.decoration ?? child.attribute)
    ];
    List<List<String>> cells = List<List<String>>.generate(
        brick.rowCount,
        (row) => List<String>.generate(
            columns.length, //num of children + 1 for row id
            (col) => col == 0
                ? (row + 1).toString()
                : brick.children[col - 1].getStringValue(
                    values: values,
                    builder: this,
                    suffix: "_${row + 1}")).reversed.toList());

    return pw.Table.fromTextArray(
        border: pw.TableBorder.all(),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
        headerHeight: 25,
        cellHeight: 40,
        cellAlignments: columns
            .asMap()
            .map((key, value) => MapEntry(key, pw.Alignment.center)),
        headerStyle: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          fontSize: 10,
        ),
        rowDecoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              width: .5,
            ),
          ),
        ),
        headers:
            columns.reversed.map((col) => handleParagraph(col, 50)).toList(),
        data: cells);
  }

  @override
  pw.Widget buildTextBrick(
      TextBrick brick, String suffix, Map<String, dynamic> values) {
    String value = getTextStringValue(values, brick, suffix);
    return attributeValueRow(
        brick.decoration ?? brick.attribute, value, brick.lines);
  }

  @override
  pw.Widget buildTitleBrick(TitleBrick brick) {
    double fontSize = getFontSize(brick.titleSize);
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
          pw.Text(brick.getStringValue(builder: this),
              style: pw.TextStyle(
                fontSize: fontSize,
              ))
        ]);
  }

  String hebrewLineDecorator(String line) {
    if (line == null) return "";
    if (!line
        .contains(RegExp(Constants.HEBREW_REGEXP))) // regular left to right
      return line;
    if (!line.contains(
        RegExp(Constants.SPECIAL_CASE_REGEXP))) // simple right to left
      return line.split('').reversed.join('');

    List<String> split = line.split(' '); // split into words
    bool rightToLeft = isFirstHebrew(split);
    RegExp hebrewRegExp = rightToLeft
        ? RegExp(Constants.NON_ENGLISH_REGEXP)
        : RegExp(Constants.HEBREW_REGEXP);
    List<bool> hebrewMap =
        split.map((word) => word.contains(hebrewRegExp)).toList();
    // reverse each hebrew word
    List<String> hebrew =
        split.where((word) => word.contains(hebrewRegExp)).map((word) {
      word = word.contains(RegExp(Constants.PARENTHESES_REGEXP))
          ? replaceParentheses(word)
          : word;
      return word.contains(RegExp(Constants.HEBREW_REGEXP))
          ? word.split('').reversed.join()
          : word;
    }).toList();
    List<String> nonHebrew =
        split.where((word) => !word.contains(hebrewRegExp)).toList();
    List<String> zipped = hebrewMap
        .map((is_hebrew) =>
            is_hebrew ? hebrew.removeAt(0) : nonHebrew.removeAt(0))
        .toList();
    zipped = rightToLeft ? zipped.reversed.toList() : zipped;

    return zipped.join(' ');
  }

  String getTextStringValue(
      Map<String, dynamic> values, TemplateBrick brick, String suffix,
      {int rowLimit = Constants.TEXT_DEFAULT_ROW_LIMIT}) {
    String textValue = values[brick.attribute + suffix] as String;
    return handleParagraph(textValue, rowLimit);
  }

  @override
  String getTitleStringValue(
      Map<String, dynamic> values, TitleBrick brick, String suffix) {
    return hebrewLineDecorator(brick.text);
  }

  String getMilliDateStringValue(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix) {
    int intValue = values[brick.attribute + suffix] as int;
    DateTime dateValue =
        intValue == null ? null : DateTime.fromMillisecondsSinceEpoch(intValue);
    String textValue = parseDate(brick, dateValue);
    return textValue;
  }

  String getListStringValue(
      Map<String, dynamic> values, ChoiceChipBrick brick, String suffix,
      {int rowLimit = Constants.TEXT_DEFAULT_ROW_LIMIT}) {
    String textValue = values[brick.attribute + suffix] as String;
    return handleParagraph(textValue, rowLimit);
  }

  @override
  String getISO9601StringValue(
      Map<String, dynamic> values, DateTimeBrick brick, String suffix) {
    String dateISO8601 = values[brick.attribute + suffix] as String;
    DateTime dateValue =
        dateISO8601 == null ? null : DateTime.parse(dateISO8601);
    String textValue = parseDate(brick, dateValue);
    return textValue;
  }

  String parseDate(DateTimeBrick brick, DateTime dateValue) {
    if (dateValue == null) return "";

    switch (brick.input) {
      case InputType.date:
        return dateToString(dateValue);
      case InputType.time:
        return dateToHourString(dateValue);
      case InputType.both:
        return dateToDateTimeString(dateValue);
    }
    return "";
  }

  pw.Widget _buildHeader(pw.Context context, pw.MemoryImage logo) {
    return pw.Column(children: <pw.Widget>[
      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Center(
              child: pw.Image(
                logo,
                width: 100,
                height: 100,
              ),
            ),
            pw.Text(DateFormat("dd.MM.yyyy").format(DateTime.now()))
          ])
    ]);
  }

  pw.Widget _buildFooter(pw.Context context) {
    String company = describeEnum(ProjectHandler().getCurrentProjectEmployer());
    return pw.Column(children: <pw.Widget>[
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: <pw.Widget>[
        pw.Text("$company - " + hebrewLineDecorator("כל הזכויות שמורות") + " ©")
      ])
    ]);
  }

  @override
  String getFileSuffix() {
    return ".pdf";
  }

  @override
  pw.Widget buildEmptyBrick(EmptyBrick brick) {
    return pw.SizedBox(
      height: brick.height,
    );
  }

  bool isFirstHebrew(List<String> split) {
    int firstHebrew = split
        .indexWhere((word) => word.contains(RegExp(Constants.HEBREW_REGEXP)));
    int firstEnglish = split
        .indexWhere((word) => word.contains(RegExp(Constants.ENGLISH_REGEXP)));
    return firstHebrew != -1 &&
        (firstEnglish == -1 || firstHebrew <= firstEnglish);
  }

  double getFontSize(TitleSizeEnum titleSize) {
    if (titleSize == null) return 40;

    switch (titleSize) {
      case TitleSizeEnum.HEADLINE_6:
        return 20;
      case TitleSizeEnum.HEADLINE_5:
        return 26;
      case TitleSizeEnum.HEADLINE_4:
        return 32;
      case TitleSizeEnum.HEADLINE_3:
        return 40;
      case TitleSizeEnum.HEADLINE_2:
        return 48;
      case TitleSizeEnum.HEADLINE_1:
        return 56;
    }
    return 40;
  }

  @override
  Future<pw.Document> buildManualReport({
    @required List<Strip> strips,
    @required Plot plot,
    @required Site site,
    @required String employeeInChargeOfReport,
    String teamLeader = "",
    String projectManager = "",
  }) async {
    final title = "פעולת פינוי ידני בחלקה";
    pdf = pw.Document(
        title: "$title ${plot.name}",
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(
              await rootBundle.load("assets/fonts/Assistant-Regular.ttf")),
          bold: pw.Font.ttf(
              await rootBundle.load("assets/fonts/Assistant-Bold.ttf")),
        ).copyWith(
          textAlign: pw.TextAlign.right,
          softWrap: true,
        ));

    pw.MemoryImage logo = await _loadImage();

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => _buildHeader(context, logo),
        footer: _buildFooter,
        build: (pw.Context context) => <pw.Widget>[
              getManualReportTitle(plot),
              getFirstRowOfDetails(plot, site, employeeInChargeOfReport),
              pw.SizedBox(height: 3),
              getStripsTable(strips),
              pw.SizedBox(height: 3),
              getSignaturePlace(teamLeader, projectManager),
            ]));

    return pdf;
  }

  pw.Widget getManualReportTitle(Plot plot) {
    final title = "פעולת פינוי ידנית";
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
          pw.Text(hebrewLineDecorator(title),
              style: pw.TextStyle(
                fontSize: 40,
              ))
        ]);
  }

  pw.Widget getFirstRowOfDetails(
      Plot plot, Site site, String manInChargeOfReport) {
    final dateTitle = "תאריך פעילות:";
    final siteField = "אתר:";
    final plotField = "חלקה:";
    final inChargeField = 'ר"צ:';
    final style = pw.TextStyle(fontSize: 18);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(hebrewLineDecorator("$inChargeField $manInChargeOfReport"),
            style: style),
        pw.Text(hebrewLineDecorator("$plotField ${plot.name}"), style: style),
        pw.Text(hebrewLineDecorator("$siteField ${site.name}"), style: style),
        pw.Text(
            hebrewLineDecorator("$dateTitle ${dateToString(DateTime.now())}"),
            style: style),
      ],
    );
  }

  pw.Widget getStripsTable(List<Strip> strips) {
    strips.sort((s1, s2) => s1.compareTo(s2));
    List<String> columns = [
      'סטריפ',
      "פעולה 1",
      "פעולה 2",
      'בקרת איכות',
      "מספר מטרות",
      'מספר מטרות עומק',
      'הערות',
    ];
    List<List<String>> cells = List<List<String>>.generate(
        strips.length,
        (row) => [
              handleParagraph(strips[row].notes, 20),
              handleParagraph(strips[row].depthTargetCount.toString(), 5),
              handleParagraph(strips[row].mineCount.toString(), 5),
              handleParagraph(strips[row].third?.employeeName ?? "", 5),
              handleParagraph(strips[row].second?.employeeName ?? "", 5),
              handleParagraph(strips[row].first?.employeeName ?? "", 5),
              handleParagraph(strips[row].name, 5),
            ]);

    return pw.Table.fromTextArray(
        border: pw.TableBorder.all(),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
        headerHeight: 25,
        columnWidths: {
          6: const pw.FixedColumnWidth(10),
          5: const pw.FixedColumnWidth(15),
          4: const pw.FixedColumnWidth(15),
          3: const pw.FixedColumnWidth(15),
          2: const pw.FixedColumnWidth(10),
          1: const pw.FixedColumnWidth(10),
          0: const pw.FixedColumnWidth(50),
        },
        cellHeight: 40,
        cellAlignments: columns
            .asMap()
            .map((key, value) => MapEntry(key, pw.Alignment.center)),
        headerStyle: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          fontSize: 10,
        ),
        rowDecoration: pw.BoxDecoration(
          border: const pw.Border(
            bottom: pw.BorderSide(
              width: .5,
            ),
          ),
        ),
        headers:
            columns.reversed.map((col) => handleParagraph(col, 5)).toList(),
        data: cells);
  }

  pw.Widget getSignaturePlace(String teamLeader, String projectManager) {
    final teamLeaderField = 'מנהל קבוצה:';
    final projectManagerField = 'מנהל אתר:';
    final signature = 'חתימה:';
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text("          "),
        pw.Text(hebrewLineDecorator("$signature")),
        pw.Text(hebrewLineDecorator("$projectManagerField $projectManager")),
        pw.Text(hebrewLineDecorator("$signature")),
        pw.Text(hebrewLineDecorator("$teamLeaderField $teamLeader")),
      ],
    );
  }

  pw.Widget getGraph() {
    // todo - check if possible
    throw Exception("Not Implemented");
  }

  String handleParagraph(String toSplit, int limit) {
    if (toSplit == null || toSplit.isEmpty) {
      return "";
    }
    var output = StringBuffer();
    var current = StringBuffer();
    final words = toSplit.split(" ");
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (current.length + word.length >= limit) {
        if (current.isEmpty) {
          if (output.isEmpty) {
            output.write("${hebrewLineDecorator(word)} ");
          } else {
            output.write("\n${hebrewLineDecorator(word)} ");
          }
        } else {
          output.write("\n${hebrewLineDecorator(current.toString())} ");
          current = StringBuffer("$word ");
        }
      } else {
        current.write("$word ");
      }
    }
    if (current.isNotEmpty) {
      output.write("\n${hebrewLineDecorator(current.toString())} ");
    }
    return output.toString().trim();
  }

  String replaceParentheses(String word) {
    switch (word) {
      case '(':
        return ')';
      case ')':
        return '(';
      case '[':
        return ']';
      case ']':
        return '[';
      case '{':
        return '}';
      case '}':
        return '{';
      default:
        return word
            .replaceAll(RegExp(r'^\('), ')')
            .replaceAll(RegExp(r'\)$'), '(')
            .replaceAll(RegExp(r'^\['), ']')
            .replaceAll(RegExp(r'\]$'), '[')
            .replaceAll(RegExp(r'^\{'), '}')
            .replaceAll(RegExp(r'\{$'), '{');
    }
  }
}

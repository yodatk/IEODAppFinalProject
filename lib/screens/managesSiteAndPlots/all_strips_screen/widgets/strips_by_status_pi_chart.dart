import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../logic/fieldHandler.dart';
import '../../../../models/strip.dart';
import '../../../../models/stripStatus.dart';

///
/// Pie Chart to show all available Strips in the current plot.
///
class StripsOfPlotPieChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StripsOfPlotPieChartState();
}

class _StripsOfPlotPieChartState extends State {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
              pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                setState(() {
                  if (pieTouchResponse.touchInput is FlLongPressEnd ||
                      pieTouchResponse.touchInput is FlPanEnd) {
                    touchedIndex = -1;
                  } else {
                    touchedIndex = pieTouchResponse.touchedSectionIndex;
                  }
                });
              }),
              borderData: FlBorderData(
                show: false,
              ),
              startDegreeOffset: 270,
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: showingSections(context)),
        ),
      ),
    );
  }

  PieChartSectionData getSection(
      BuildContext context,
      Color color,
      IconData icon,
      int i,
      Set<Strip> allStrips,
      List<Set<Strip>> allStripsGroup,
      String toolTip) {
    var f = NumberFormat("###", "en_US");
    final radiusVal = MediaQuery.of(context).size.width * 0.32;
    final widgetSizeVal = 40.0;
    final isTouched = i == touchedIndex;
    final double fontSize = isTouched ? 16 : 14;
    final double radius = isTouched ? 1.1 * radiusVal : radiusVal;
    final double widgetSize = isTouched ? 1.375 * widgetSizeVal : widgetSizeVal;
    final percent =
        (allStripsGroup[i].length.toDouble() / allStrips.length) * 100;

    return PieChartSectionData(
      color: color,
      value: allStripsGroup[i].length.toDouble(),
      title: percent >= 6 ? '${f.format(percent)}%' : '',
      radius: radius,
      titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff)),
      badgeWidget: _Badge(
        icon,
        size: widgetSize,
        borderColor: const Color(0xff0293ee),
        tooltip: '$toolTip, ${f.format(percent)}%',
      ),
      badgePositionPercentageOffset: 0.98,
    );
  }

  List<PieChartSectionData> showingSections(BuildContext context) {
    final allStripsLists = {
      StripStatus.NONE: FieldHandler().currentNoneStrips,
      StripStatus.IN_FIRST: FieldHandler().currentInFirstStrips,
      StripStatus.FIRST_DONE: FieldHandler().currentFirstDoneStrips,
      StripStatus.IN_SECOND: FieldHandler().currentInSecondStrips,
      StripStatus.SECOND_DONE: FieldHandler().currentSecondDoneStrips,
      StripStatus.IN_REVIEW: FieldHandler().currentInReviewStrips,
      StripStatus.FINISHED: FieldHandler().currentFinishedStrips
    }..removeWhere((key, value) => value == null || value.isEmpty);
    final allStrips = Set<Strip>();
    final statuses = <StripStatus>[];
    final stripSets = <Set<Strip>>[];
    allStripsLists.forEach((key, value) {
      statuses.add(key);
      stripSets.add(value);
      allStrips.addAll(value);
    });
    return List.generate(stripSets.length, (i) {
      switch (statuses[i]) {
        case StripStatus.NONE:
          final tooltip1 = "טרם התחיל";
          final tooltip2 = '${FieldHandler().currentNoneStrips.length}';
          return getSection(
            context,
            Colors.red,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.IN_FIRST:
          final tooltip1 = "בפעולה ראשונה";
          final tooltip2 = '${FieldHandler().currentInFirstStrips.length}';
          return getSection(
            context,
            Colors.deepOrange,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.FIRST_DONE:
          final tooltip1 = "אחרי ראשונה";
          final tooltip2 = '${FieldHandler().currentFirstDoneStrips.length}';
          return getSection(
            context,
            Colors.orange,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.IN_SECOND:
          final tooltip1 = "בפעולה שניה";
          final tooltip2 = '${FieldHandler().currentInSecondStrips.length}';
          return getSection(
            context,
            Colors.pinkAccent,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.SECOND_DONE:
          final tooltip1 = "אחרי שניה";
          final tooltip2 = '${FieldHandler().currentSecondDoneStrips.length}';
          return getSection(
            context,
            Colors.purpleAccent,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.IN_REVIEW:
          final tooltip1 = "בביקורת";
          final tooltip2 = '${FieldHandler().currentInReviewStrips.length}';
          return getSection(
            context,
            Colors.blue,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        case StripStatus.FINISHED:
          final tooltip1 = "גמורים";
          final tooltip2 = '${FieldHandler().currentFinishedStrips.length}';
          return getSection(
            context,
            Colors.green,
            convertStatusToIcon(statuses[i]),
            i,
            allStrips,
            stripSets,
            '$tooltip1, $tooltip2',
          );
        default:
          return null;
      }
    });
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;
  final String tooltip;

  const _Badge(
    this.icon, {
    Key key,
    @required this.tooltip,
    @required this.size,
    @required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: PieChart.defaultDuration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              offset: const Offset(3, 3),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.all(size * .15),
        child: Center(child: Icon(icon)),
      ),
    );
  }
}

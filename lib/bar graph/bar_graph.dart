import 'package:expense_tracker/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List monthlySummary; // (25, 500, 120...)
  final int startMonth; // 0 JAN, 1 FEB, 2 MAR...
  final void Function(int)? onBarTapped;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
    required this.onBarTapped,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // this list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    // we need to scroll to the latest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // initialize bar data - user our monthly summary to create a list of bars
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  //calculate max for upper limit of graph
  double calcuateMax() {
    // initially, set it at 500, but adjust if spending is past this amount
    double max = 500;

    // get the month with the highest amount
    widget.monthlySummary.sort();
    //increase the upper limit by a bit
    max = widget.monthlySummary.last = 1.05;

    if (max < 500) {
      return 500;
    }

    return max;
  }

  // scroll controller to make sure it scrolls to the end/latest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    // initialize upon build
    initializeBarData();

    // bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width:
              barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.spot != null) {
                    final tappedIndex = response.spot!.touchedBarGroupIndex;
                    widget.onBarTapped?.call(tappedIndex);
                  }
                },
              ),

              minY: 0,
              maxY: calcuateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 24,
                  ),
                ),
              ),
              barGroups:
                  barData
                      .map(
                        (data) => BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                              toY: data.y.toDouble(),
                              width: barWidth,
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromARGB(255, 40, 40, 220),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: calcuateMax(),
                                color: Colors.grey.shade100,
                              ),
                            ),
                          ],
                          barsSpace: 4,
                        ),
                      )
                      .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

//  B O T T O M - T I T L E S
Widget getBottomTitles(double value, TitleMeta meta) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J';
      break;
    case 1:
      text = 'A';
      break;
    case 2:
      text = 'S';
      break;
    case 3:
      text = 'O';
      break;
    case 4:
      text = 'N';
      break;
    case 5:
      text = 'D';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'F';
      break;
    case 8:
      text = 'M';
      break;
    case 9:
      text = 'A';
      break;
    case 10:
      text = 'M';
      break;
    case 11:
      text = 'J';
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(child: Text(text, style: textstyle), meta: meta);
}

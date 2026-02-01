import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:intl/intl.dart';

class AttendanceBarChart extends StatefulWidget {
  final List<ActivityAttendance> fetchedWeeklyAttendanceSummaryData;
  final String startDate;
  final String endDate;

  const AttendanceBarChart(
      this.fetchedWeeklyAttendanceSummaryData, this.startDate, this.endDate,
      {super.key});

  @override
  State<AttendanceBarChart> createState() => _AttendanceBarChartState();
}

class _AttendanceBarChartState extends State<AttendanceBarChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<String> _getDateRange() {
    final start = DateTime.parse(widget.startDate);
    final end = DateTime.parse(widget.endDate);

    return List.generate(end.difference(start).inDays + 1,
        (i) => DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i))));
  }

  List<BarChartGroupData> _getBarGroups() {
    final dates = _getDateRange();

    return List.generate(dates.length, (i) {
      final date = dates[i];
      final present = _presentCount(date);
      final absent = _absentCount(date);

      return BarChartGroupData(
        barsSpace: 5,
        x: i,
        barRods: [
          //present bar
          BarChartRodData(
            borderSide: BorderSide(width: 2.0),
            borderRadius: BorderRadius.zero,
            width: 20,
            toY: present.toDouble(),
            color: Colors.green,
          ),

          //absent bar
          BarChartRodData(
            borderSide: BorderSide(width: 2.0),
            borderRadius: BorderRadius.zero,
            width: 20,
            toY: absent.toDouble(),
            color: Colors.red,
          ),
        ],
        showingTooltipIndicators: [0, 1], // force tooltip to show
      );
    });
  }

  Widget getTitles(double value, TitleMeta meta) {
    final dates = _getDateRange();
    final index = value.toInt();

    if (index < 0 || index >= dates.length) return const SizedBox();

    final date = DateTime.parse(dates[index]);

    return SideTitleWidget(
        meta: meta,
        child: Column(
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              DateFormat('MM/dd').format(date), // 03/04
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ));
  }

  int _presentCount(String date) {
    return widget.fetchedWeeklyAttendanceSummaryData
            .firstWhere(
                (summaryAttendanceObject) =>
                    summaryAttendanceObject.sign_in_date == date,
                orElse: () => ActivityAttendance(present_count: 0))
            .present_count ??
        0;
  }

  int _absentCount(String date) {
    return widget.fetchedWeeklyAttendanceSummaryData
            .firstWhere(
                (summaryAttendanceObject) =>
                    summaryAttendanceObject.sign_in_date == date,
                orElse: () => ActivityAttendance(absent_count: 0))
            .absent_count ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20.0,
        ),
        if (widget.fetchedWeeklyAttendanceSummaryData.length > 0)
          Container(
            height: screenHeight * 0.5,
            child: BarChart(
              BarChartData(
                  groupsSpace: 2.0,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _getBarGroups(),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (_, meta) => SizedBox())),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              getTitlesWidget: getTitles,
                              showTitles: true,
                              reservedSize: 50))),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                  ),
                  barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toInt().toString(),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ))),
            ),
          )
        else
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: const Text(
              'No data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
      ],
    );
    // );
  }
}

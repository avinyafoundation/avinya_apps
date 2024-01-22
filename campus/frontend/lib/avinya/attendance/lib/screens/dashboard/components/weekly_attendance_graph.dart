import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';

class LineChartWidget extends StatelessWidget {
  final List<ActivityAttendance> points;

  const LineChartWidget(this.points, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Student Count",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 2,
          child: LineChart(
            LineChartData(
              lineBarsData: points.isNotEmpty
                  ? [
                      LineChartBarData(
                        spots: points
                            .where(
                                (point) => point.x != null && point.y != null)
                            .map((point) => FlSpot(point.x!, point.y!))
                            .toList(),
                        isCurved: false,
                        dotData: FlDotData(
                          show: true,
                        ),
                      ),
                    ]
                  : [],
              borderData: FlBorderData(
                border: const Border(bottom: BorderSide(), left: BorderSide()),
              ),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                leftTitles: AxisTitles(sideTitles: _leftTitles),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          // Assuming value is the timestamp in milliseconds
          int timestamp = value.toInt();

          // Assuming each point represents a day, and 'x' is the date in milliseconds
          DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

          return Text(
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12),
          );
        },
      );

  SideTitles get _leftTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          int timestamp = value.toInt();
          return Text(
            '${timestamp.toString()}',
            style: TextStyle(fontSize: 12),
          );
        },
      );
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class Chart extends StatelessWidget {
  Chart(
      {Key? key,
      required this.fetchedPieChartData,
      required this.totalStudentCount,
      required this.totalAttendance})
      : super(key: key);

  final List fetchedPieChartData;
  final int totalStudentCount;
  final int totalAttendance;

  late final List<PieChartSectionData> paiChartSelectionData =
      generatePieChartSections(fetchedPieChartData);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionData,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "${totalAttendance.toString()}",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                Text(
                  "of ${totalStudentCount} Students",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> generatePieChartSections(List fetchedPieChartData) {
  List<PieChartSectionData> pieChartSections = [];

  fetchedPieChartData.forEach((attendance) {
    // Assuming you want to use total_student_count for the value
    double value = 0;
    double totalStudentPerClass = 0;
    int color = 0xFFFFA500;
    if (attendance.present_count != null) {
      value = attendance.present_count!.toDouble();
      totalStudentPerClass = attendance.total_student_count!.toDouble();
      color = attendance.color;
    }

    pieChartSections.add(
      PieChartSectionData(
        color: Color(color),
        value: value,
        showTitle: false,
        radius: calculateRadius(value, totalStudentPerClass),
      ),
    );
  });

  return pieChartSections;
}

double calculateRadius(double value, double totalStudentPerClass) {
  double radius = 0;
  radius = (value * 40 / totalStudentPerClass);
  return radius;
}

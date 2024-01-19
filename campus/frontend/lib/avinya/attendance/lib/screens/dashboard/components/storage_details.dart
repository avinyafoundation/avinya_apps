import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import '../constants.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails(
      {Key? key,
      required this.fetchedPieChartData,
      required this.totalStudentCount,
      required this.totalAttendance})
      : super(key: key);

  final List fetchedPieChartData;
  final int totalStudentCount;
  final int totalAttendance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Student Attendance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(
              fetchedPieChartData: fetchedPieChartData,
              totalStudentCount: totalStudentCount,
              totalAttendance: totalAttendance),
          if (fetchedPieChartData.isEmpty)
            Center(
              child: Text(
                "No Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            ...fetchedPieChartData.map(
              (attendance) => StorageInfoCard(
                svgSrc: attendance.svg_src ?? 'assets/icons/late.png',
                title: attendance.description ?? '',
                amountOfFiles: attendance.present_count?.toString() ?? '',
                numOfFiles: attendance.total_student_count ?? 0,
                color: attendance.color,
              ),
            ),
        ],
      ),
    );
  }
}

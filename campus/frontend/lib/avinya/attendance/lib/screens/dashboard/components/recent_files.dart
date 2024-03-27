import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import '../constants.dart';

class AttendanceMissedBySecurity extends StatefulWidget {
  const AttendanceMissedBySecurity({
    Key? key,
    required this.fetchedAttendanceData,
  }) : super(key: key);

  final List<ActivityAttendance> fetchedAttendanceData;

  @override
  _AttendanceMissedBySecurityState createState() =>
      _AttendanceMissedBySecurityState();
}

class _AttendanceMissedBySecurityState
    extends State<AttendanceMissedBySecurity> {
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
            "Attendance Missed By Security",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: widget.fetchedAttendanceData.isEmpty
                ? Center(
                    child: Text(
                      "No Data",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : DataTable(
                    columnSpacing: defaultPadding,
                    columns: [
                      DataColumn(
                        label: Text(
                          "Student Name",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Class",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Sign In Date",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(
                      widget.fetchedAttendanceData.length,
                      (index) => recentFileDataRow(
                          widget.fetchedAttendanceData[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(ActivityAttendance fileInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            // Icon(Icons.verified_user, color: Colors.white, size: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                fileInfo.preferred_name!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(
        fileInfo.description!,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      )),
      DataCell(Text(
        fileInfo.sign_in_time!,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      )),
    ],
  );
}

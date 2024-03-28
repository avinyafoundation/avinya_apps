import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class AttendanceSummaryExcelReportExport extends StatefulWidget {
  final List<ActivityAttendance> fetchedDailyAttendanceSummaryData;
  final List<String?> columnNames;
  final Function() updateExcelState;
  final bool isFetching;
  final String  formattedStartDate;
  final String formattedEndDate;

  const AttendanceSummaryExcelReportExport(
      {Key? key,
      required this.fetchedDailyAttendanceSummaryData,
      required this.columnNames,
      required this.updateExcelState,
      required this.isFetching,
      required this.formattedStartDate,
      required this.formattedEndDate
      })
      : super(key: key);

  @override
  _AttendanceSummaryExcelReportExportState createState() => _AttendanceSummaryExcelReportExportState();
}

class _AttendanceSummaryExcelReportExportState extends State<AttendanceSummaryExcelReportExport> {
  List<ActivityAttendance> _fetchedDailyAttendanceSummaryData = [];
  List<String?> columnNames = [];
  List<String?> columnNamesWithoutDates = [];


  void exportToExcel() async {
    await widget.updateExcelState();
    
   
    setState(() {
      this._fetchedDailyAttendanceSummaryData = widget.fetchedDailyAttendanceSummaryData;
      this.columnNames = widget.columnNames;
    });
    
    if (_fetchedDailyAttendanceSummaryData.length > 0) {
      

    if (columnNamesWithoutDates.isEmpty) {
      columnNamesWithoutDates.addAll([
        "Date",
        "Daily Count",
        "Daily Attendance Percentage",
        "Late Count",
        "Late Attendance Percentage",
        "Total Count"
      ]);
    }

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Styling for organization header
    final organizationHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: '#807f7d',
      horizontalAlign: HorizontalAlign.Center,
    );

    // Styling for row cells
    final rowCellsStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );

    // Adding organization header
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(
          columnIndex: columnNamesWithoutDates.length - 1, rowIndex: 0),
    );

    // Adding subheaders
    final subHeaderStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: '#a3a3a2',
      textWrapping: TextWrapping.WrapText,
    );

    // Adding column headers
    for (var colIndex = 0;
        colIndex < columnNamesWithoutDates.length;
        colIndex++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .value = columnNamesWithoutDates[colIndex];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .cellStyle = subHeaderStyle;
    }
    sheet.setColWidth(0, 10);
    sheet.setColWidth(1, 25);
    sheet.setColWidth(2, 26);
    sheet.setColWidth(3, 20);
    sheet.setColWidth(4, 25);
    sheet.setColWidth(5, 26);
   

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        "Avinya Foundation Daily Attendance Summary Report From ${widget.formattedStartDate} to ${widget.formattedEndDate}";
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = organizationHeaderStyle;

    if (_fetchedDailyAttendanceSummaryData.isNotEmpty) {
     
      for (var index = 0; index < _fetchedDailyAttendanceSummaryData.length; index++) {
        var dailyAttendanceSummaryData = _fetchedDailyAttendanceSummaryData[index];

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index + 2))
            .value = dailyAttendanceSummaryData.sign_in_date?.toString() ?? '';

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index + 2))
            .value = dailyAttendanceSummaryData.present_count?.toString() ?? '';

        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 2, rowIndex: index + 2))
                .value =
            (dailyAttendanceSummaryData.present_attendance_percentage?.toString() ?? '') + "%"; // update bank branch name

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: index + 2))
            .value = dailyAttendanceSummaryData.late_count?.toString() ?? '';

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: index + 2))
            .value = (dailyAttendanceSummaryData.late_attendance_percentage?.toString()??'') + "%";
        
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: index + 2))
            .value = dailyAttendanceSummaryData.total_count?.toString()??'';
        
      }
    }

    excel.save(fileName: "DailyAttendanceSummaryReport_${widget.formattedStartDate}_to_${widget.formattedEndDate}.xlsx");
  }

}

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isFetching,
      child: ElevatedButton.icon(
        icon: Icon(Icons.download),
        label: Text('Excel Export'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
        ),
        onPressed: (){
          exportToExcel();
        },
        
      ),
    );
  }
}

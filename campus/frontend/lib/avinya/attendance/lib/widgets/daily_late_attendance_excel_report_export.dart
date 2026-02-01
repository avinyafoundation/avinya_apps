import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class DailyLateAttendanceExcelReportExport  extends StatefulWidget {
  final List<ActivityAttendance> fetchedDailyLateAttendanceData;
  final Function() updateExcelState;
    final bool isFetching;
  final String  formattedStartDate;
  final String formattedEndDate;
  var selectedValue;

  DailyLateAttendanceExcelReportExport(
      {Key? key,
      required this.fetchedDailyLateAttendanceData,
      required this.updateExcelState,
      required this.isFetching,
      required this.selectedValue,
      required this.formattedStartDate,
      required this.formattedEndDate
      })
      : super(key: key);

  @override
  _DailyLateAttendanceExcelReportExportState createState() => _DailyLateAttendanceExcelReportExportState();
}

class _DailyLateAttendanceExcelReportExportState extends State<DailyLateAttendanceExcelReportExport> {
  List<ActivityAttendance> _fetchedDailyLateAttendanceData = [];
  List<String?> columnNamesWithoutDates = [];
  var _selectedValue;


  void exportToExcel() async {
    await widget.updateExcelState();
    
   
    setState(() {
      this._fetchedDailyLateAttendanceData = widget.fetchedDailyLateAttendanceData;
      this._selectedValue = widget.selectedValue;
      this.columnNamesWithoutDates.clear();
    });
    
    if (_fetchedDailyLateAttendanceData.length > 0) {
      
   
    if (columnNamesWithoutDates.isEmpty) {

     if(_selectedValue == null){

        columnNamesWithoutDates.addAll([
          "Date",
          "Name",
          "Digital ID",
          "Class",
          "In Time",
          "Late By"
        ]);

     }else{
        columnNamesWithoutDates.addAll([
          "Date",
          "Name",
          "Digital ID",
          "In Time",
          "Late By"
        ]);
     }
    }

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Styling for organization header
    final organizationHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#807f7d'),
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
      backgroundColorHex: ExcelColor.fromHexString('#a3a3a2'),
      textWrapping: TextWrapping.WrapText,
    );

    // Adding column headers
    for (var colIndex = 0;
        colIndex < columnNamesWithoutDates.length;
        colIndex++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .value = TextCellValue(columnNamesWithoutDates[colIndex]??'');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .cellStyle = subHeaderStyle;
    }
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 50);

    if(_selectedValue == null){
      sheet.setColumnWidth(3, 20);
      sheet.setColumnWidth(4, 25);
      sheet.setColumnWidth(5, 26);
    }else{
      sheet.setColumnWidth(3, 20);
      sheet.setColumnWidth(4, 25);
    }

   

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
      TextCellValue("Avinya Foundation Daily Late Attendance Summary Report From ${widget.formattedStartDate} to ${widget.formattedEndDate}");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = organizationHeaderStyle;

    if (_fetchedDailyLateAttendanceData.isNotEmpty) {
     
      for (var index = 0; index < _fetchedDailyLateAttendanceData.length; index++) {

        var dailyLateAttendanceData = _fetchedDailyLateAttendanceData[index];
        var date = dailyLateAttendanceData.sign_in_time!.split(" ")[0];

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index + 2))
            .value = TextCellValue(date.toString() ?? '');

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index + 2))
            .value = TextCellValue(dailyLateAttendanceData.preferred_name?.toString() ?? '');

        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 2, rowIndex: index + 2))
                .value =
            TextCellValue((dailyLateAttendanceData.digital_id?.toString() ?? '')); 

      if(_selectedValue == null){

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: index + 2))
            .value = TextCellValue(dailyLateAttendanceData.description?.toString() ?? '');

        
        var lateSignInTime =
          DateTime.parse(dailyLateAttendanceData.sign_in_time!);
        var officeStartTime = DateTime.parse("$date 08:30:00");
        var lateBy = lateSignInTime.difference(officeStartTime).inMinutes;
        var formattedTime = DateFormat('hh:mm a').format(lateSignInTime);

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: index + 2))
            .value = TextCellValue(formattedTime.toString()??'');
        
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: index + 2))
            .value = TextCellValue((lateBy.toString()??'') + " minutes");

      }else{

        var lateSignInTime =
          DateTime.parse(dailyLateAttendanceData.sign_in_time!);
        var officeStartTime = DateTime.parse("$date 08:30:00");
        var lateBy = lateSignInTime.difference(officeStartTime).inMinutes;
        var formattedTime = DateFormat('hh:mm a').format(lateSignInTime);

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: index + 2))
            .value = TextCellValue(formattedTime.toString()??'');
        
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: index + 2))
            .value = TextCellValue((lateBy.toString()??'')+ " minutes");

      }
        
     }
    }

    excel.save(fileName: "DailyLateAttendanceReport_${widget.formattedStartDate}_to_${widget.formattedEndDate}.xlsx");
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

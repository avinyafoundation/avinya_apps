// import 'package:excel/excel.dart';
// import 'package:flutter/material.dart';
// import 'package:attendance/data/activity_attendance.dart';
// import 'package:gallery/data/person.dart';
// import 'package:intl/intl.dart';

// class ExcelExport extends StatefulWidget {
//   final List<ActivityAttendance> fetchedAttendance;
//   final List<String?> columnNames;
//   final Organization? fetchedOrganization;

//   const ExcelExport(
//       {Key? key,
//       required this.fetchedAttendance,
//       required this.columnNames,
//       required this.fetchedOrganization})
//       : super(key: key);

//   @override
//   _ExcelExportState createState() => _ExcelExportState();
// }

// class _ExcelExportState extends State<ExcelExport> {
//   Organization? _fetchedOrganization;
//   List<ActivityAttendance> _fetchedAttendance = [];
//   List<String?> columnNames = [];

//   void exportToExcel() {
//     _fetchedAttendance = widget.fetchedAttendance;
//     columnNames = widget.columnNames;
//     _fetchedOrganization = widget.fetchedOrganization;

//     columnNames.addAll(["Bank Name", "Bank Account Name", "Bank Account No."]);

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel[excel.getDefaultSheet()!];

//     sheet.setColWidth(0, 25);
//     sheet.setColWidth(1, 40);

//     // Styling for organization header
//     final organizationHeaderStyle = CellStyle(
//       bold: true,
//       backgroundColorHex: '#F2F2F2',
//       horizontalAlign: HorizontalAlign.Center,
//     );

//     // Styling for row cells
//     final rowCellsStyle = CellStyle(
//       horizontalAlign: HorizontalAlign.Center,
//     );

//     // Adding organization header
//     sheet.merge(
//       CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
//       CellIndex.indexByColumnRow(
//           columnIndex: columnNames.length - 1, rowIndex: 0),
//     );

//     // Adding subheaders
//     final subHeaderStyle = CellStyle(
//       bold: true,
//       horizontalAlign: HorizontalAlign.Center,
//     );

//     // Adding column headers
//     for (var columnIndex = 0; columnIndex < columnNames.length; columnIndex++) {
//       sheet
//           .cell(
//               CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1))
//           .value = columnNames[columnIndex];
//       sheet
//           .cell(
//               CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1))
//           .cellStyle = subHeaderStyle;
//     }
//     sheet.setColWidth(columnNames.length - 5, 25);
//     sheet.setColWidth(columnNames.length - 4, 25);
//     sheet.setColWidth(columnNames.length - 3, 25);
//     sheet.setColWidth(columnNames.length - 2, 25);
//     sheet.setColWidth(columnNames.length - 1, 25);
//     final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
//     final dateFormatter = DateFormat('yyyy-MM-dd');
//     List<String?> dateColumns =
//         columnNames.where((name) => dateRegex.hasMatch(name!)).toList();

//     String? fromDate = dateColumns.isNotEmpty ? dateColumns.first : '';
//     String? toDate = dateColumns.isNotEmpty ? dateColumns.last : '';

//     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
//         "Avinya Foundation Student Payment Report From ${fromDate} to ${toDate}";
//     sheet
//         .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
//         .cellStyle = organizationHeaderStyle;

//     if (_fetchedOrganization != null &&
//         _fetchedOrganization!.people.isNotEmpty &&
//         columnNames.length > 0) {
//       for (var rindex = 2;
//           rindex < _fetchedOrganization!.people.length + 2;
//           rindex++) {
//         for (var index = 0;
//             index < columnNames.toSet().toList().length;
//             index++) {
//           var element = columnNames[index];
//           if (dateRegex.hasMatch(element!)) {
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: index, rowIndex: rindex))
//                 .value = "Absent";
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: index, rowIndex: rindex))
//                 .cellStyle = rowCellsStyle;
//           }
//         }
//       }

//       for (var index = 0;
//           index < _fetchedOrganization!.people.length;
//           index++) {
//         var person = _fetchedOrganization!.people[index];

//         sheet
//             .cell(
//                 CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index + 2))
//             .value = person.preferred_name!;

//         sheet
//             .cell(
//                 CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index + 2))
//             .value = person.digital_id.toString();

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 3, rowIndex: index + 2))
//             .value = person.bank_name?.toString() ?? '';

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 2, rowIndex: index + 2))
//             .value = person.bank_account_name?.toString() ?? '';

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 1, rowIndex: index + 2))
//             .value = person.bank_account_number?.toString() ?? '';

//         int absentCount = 0;

//         for (var element in columnNames) {
//           if (dateRegex.hasMatch(element!)) {
//             try {
//               dateFormatter.parseStrict(element);
//               absentCount++;
//             } catch (e) {
//               // Handle the exception or continue to the next element
//             }
//           }
//         }

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 7, rowIndex: index + 2))
//             .value = '0';
//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 7, rowIndex: index + 2))
//             .cellStyle = rowCellsStyle;

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 6, rowIndex: index + 2))
//             .value = absentCount.toString();
//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 6, rowIndex: index + 2))
//             .cellStyle = rowCellsStyle;

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 5, rowIndex: index + 2))
//             .value = '0';
//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 5, rowIndex: index + 2))
//             .cellStyle = rowCellsStyle;

//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 4, rowIndex: index + 2))
//             .value = '0';
//         sheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnNames.length - 4, rowIndex: index + 2))
//             .cellStyle = rowCellsStyle;

//         for (final attendance in _fetchedAttendance) {
//           if (attendance.person_id == person.id) {
//             int presentCount = 0;
//             int newAbsentCount = 0;
//             for (final date in columnNames) {
//               if (attendance.sign_in_time != null &&
//                   attendance.sign_in_time!.split(" ")[0] == date) {
//                 presentCount++;
//                 sheet
//                     .cell(CellIndex.indexByColumnRow(
//                         columnIndex: columnNames.indexOf(date),
//                         rowIndex: index + 2))
//                     .value = 'Present';
//                 sheet
//                     .cell(CellIndex.indexByColumnRow(
//                         columnIndex: columnNames.indexOf(date),
//                         rowIndex: index + 2))
//                     .cellStyle = rowCellsStyle;
//               }
//             }

//             newAbsentCount = absentCount - presentCount;

//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 7, rowIndex: index + 2))
//                 .value = presentCount.toString();
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 7, rowIndex: index + 2))
//                 .cellStyle = rowCellsStyle;

//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 6, rowIndex: index + 2))
//                 .value = newAbsentCount.toString();
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 6, rowIndex: index + 2))
//                 .cellStyle = rowCellsStyle;

//             int studentPayment = 100 * presentCount;
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 5, rowIndex: index + 2))
//                 .value = studentPayment.toDouble().toStringAsFixed(2);
//             sheet
//                 .cell(CellIndex.indexByColumnRow(
//                     columnIndex: columnNames.length - 4, rowIndex: index + 2))
//                 .value = studentPayment.toDouble().toStringAsFixed(2);
//           }
//         }
//       }
//     }

//     excel.save(fileName: "StudentPayment_${fromDate}_to_${toDate}.xlsx");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         child: Text('Export to Excel'),
//         onPressed: exportToExcel,
//       ),
//     );
//   }
// }

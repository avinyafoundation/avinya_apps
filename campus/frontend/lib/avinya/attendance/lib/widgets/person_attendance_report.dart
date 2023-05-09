import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gallery/avinya/asset/lib/data.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';

class PersonAttendanceMarkerReport extends StatefulWidget {
  const PersonAttendanceMarkerReport({super.key});

  @override
  State<PersonAttendanceMarkerReport> createState() => _PersonAttendanceMarkerReportState();
}

class _PersonAttendanceMarkerReportState extends State<PersonAttendanceMarkerReport> {

 List<ActivityAttendance> _personAttendanceReport = [];
 List<String?> _columnNames = [];
 var result_limit = 8;


 Future<List<ActivityAttendance>> refreshPersonActivityAttendanceReport() async{

     _personAttendanceReport = await getPersonActivityAttendanceReport(
        campusAppsPortalInstance.getUserPerson().id!,
        campusAppsPortalInstance.activityIds['school-day']!,
        result_limit
     );        
     
     _personAttendanceReport.removeWhere((dayAttendance) => [null].contains(dayAttendance.sign_in_time));

   _columnNames = _personAttendanceReport.map((dayAttendance) => dayAttendance.sign_in_time!.substring(0,10)).toList();
    
    print("columnnames"+"$_columnNames");
   return _personAttendanceReport;
 }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityAttendance>>(
      future: refreshPersonActivityAttendanceReport(),
      builder: (BuildContext context,AsyncSnapshot snapshot){

        if(snapshot.hasData){

        return SingleChildScrollView(
          //scrollDirection: Axis.horizontal,
          child: PaginatedDataTable(
            
            columns: _columnNames.map((columnName) => DataColumn(label:Text(columnName!))).toList(), 
            source: _PersonAttendanceMarkerReportDataSource(snapshot.data,_columnNames),
            rowsPerPage: 1,
            columnSpacing: 30.0,
            dataRowHeight: 40.0,
            ),
        );
        }else if(snapshot.hasError){
           return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
        },
      );
  }
}

class _PersonAttendanceMarkerReportDataSource extends DataTableSource{

 _PersonAttendanceMarkerReportDataSource(this._data,this.numberOfColumns);

  List<ActivityAttendance> _data;
  List<String?>  numberOfColumns = [];
  
  @override
  DataRow? getRow(int index) {
    if(index >= _data.length){
     return null;
    }
    List<DataCell> cells = [];
    print("index"+"$index");
    print("numberofcolumns"+"$numberOfColumns");


    int dataIndex=0;
    for (var property in numberOfColumns){
     var widget;
     if(_data[dataIndex].sign_in_time !=null){
        widget = Icon(
          Icons.check,
          color: Colors.black,
          size: 20.0,
        );
     }


      var cellWidget = DataCell(widget);
      cells.add(cellWidget);
      dataIndex++;
    }
      
    return DataRow(cells: cells);
  }
  
  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;
  
  @override
  // TODO: implement rowCount
  int get rowCount => 1;
  
  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
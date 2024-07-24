import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:gallery/data/campus_apps_portal.dart';

class ConsumableMonthlyReport extends StatefulWidget {
  const ConsumableMonthlyReport({super.key});

  @override
  State<ConsumableMonthlyReport> createState() => _ConsumableMonthlyReportState();
}

class _ConsumableMonthlyReportState extends State<ConsumableMonthlyReport> {
  List<StockReplenishment> _fetchedConsumableMonthlySummaryData = [];
  bool _isFetching = false;
  DateTime? _selected;

  late DataTableSource _data;

  List<DataColumn> dataTablecolumnNames = [];
  var activityId = 0;
  late int parentOrgId;

  @override
  void initState() {
    super.initState();
    parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(
        _fetchedConsumableMonthlySummaryData, updateSelected);
    // DateRangePicker(updateDateRange, formattedStartDate);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }
  
  List<DataColumn> _buildDataColumns() {
    List<DataColumn> columnNames = [];

    columnNames.add(DataColumn(
        label: Text('Product Name',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Opening Stock(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Replenishment(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Total(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Consumption(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Closing Stock(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    columnNames.add(DataColumn(
        label: Text('Unit',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    return columnNames;
  }

  Future<void> _onPressed({required BuildContext context,String? locale,}) async {

    final localeObj = locale != null ? Locale(locale) : null;

    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
      locale: localeObj,
    );

   if(selected !=null){
    setState(() {
      _isFetching = true;
    });
   }else{
    setState(() {
      _isFetching = false;
    });
   }
   
    if (selected != null) {

     int year = selected.year;
     int month = selected.month;

     _fetchedConsumableMonthlySummaryData = await getConsumableMonthlyReport(parentOrgId,year,month);

      setState(() {
        _selected = selected;
        _fetchedConsumableMonthlySummaryData;
        _isFetching = false;
        _data = MyData(_fetchedConsumableMonthlySummaryData,
            updateSelected);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Row(
                  children: [
                    Text(
                      'Select a Year & Month :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: ()=> _onPressed(context: context,locale: 'en'), 
                      child: Icon(Icons.calendar_month),
                    ),
                     if (_selected == null)
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        child: const Text(
                          'No month & year selected.',
                           style: TextStyle(
                            fontSize:14, 
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                    else
                      Container(
                        child: Text(
                          DateFormat.yMMMM().format(_selected!).toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal
                            ),
                          ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Wrap(children: [
                if (_isFetching)
                  Container(
                    margin: EdgeInsets.only(top: 180),
                    child: SpinKitCircle(
                      color: (Colors
                          .yellow[700]), // Customize the color of the indicator
                      size: 50, // Customize the size of the indicator
                    ),
                  )
                else if (_fetchedConsumableMonthlySummaryData.length > 0)
                  Container(
                    margin: EdgeInsets.only(left: 10.0,top: 20.0),
                    child: ScrollConfiguration(
                      behavior:
                          ScrollConfiguration.of(context).copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: _buildDataColumns(),
                        // header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 50,
                        horizontalMargin: 60,
                        rowsPerPage: 10,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text('No consumable monthly  summary data found'),
                  ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
   MyData(this._fetchedConsumableMonthlySummaryData,this.updateSelected);
 
  final List<StockReplenishment> _fetchedConsumableMonthlySummaryData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    
    
    if(_fetchedConsumableMonthlySummaryData.length > 0){

      List<DataCell> cells = List<DataCell>.filled(
          7, DataCell.empty);

      cells[0] =  DataCell(
              Center(child: Text(_fetchedConsumableMonthlySummaryData[index].consumable!.name.toString())));
      cells[1] =  DataCell(
              Center(child: Text(_fetchedConsumableMonthlySummaryData[index].quantity!.toStringAsFixed(2))));
      cells[2] =  DataCell(
              Center(child: Text(_fetchedConsumableMonthlySummaryData[index].quantity_in!.toStringAsFixed(2))));
      
      double? balance = (_fetchedConsumableMonthlySummaryData[index].quantity!) +
                        (_fetchedConsumableMonthlySummaryData[index].quantity_in!);

      cells[3] =  DataCell(
              Center(child: Text(balance.toStringAsFixed(2))));

      cells[4] =  DataCell(
              Center(child: Text(_fetchedConsumableMonthlySummaryData[index].quantity_out!.toStringAsFixed(2))));

      
      double? closingStock = (balance) - (_fetchedConsumableMonthlySummaryData[index].quantity_out!);

      cells[5] = DataCell(Center(child: Text(closingStock.toStringAsFixed(2))));

      cells[6] =  DataCell(
              Center(child: Text(_fetchedConsumableMonthlySummaryData[index].resource_property!.value.toString())));
      
      return DataRow(cells: cells);
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    if (_fetchedConsumableMonthlySummaryData.length > 0) {
      count = _fetchedConsumableMonthlySummaryData.length;
    }
    return count;
  }

  @override
  int get selectedRowCount => 0;
}

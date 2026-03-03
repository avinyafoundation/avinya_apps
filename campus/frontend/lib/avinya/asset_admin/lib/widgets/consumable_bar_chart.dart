import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/asset_admin/lib/data/consumable.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';

class ConsumableBarChart extends StatefulWidget {
  const ConsumableBarChart({super.key});

  @override
  State<ConsumableBarChart> createState() => _ConsumableBarChartState();
}

class _ConsumableBarChartState extends State<ConsumableBarChart> {
  Consumable? _selectedConsumableValue;
  late Future<List<Consumable>> _fetchConsumableData;
  DateTime _selectedYear = DateTime.now();
  bool _isFetching = false;
  String? _selectedConsumableUnitValue;

  List<StockReplenishment> _fetchedConsumableYearlySummaryData = [];
  List<double> _consumableItemQuantityInForYear = [];
  List<double> _consumableItemQuantityOutForYear = [];

  @override
  void initState() {
    super.initState();
    _fetchConsumableData = _loadConsumableData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<Consumable>> _loadConsumableData() async {
    return await fetchConsumables();
  }

  void _showPicker(BuildContext context) {
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text('Select a Year'),
              ],
            ),
            content: Container(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(DateTime.now().year - 100),
                lastDate: DateTime(DateTime.now().year + 120),
                initialDate: DateTime.now(),
                selectedDate: _selectedYear,
                onChanged: (DateTime dateTime) async {
                  Navigator.pop(context);
                  setState(() {
                    _selectedYear = dateTime;
                    _isFetching = true;
                  });

                  if (_selectedYear != null &&
                      _selectedConsumableValue != null) {
                    int? parentOrgId = campusAppsPortalInstance
                        .getUserPerson()
                        .organization!
                        .id;

                    _fetchedConsumableYearlySummaryData =
                        await getConsumableYearlyReport(parentOrgId!,
                            _selectedConsumableValue!.id!, _selectedYear.year);

                    _selectedConsumableUnitValue =
                        _fetchedConsumableYearlySummaryData
                            .first.resource_property!.value;

                    _consumableItemQuantityInForYear =
                        _fetchedConsumableYearlySummaryData
                            .map((consumableMonthObject) =>
                                consumableMonthObject.quantity_in!)
                            .toList();
                    _consumableItemQuantityOutForYear =
                        _fetchedConsumableYearlySummaryData
                            .map((consumableMonthObject) =>
                                consumableMonthObject.quantity_out!)
                            .toList();

                    setState(() {
                      _fetchedConsumableYearlySummaryData;
                      _consumableItemQuantityInForYear;
                      _consumableItemQuantityOutForYear;
                      _isFetching = false;
                    });
                  }
                },
              ),
            ),
          );
        }));
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(12, (i) {
      return BarChartGroupData(
        barsSpace: 5,
        x: i,
        barRods: [
          BarChartRodData(
            borderSide: BorderSide(width: 2.0),
            borderRadius: BorderRadius.zero,
            width: 20,
            toY: _getQuantityInValue(i),
            color: Colors.green,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, _getQuantityInValue(i), Colors.green),
            ],
          ),
          BarChartRodData(
            borderSide: BorderSide(width: 2.0),
            borderRadius: BorderRadius.zero,
            width: 20,
            toY: _getQuantityOutValue(i),
            color: Colors.red,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, _getQuantityOutValue(i), Colors.red),
            ],
          ),
        ],
      );
    });
  }

  double _getQuantityInValue(int month) {
    return _consumableItemQuantityInForYear[month];
  }

  double _getQuantityOutValue(int month) {
    return _consumableItemQuantityOutForYear[month];
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Center(child: const Text('Jan', style: style));
        break;
      case 1:
        text = Center(child: const Text('Feb', style: style));
        break;
      case 2:
        text = Center(child: const Text('Mar', style: style));
        break;
      case 3:
        text = Center(child: const Text('Apr', style: style));
        break;
      case 4:
        text = Center(child: const Text('May', style: style));
        break;
      case 5:
        text = Center(child: const Text('Jun', style: style));
        break;
      case 6:
        text = Center(child: const Text('Jul', style: style));
        break;
      case 7:
        text = Center(child: const Text('Aug', style: style));
        break;
      case 8:
        text = Center(child: const Text('Sep', style: style));
        break;
      case 9:
        text = Center(child: const Text('Oct', style: style));
        break;
      case 10:
        text = Center(child: const Text('Nov', style: style));
        break;
      default:
        text = Center(child: const Text('Dec', style: style));
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Consumable Yearly Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a Consumable :',
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 5.0,
            ),
            FutureBuilder<List<Consumable>>(
                future: _fetchConsumableData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      child: SpinKitCircle(
                        color: (Colors.yellow[700]),
                        size: 70,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong...'),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No consumable data found'),
                    );
                  }
                  final consumableData = snapshot.data!;
                  return DropdownButton<Consumable>(
                      value: _selectedConsumableValue,
                      items: consumableData.map((Consumable consumable) {
                        return DropdownMenuItem(
                            value: consumable,
                            child: Text(consumable.name! ?? ''));
                      }).toList(),
                      onChanged: (Consumable? newValue) async {
                        if (newValue == null) {
                          return;
                        }

                        int consumableId = newValue.id!;

                        int? parentOrgId = campusAppsPortalInstance
                            .getUserPerson()
                            .organization!
                            .id;

                        _fetchedConsumableYearlySummaryData =
                            await getConsumableYearlyReport(
                                parentOrgId!, consumableId, _selectedYear.year);

                        _selectedConsumableUnitValue =
                            _fetchedConsumableYearlySummaryData
                                .first.resource_property!.value;

                        _consumableItemQuantityInForYear =
                            _fetchedConsumableYearlySummaryData
                                .map((consumableMonthObject) =>
                                    consumableMonthObject.quantity_in!)
                                .toList();
                        _consumableItemQuantityOutForYear =
                            _fetchedConsumableYearlySummaryData
                                .map((consumableMonthObject) =>
                                    consumableMonthObject.quantity_out!)
                                .toList();

                        setState(() {
                          _fetchedConsumableYearlySummaryData;
                          _selectedConsumableValue = newValue;
                          _consumableItemQuantityInForYear;
                          _consumableItemQuantityOutForYear;
                        });
                      });
                }),
            const SizedBox(
              width: 20.0,
            ),
            Text(
              'Select a Year:',
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 5,
            ),
            TextButton(
              onPressed: () => _showPicker(context),
              child: Icon(Icons.calendar_month),
            ),
            if (_selectedYear == null)
              Container(
                margin: EdgeInsets.only(left: 10.0),
                child: const Text(
                  'No year selected.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            else
              Container(
                child: Text(
                  _selectedYear.year.toString(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
            SizedBox(
              width: 20.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
            SizedBox(
              width: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ],
        ),
        const SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Unit - ${_selectedConsumableUnitValue ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70.0,
                  height: 30.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Quantity In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                  child: Container(
                    width: 20,
                    height: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80.0,
                    height: 30.0,
                    child: Text(
                      'Quantity Out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        if (_consumableItemQuantityInForYear.length > 0 &&
            _consumableItemQuantityOutForYear.length > 0)
          Container(
            height: screenHeight * 0.5,
            child: BarChart(
              BarChartData(
                groupsSpace: 30.0,
                alignment: BarChartAlignment.spaceAround,
                barGroups: _getBarGroups(),
                titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            getTitlesWidget: getTitles,
                            showTitles: true,
                            reservedSize: 50))),
                gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false),
              ),
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

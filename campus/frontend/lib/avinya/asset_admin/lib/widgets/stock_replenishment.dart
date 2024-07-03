import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
// import 'package:asset_admin/data/stock_repenishment.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StockReplenishmentForm extends StatefulWidget {
  const StockReplenishmentForm({Key? key, required this.title})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<StockReplenishmentForm> createState() => _StockReplenishmentState();
}

class _StockReplenishmentState extends State<StockReplenishmentForm> {
  List<StockReplenishment> _fetchedStockList = [];
  List<StockReplenishment> _fetchedStockListAfterSchool = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;
  List<Person> _fetchedStudentList = [];

  bool _isSubmitting = false;
  bool _isUpdate = false;
  //calendar specific variables
  DateTime? _selectedDay;

  List<TextEditingController> _controllers = [];
  DateTime _selectedDate = DateTime.now();

  late DataTableSource _data;
  List<String?> columnNames = [];
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  bool _isDisplayErrorMessage = false;

  var today = DateTime.now();

  // DateTime? _selectedDate;
  late TextEditingController _controller;
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }

    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        setState(() {
          refreshState(DateFormat('yyyy-MM-dd').format(_selectedDate!));
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // var today = DateTime.now();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    _selectedDate = DateTime.now();
    _fetchInitialData();
    // selectWeek(today, activityId);
  }

  void _initializeControllers() {
    _controllers = _fetchedStockList.map((item) {
      DateTime isToday = DateTime.now();
      return TextEditingController(
        text:
            _selectedDate == isToday ? '' : item.quantity_in?.toString() ?? '',
      );
    }).toList();
  }

  @override
  void dispose() {
    // Perform any cleanup tasks here
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization?.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Show loading indicator
      });
      try {
        await refreshState(DateFormat('yyyy-MM-dd').format(_selectedDate!));
      } catch (error) {
        // Handle any errors that occur during the fetch
        // You can show an error message or take appropriate actions here
      } finally {
        setState(() {
          _isFetching = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Perform any initialization that depends on context
    // _pickDate(context);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  Future<void> refreshState(String? newValue) async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    _selectedValue = newValue ?? null;

    _fetchedStockList =
        await getStockListforReplenishment(parentOrgId, newValue!);
    Person person = campusAppsPortalInstance.getUserPerson();

    var formattedDate = formatDateTime(_selectedDate!);
    for (var item in _fetchedStockList) {
      int? avinya_type_id = item.avinya_type?.id;
      item.avinya_type_id = avinya_type_id;
      item.person_id = person.id;
      item.consumable_id = item.consumable!.id;
      item.updated = formattedDate;
      item.organization_id = parentOrgId;
    }

    _initializeControllers();

    if (mounted) {
      setState(() {
        _fetchedStockList;
        _isFetching =
            false; // Ensure _isFetching is set to false after fetching
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    var result = await addConsumableReplenishment(_fetchedStockList);

    // Add your form submission logic here

    setState(() {
      _isSubmitting = false;
      _isUpdate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Please go to 'Mark Attendance' Page",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 200,
                      child: TextField(
                        readOnly: true,
                        onTap: () => _pickDate(context),
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : '${_selectedDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _isFetching
                      ? Center(
                          child: SpinKitCircle(
                            color: Colors.deepPurpleAccent,
                            size: 50,
                          ),
                        )
                      : _fetchedStockList.isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(
                                            label: Text(
                                          "Product Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          "Quantity",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          "On Hand",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          "Total",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          "Unit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ],
                                      rows: _fetchedStockList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        StockReplenishment item = entry.value;
                                        double totalQuantityIn =
                                            (item.quantity_in ?? 0.0) +
                                                (item.quantity ?? 0.0);
                                        DateTime isToday = DateTime.now();
                                        _controller = TextEditingController(
                                          text: _selectedDate != null &&
                                                  _selectedDate == isToday
                                              ? ''
                                              : item.quantity_in?.toString() ??
                                                  '',
                                        );
                                        // _controller.addListener(() {
                                        //   final text = _controller.text;
                                        //   final quantity_in =
                                        //       int.tryParse(text);
                                        //   if (quantity_in != null) {
                                        //     setState(() {
                                        //       item.quantity_in = quantity_in;
                                        //       totalQuantityIn =
                                        //           (item.quantity_in ?? 0) +
                                        //               (item.quantity ?? 0);
                                        //     });
                                        //   }
                                        // });
                                        return DataRow(cells: [
                                          DataCell(
                                              Text(item.consumable!.name!)),
                                          DataCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 2.0),
                                              child: TextField(
                                                controller: _controllers[index],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^\d*\.?\d{0,2}')),
                                                ],
                                                onChanged:
                                                    (String value) async {
                                                  double? quantity_in =
                                                      double.tryParse(value);
                                                  if (quantity_in != null) {
                                                    print(
                                                        'Quantity: $quantity_in');
                                                    setState(() {
                                                      item.quantity_in =
                                                          quantity_in;
                                                      totalQuantityIn =
                                                          (item.quantity_in ??
                                                                  0.0) +
                                                              (item.quantity ??
                                                                  0.0);
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  hintText: item.quantity_in
                                                          ?.toString() ??
                                                      'Enter quantity',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                              Text(item.quantity!.toString())),
                                          DataCell(
                                              Text(totalQuantityIn.toString())),
                                          DataCell(Text(item
                                              .resource_property!.value!
                                              .toString())),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text('No data found'),
                            ),
                  if (!_isFetching && _fetchedStockList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 120, // Set the width of the button
                          // child: ElevatedButton(
                          //   onPressed: _isSubmitting ? null : _handleSubmit,
                          //   style: ElevatedButton.styleFrom(
                          //     primary: Colors.deepPurple, // Change button color
                          //     elevation: 4, // Add elevation
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Text(
                          //       _isUpdate ? 'Update' : 'Save',
                          //       style: TextStyle(
                          //         fontSize: 16, // Increase font size
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.white, // Change text color
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(16.0)),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 16),
                              ),
                              elevation: MaterialStateProperty.all(20),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.greenAccent),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                            ),
                            child: Text(
                              _isUpdate ? 'Update' : 'Save',
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StockReplenishmentForm extends StatefulWidget {
  const StockReplenishmentForm({Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  State<StockReplenishmentForm> createState() => _StockReplenishmentState();
}

class _StockReplenishmentState extends State<StockReplenishmentForm> {
  List<StockReplenishment> _fetchedStockList = [];
  List<StockReplenishment> _fetchedStockListAfterSchool = [];
  List<StockReplenishment> result = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;
  bool _isAfter = false;
  List<Person> _fetchedStudentList = [];
  Person? _person;
  String? formatted_date;
  int? parent_org_id;

  bool _isSubmitting = false;
  bool _isUpdate = false;
  bool _showQtyIn = false;
  bool _backDate = false;
  double prevQtyIn = 0.00;
  int prevIndex = 0;
  //calendar specific variables
  DateTime? _selectedDay;

  List<TextEditingController> _controllers = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _fetcheddDate = DateTime.now();

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
      DateTime isToday = DateTime.now();
      _isAfter = picked.isAfter(isToday);
      setState(() {
        _selectedDate = picked;
        _isAfter = _isAfter;
        prevQtyIn = 0.00;
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
          refreshState(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!));
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
        text: _showQtyIn ? item.quantity_in?.toString() : '0',
        // text:
        //     _selectedDate == isToday ? '' : item.quantity_in?.toString() ?? '',
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
        await refreshState(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!));
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

    var formattedDate = formatDateTime(_selectedDate);

    for (var item in _fetchedStockList) {
      if (item.updated != null) {
        DateTime itemDate = DateTime.parse(item.updated!).toLocal();
        DateTime itemDateOnly =
            DateTime(itemDate.year, itemDate.month, itemDate.day);
        DateTime currentDate = DateTime.now().toLocal();
        if (item.quantity_out != 0) {
          if (_selectedDate.day == currentDate.day) {
            _isSubmitting = false;
            _showQtyIn = false;
            _backDate = false;
            _isUpdate = false;
          } else {
            _isUpdate = true;
            _backDate = false;
            _isSubmitting = true;
            _showQtyIn = false;
            // this is a depletion
          }
        } else {
          if (_selectedDate.year == currentDate.year &&
              _selectedDate.month == currentDate.month &&
              _selectedDate.day == currentDate.day) {
            if (_selectedDate.isAfter(itemDateOnly) &&
                item.quantity_in != 0 &&
                _selectedDate.day != itemDateOnly.day) {
              _showQtyIn = false;
              _backDate = false;
              _isUpdate = false;
            } else {
              _isSubmitting = false;
              _showQtyIn = false;
              _backDate = false;
              _isUpdate = false;
            }
          } else if (_selectedDate.isBefore(currentDate)) {
            if (_selectedDate.isAfter(itemDateOnly) && item.quantity_in != 0) {
              _isSubmitting = false;
              _showQtyIn = false;
              _backDate = false;
              _isUpdate = false;
              break;
            } else if (_selectedDate.isBefore(itemDateOnly)) {
              _isSubmitting = true;
              _showQtyIn = true;
              _backDate = true;
              _isUpdate = true;
            } else {
              _isSubmitting = true;
              _backDate = false;
              _showQtyIn = true;
              _isUpdate = true;
            }
          } else {
            _isSubmitting = false;
            _showQtyIn = false;
            _backDate = false;
            _isUpdate = false;
          }
        }
      } else {
        _isSubmitting = false;
        _showQtyIn = false;
        _backDate = false;
        _isUpdate = false;
      }
    }

    _fetchedStockList.map((item) {
      if (item.quantity_in != 0) {
        if (item.updated != null) {
          _fetcheddDate = DateTime.parse(item.updated!);
        }
      }
    }).toList();

    if (mounted) {
      setState(() {
        _fetchedStockList;
        _person = person;
        _isSubmitting = _isSubmitting;
        _backDate = _backDate;
        _showQtyIn = _showQtyIn;
        _fetcheddDate = _fetcheddDate;
        _isUpdate = _isUpdate;
        formatted_date = formattedDate;
        parent_org_id = parentOrgId;
        _isFetching =
            false; // Ensure _isFetching is set to false after fetching
      });
    }

    _initializeControllers();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_showQtyIn || _isUpdate) {
      result = await updateConsumableReplenishment(
          _fetchedStockList, this.formatted_date);
    } else {
      result = await addConsumableReplenishment(_fetchedStockList,
          this._person?.id, this.parent_org_id, this.formatted_date, _isUpdate);
    }

    setState(() {
      refreshState(DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate));
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
                      : _backDate != true
                          ? _fetchedStockList.isNotEmpty
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
                                            StockReplenishment item =
                                                entry.value;
                                            _controller = TextEditingController(
                                              text: _isAfter
                                                  ? '0'
                                                  : item.quantity_in
                                                          ?.toString() ??
                                                      '',
                                            );
                                            return DataRow(cells: [
                                              DataCell(
                                                  Text(item.consumable!.name!)),
                                              DataCell(
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 2.0),
                                                  child: TextField(
                                                    controller:
                                                        _controllers[index],
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
                                                          double.tryParse(
                                                              value);
                                                      if (quantity_in != null) {
                                                        print(
                                                            'Quantity: $quantity_in');
                                                        setState(() {
                                                          item.quantity_in =
                                                              quantity_in;
                                                          prevQtyIn = (item
                                                                  .quantity_in ??
                                                              0.0);
                                                          prevIndex = index;

                                                          if (_showQtyIn) {
                                                            item.total_quantity =
                                                                (item.quantity_in ??
                                                                        0.0) +
                                                                    (item.prev_quantity ??
                                                                        0.0);
                                                          } else {
                                                            item.total_quantity =
                                                                double.tryParse(
                                                                        value)! +
                                                                    (item.quantity ??
                                                                        0.0);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    enabled: !_isSubmitting,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(_showQtyIn
                                                    ? item.prev_quantity!
                                                        .toString()
                                                    : item.quantity!
                                                        .toString()),
                                              ),
                                              DataCell(Text(item.total_quantity
                                                  .toString())),
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
                                )
                          : Text("Please Select Valid Date"),
                  if (!_isFetching && _fetchedStockList.isNotEmpty)
                    _backDate != true
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 120,
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting ? null : _handleSubmit,
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(16.0)),
                                    textStyle:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return TextStyle(
                                            fontSize: 16, color: Colors.grey);
                                      }
                                      return TextStyle(
                                          fontSize: 16, color: Colors.black);
                                    }),
                                    elevation:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return 0.0;
                                      }
                                      return 20.0;
                                    }),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey.shade400;
                                      }
                                      return Colors.greenAccent;
                                    }),
                                    foregroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey.shade700;
                                      }
                                      return Colors.black;
                                    }),
                                  ),
                                  child: Text(
                                    _isUpdate ? 'Update' : 'Save',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(""),
                ],
              ),
            ),
    );
  }
}

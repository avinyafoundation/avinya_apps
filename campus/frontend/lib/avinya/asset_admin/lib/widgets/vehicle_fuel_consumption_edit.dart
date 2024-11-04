import 'package:flutter/material.dart';

class VehicleFuelConsumptionEdit extends StatefulWidget {
  const VehicleFuelConsumptionEdit({super.key});

  @override
  State<VehicleFuelConsumptionEdit> createState() =>
      _VehicleFuelConsumptionEditState();
}

class _VehicleFuelConsumptionEditState
    extends State<VehicleFuelConsumptionEdit> {
  DateTime? _selectedDate;
  String reasonValue = 'Student Shuttle-Morning';
  final List<String> reasonValues = [
    'Student Shuttle-Morning',
    'Student Shuttle-Evening',
    'Other'
  ];
  String vehicleNoValue = 'QL-9904';
  final List<String> vehicleNoValues = ['QL-9904', 'PB-2010', 'KV-1892'];
  final _starting_meter_controller = TextEditingController();
  final _ending_meter_controller = TextEditingController();
  final _comment_controller = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _starting_meter_controller.dispose();
    _ending_meter_controller.dispose();
    _comment_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 30.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Select a Date :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 30.0),
                width: screenWidth * 0.05,
                height: screenHeight * 0.06,
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month),
                      border: InputBorder.none),
                  onTap: () => _selectDate(context),
                ),
              ),
            ),
            if (_selectedDate != null)
              Flexible(
                  flex: 1,
                  child: Text('${_selectedDate!.toLocal()}'.split(' ')[0]))
            else
              Flexible(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: const Text(
                    'No date selected.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Select a Reason :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                width: screenWidth * 0.17,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(5.0)),
                child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    value: reasonValue,
                    items: reasonValues.map((String? reason) {
                      return DropdownMenuItem<String>(
                          value: reason, child: Text(reason ?? ''));
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue == null) {
                        return;
                      }
                      setState(() {
                        reasonValue = newValue;
                      });
                    }),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Vehicle No :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 50.0),
                width: screenWidth * 0.08,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(5.0)),
                child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    value: vehicleNoValue,
                    items: vehicleNoValues.map((String? vehicleNo) {
                      return DropdownMenuItem<String>(
                          value: vehicleNo, child: Text(vehicleNo ?? ''));
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue == null) {
                        return;
                      }
                      setState(() {
                        vehicleNoValue = newValue;
                      });
                    }),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Starting Meter :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 30.0),
                width: screenWidth * 0.2,
                height: screenHeight * 0.08,
                child: TextField(
                  maxLength: 20,
                  keyboardType: TextInputType.number,
                  controller: _starting_meter_controller,
                  decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Ending Meter :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 35.0),
                width: screenWidth * 0.2,
                height: screenHeight * 0.08,
                child: TextField(
                  maxLength: 20,
                  keyboardType: TextInputType.number,
                  controller: _ending_meter_controller,
                  decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'Comment :',
                style: TextStyle(
                    fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 55.0),
                width: screenWidth * 0.2,
                height: screenHeight * 0.2,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  controller: _comment_controller,
                  decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0))),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.1,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      backgroundColor: Colors.yellow[700],
                      side: BorderSide(
                        color: Colors.grey.shade500,
                        width: 0.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    onPressed: (() {}),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    )),
              ),
            ),
          ],
        )
      ]),
    );
  }
}

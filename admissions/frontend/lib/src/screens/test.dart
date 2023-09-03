import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subject Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SubjectSelectionPage(),
    );
  }
}

class SubjectSelectionPage extends StatefulWidget {
  @override
  _SubjectSelectionPageState createState() => _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends State<SubjectSelectionPage> {
  String selectedOption = 'Arts';
  List<String> selectedOptionSubjects = [];
  Map<String, List<String>> optionSubjects = {
    'Arts': [
      'Arabic',
      'Art',
      //... list of subjects for Arts
    ],
    'Commerce': [
      'Accounting',
      'Business',
      //... list of subjects for Commerce
    ],
    'Bio Science': [
      'Agriculture',
      'Bio System Technology',
      //... list of subjects for Bio Science
    ],
    'Physical Science (Maths)': [
      'Chemistry',
      'Combine Mathematics',
      //... list of subjects for Physical Science (Maths)
    ],
    'Technology': [
      'Agro Technology',
      'Engineering Technology',
      //... list of subjects for Technology
    ],
  };

  String selectedSubject = '';
  String selectedResult = 'A';

  @override
  void initState() {
    super.initState();
    selectedOptionSubjects = optionSubjects[selectedOption]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject Selection'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                selectedOption = newValue!;
                selectedOptionSubjects = optionSubjects[newValue!]!;
                selectedSubject = '';
              });
            },
            items: optionSubjects.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedSubject,
            onChanged: (String? newValue) {
              setState(() {
                selectedSubject = newValue!;
              });
            },
            items: selectedOptionSubjects
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedResult,
            onChanged: (String? newValue) {
              setState(() {
                selectedResult = newValue!;
              });
            },
            items: <String>['A', 'B', 'C', 'D', 'F']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          buildResultTable(),
        ],
      ),
    );
  }

  Widget buildResultTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(2.0),
        1: FlexColumnWidth(1.0),
      },
      children: <TableRow>[
        buildTableRow(['Subject', 'Result']),
        buildTableRow([buildSubjectDropdown(), buildResultDropdown()]),
      ],
    );
  }

  Widget buildSubjectDropdown() {
    return DropdownButton<String>(
      value: selectedSubject,
      onChanged: (String? newValue) {
        setState(() {
          selectedSubject = newValue!;
        });
      },
      items:
          selectedOptionSubjects.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildResultDropdown() {
    return DropdownButton<String>(
      value: selectedResult,
      onChanged: (String? newValue) {
        setState(() {
          selectedResult = newValue!;
        });
      },
      items: <String>['A', 'B', 'C', 'D', 'F']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  TableRow buildTableRow(List<dynamic> values) {
    return TableRow(
      children: values
          .map((value) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: value is Widget ? value : Text(value),
                ),
              ))
          .toList(),
    );
  }
}

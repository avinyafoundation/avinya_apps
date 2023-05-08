import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';

import '../data.dart';

class ResourceAllocationList extends StatefulWidget {
  const ResourceAllocationList({super.key, this.onTap});
  final ValueChanged<ResourceAllocation>? onTap;

  @override
  ResourceAllocationListState createState() =>
      ResourceAllocationListState(onTap);
}

class ResourceAllocationListState extends State<ResourceAllocationList> {
  late Future<List<ResourceAllocation>> futureResourceAllocations;
  final ValueChanged<ResourceAllocation>? onTap;

  ResourceAllocationListState(this.onTap);

  @override
  void initState() {
    super.initState();

    int? person_id = campusAppsPortalInstance.getUserPerson().id;
    futureResourceAllocations = fetchResourceAllocations(
        person_id!); // for now get notes for activity id 1
  }

  Future<List<ResourceAllocation>> refreshResourceAllocationState() async {
    int? person_id = campusAppsPortalInstance.getUserPerson().id;
    futureResourceAllocations = fetchResourceAllocations(person_id!);
    return futureResourceAllocations;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ResourceAllocation>>(
      future: refreshResourceAllocationState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setResourceAllocations(snapshot.data);
          if (snapshot.data!.length > 0) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListTile(
                  title: Text(
                    (snapshot.data![index].asset!.model!.toString()),
                  ),
                  subtitle: Text(
                    ' ' +
                        (snapshot.data![index].asset!.name!.toString()) +
                        ' | ' +
                        snapshot.data![index].quantity!.toString() +
                        ' | ' +
                        snapshot.data![index].startDate!.toString() +
                        ' | ' +
                        snapshot.data![index].endDate!.toString() +
                        ' | ',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                  ),
                  onTap:
                      onTap != null ? () => onTap!(snapshot.data![index]) : null
                  // print((snapshot.data![index].asset!.name!.toString())
                  ),
            );
          } else {
            return const Center(
              child: Text('No Resource Allocations'),
            );
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class AddResourceAllocationPage extends StatefulWidget {
  static const String route = '/resource_allocation/add';
  const AddResourceAllocationPage({super.key});
  @override
  _AddResourceAllocationPageState createState() =>
      _AddResourceAllocationPageState();
}

class _AddResourceAllocationPageState extends State<AddResourceAllocationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<AvinyaType>> futureAvinyaTypes;

  var _selectedValue;
  AvinyaType? _selectedAvinyaType;
  List<AvinyaType> _avinyaTypes = [];
  Asset? _selectedAsset;

  // late TextEditingController asset_Controller;
  // late FocusNode asset_FocusNode;
  // late Asset selectedAsset;

  late TextEditingController quantity_Controller;
  late FocusNode quantity_FocusNode;

  late TextEditingController startDate_Controller;
  late FocusNode startDate_FocusNode;

  late TextEditingController endDate_Controller;
  late FocusNode endDate_FocusNode;

  // late TextEditingController purpose_Controller;
  // late FocusNode purpose_FocusNode;

  @override
  void initState() {
    super.initState();
    // asset_Controller = TextEditingController();
    // asset_FocusNode = FocusNode();

    futureAvinyaTypes = fetchAvinyaTypesByAsset();

    quantity_Controller = TextEditingController();
    quantity_FocusNode = FocusNode();

    startDate_Controller = TextEditingController();
    startDate_FocusNode = FocusNode();

    endDate_Controller = TextEditingController();
    endDate_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    // asset_Controller.dispose();
    // asset_FocusNode.dispose();

    quantity_Controller.dispose();
    quantity_FocusNode.dispose();

    startDate_Controller.dispose();
    startDate_FocusNode.dispose();

    endDate_Controller.dispose();
    endDate_FocusNode.dispose();

    super.dispose();
  }

  Future<List<AvinyaType>> refreshAvinyaTypesState() async {
    futureAvinyaTypes = fetchAvinyaTypesByAsset();
    return futureAvinyaTypes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Resource Allocation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Asset you want to request'),
              // TextFormField(
              //   controller: asset_Controller,
              //   decoration: const InputDecoration(labelText: 'asset'),
              //   onFieldSubmitted: (_) {
              //     asset_FocusNode.requestFocus();
              //   },
              //   validator: _mandatoryValidator,
              // ),
              DropdownButton<AvinyaType>(
                value: _selectedAvinyaType,
                hint: const Text('Select Asset Type'),
                onChanged: (AvinyaType? newValue) async {
                  _selectedAvinyaType = newValue;
                  print(newValue?.name);
                  _avinyaTypes = await fetchAvinyaTypesByAsset();

                  setState(() {});
                },
                items: campusConfigSystemInstance.avinyaTypes
                    ?.map<DropdownMenuItem<AvinyaType>>((AvinyaType value) {
                  return DropdownMenuItem<AvinyaType>(
                    value: value,
                    child: Text(value.name!),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: quantity_Controller,
                decoration: const InputDecoration(labelText: 'quantity'),
                onFieldSubmitted: (_) {
                  quantity_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: startDate_Controller,
                decoration: const InputDecoration(labelText: 'start date'),
                onFieldSubmitted: (_) {
                  startDate_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: endDate_Controller,
                decoration: const InputDecoration(labelText: 'end date'),
                onFieldSubmitted: (_) {
                  endDate_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              // TextFormField(
              //   controller: purpose_Controller,
              //   decoration: const InputDecoration(labelText: 'purpose'),
              //   onFieldSubmitted: (_) {
              //     purpose_FocusNode.requestFocus();
              //   },
              //   validator: _mandatoryValidator,
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _AddResourceAllocation(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _AddResourceAllocation(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final ResourceAllocation resourceAllocation = ResourceAllocation(
          // asset: Asset(id: int.parse(asset_Controller.text)),
          quantity: int.parse(quantity_Controller.text),
          startDate: DateTime.parse(startDate_Controller.text),
          endDate: DateTime.parse(endDate_Controller.text),
          // purpose: purpose_Controller.text,
        );
        await createResourceAllocation(resourceAllocation);
        Navigator.of(context).pop(true);
        // final bool result = await ResourceAllocationService.addResourceAllocation(resourceAllocation);
        // final String message = result ? 'Resource Allocation added' : 'Error adding Resource Allocation';
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        // Navigator.pop(context);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Resource Allocation'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }
}

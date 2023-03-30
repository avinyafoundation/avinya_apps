import 'package:flutter/material.dart';

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
    futureResourceAllocations =
        fetchResourceAllocations(10); // for now get notes for activity id 1
  }

  Future<List<ResourceAllocation>> refreshResourceAllocationState() async {
    futureResourceAllocations = fetchResourceAllocations(10);
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

  late TextEditingController asset_Controller;
  late FocusNode asset_FocusNode;
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
    asset_Controller = TextEditingController();
    asset_FocusNode = FocusNode();

    quantity_Controller = TextEditingController();
    quantity_FocusNode = FocusNode();

    startDate_Controller = TextEditingController();
    startDate_FocusNode = FocusNode();

    endDate_Controller = TextEditingController();
    endDate_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    asset_Controller.dispose();
    asset_FocusNode.dispose();

    quantity_Controller.dispose();
    quantity_FocusNode.dispose();

    startDate_Controller.dispose();
    startDate_FocusNode.dispose();

    endDate_Controller.dispose();
    endDate_FocusNode.dispose();

    super.dispose();
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
                  'Fill in the details of the AvinyaType you want to add'),
              TextFormField(
                controller: asset_Controller,
                decoration: const InputDecoration(labelText: 'asset'),
                onFieldSubmitted: (_) {
                  asset_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
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
          asset: Asset(id: int.parse(asset_Controller.text)),
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
  

// class _SelectAvinyaTypePageState extends State<SelectAvinyaTypePage> {
//   late Future<List<AvinyaType>> futureAvinyaTypes;
//   final ValueChanged<AvinyaType>? onTap;

//   _SelectAvinyaTypePageState(this.onTap);

//   late TextEditingController avinyaType_Controller;
//   late FocusNode avinyaType_FocusNode;
//   late AvinyaType selectedAvinyaType;

//   @override
//   void initState() {
//     super.initState();
//     avinyaType_Controller = TextEditingController();
//     avinyaType_FocusNode = FocusNode();

//     futureAvinyaTypes = fetchAvinyaTypesByAsset();
//   }

//   Future<List<AvinyaType>> refreshAvinyaTypesState() async {
//     futureAvinyaTypes = fetchAvinyaTypesByAsset();
//     return futureAvinyaTypes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: FutureBuilder<List<AvinyaType>>(
//           future: refreshAvinyaTypesState(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               campusConfigSystemInstance.setAvinyaTypes(snapshot.data);
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   DropdownButton(
//                     hint: Text("Select Avinya Type"),
//                     items: snapshot.data?.map((AvinyaType value) {
//                       return DropdownMenuItem<AvinyaType>(
//                         value: value,
//                         child: Text(value.name ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (AvinyaType? value) {
//                       setState(() {
//                         avinyaType_Controller.text = value?.name ?? '';
//                         selectedAvinyaType = value!;
//                       });
//                     },
//                   ),
//                   TextField(
//                     focusNode: avinyaType_FocusNode,
//                     controller: avinyaType_Controller,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         onTap!(selectedAvinyaType);
//                         // onTap != null ? () => onTap!(selectedActivity) : null;
//                       },
//                       child: Text("View Notes"),
//                     ),
//                   )
//                 ],
//               );
//             } else if (snapshot.hasError) {
//               return Text("${snapshot.error}");
//             }
//             return CircularProgressIndicator();
//           },
//         ),
//       ),
//     );
//   }
// }

// Future<Asset> _getAsset() async {
//   return fetchAssetByAvinyaType(421);
// }

// class AllocateAssetPage extends StatefulWidget {
//   //static const String route = '/allocate_asset';
//   const AllocateAssetPage({super.key, this.onTap});
//   final ValueChanged<Asset>? onTap;

//   @override
//   _AllocateAssetPageState createState() => _AllocateAssetPageState(onTap);
// }

// // class AvinyaTypeListState extends State<AvinyaTypeList> {
// //   late Future<List<AvinyaType>> futureAvinyaTypes;
// //   final ValueChanged<AvinyaType>? onTap;

// //   AvinyaTypeListState(this.onTap);

// //   @override
// //   void initState() {
// //     super.initState();
// //     futureAvinyaTypes = fetchAvinyaTypes();
// //   }

// //   Future<List<AvinyaType>> refreshAvinyaTypeState() async {
// //     futureAvinyaTypes = fetchAvinyaTypes();
// //     return futureAvinyaTypes;
// //   }

// class _AllocateAssetPageState extends State<AllocateAssetPage> {
//   late Future<List<Asset>> futureAssets;
//   final ValueChanged<Asset>? onTap;

//   _AllocateAssetPageState(this.onTap);

//   late TextEditingController asset_Controller;
//   late FocusNode asset_FocusNode;
//   late Asset selectedAsset;

//   @override
//   void initState() {
//     super.initState();
//     asset_Controller = TextEditingController();
//     asset_FocusNode = FocusNode();

//     // futureAssets = fetchAssetsByAvinyaType(421);
//   }

//   Future<List<Asset>> refreshAssetState() async {
//     //futureAssets = fetchAssetsByAvinyaType(421);
//     return futureAssets;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: FutureBuilder<List<Asset>>(
//           future: refreshAssetState(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               campusConfigSystemInstance.setAssets(snapshot.data);
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   DropdownButton(
//                     hint: Text("Select Asset"),
//                     items: snapshot.data?.map((Asset value) {
//                       return DropdownMenuItem<Asset>(
//                         value: value,
//                         child: Text(value.name ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (Asset? value) {
//                       setState(() {
//                         asset_Controller.text = value?.name ?? '';
//                         selectedAsset = value!;
//                       });
//                     },
//                   ),
//                   TextField(
//                     focusNode: asset_FocusNode,
//                     controller: asset_Controller,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         onTap!(selectedAsset);
//                         // onTap != null ? () => onTap!(selectedActivity) : null;
//                       },
//                       child: Text("View Notes"),
//                     ),
//                   )
//                 ],
//               );
//             } else if (snapshot.hasError) {
//               return Text("${snapshot.error}");
//             }
//             return CircularProgressIndicator();
//           },
//         ),
//       ),
//     );
//   }
// }























// import 'package:flutter/material.dart';

// import '../data.dart';

// class ResourceAllocationList extends StatefulWidget {
//   const ResourceAllocationList({super.key, this.onTap});
//   final ValueChanged<ResourceAllocation>? onTap;

//   @override
//   ResourceAllocationListState createState() =>
//       ResourceAllocationListState(onTap);
// }

// class ResourceAllocationListState extends State<ResourceAllocationList> {
//   late Future<List<ResourceAllocation>> futureResourceAllocations;
//   final ValueChanged<ResourceAllocation>? onTap;

//   ResourceAllocationListState(this.onTap);

//   @override
//   void initState() {
//     super.initState();
//     // futureResourceAllocations = fetchResourceAllocationsByPersonId(1);
//   }

//   Future<List<ResourceAllocation>> refreshResourceAllocationState() async {
//     //  futureResourceAllocations = fetchResourceAllocationsByPersonId(1);
//     return futureResourceAllocations;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<ResourceAllocation>>(
//       future: refreshResourceAllocationState(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) => ListTile(
//               title: Text(
//                 (snapshot.data![index].asset!.model.toString()),
//               ),
//               subtitle: Text(
//                 ' ' +
//                     snapshot.data![index].asset!.name.toString() +
//                     ' ' +
//                     snapshot.data![index].start_date.toString() +
//                     ' ' +
//                     snapshot.data![index].end_date.toString() +
//                     ' ' +
//                     snapshot.data![index].asset!.registrationNumber.toString() +
//                     ' ',
//               ),
//               onTap: onTap != null ? () => onTap!(snapshot.data![index]) : null,
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Text("${snapshot.error}");
//         }
//         return const CircularProgressIndicator();
//       },
//     );
//   }
// }

// class AddResourceAllocationPage extends StatefulWidget {
//   static const String route = '/resource_allocation/add';
//   const AddResourceAllocationPage({super.key});
//   @override
//   _AddResourceAllocationPageState createState() =>
//       _AddResourceAllocationPageState();
// }

// class _AddResourceAllocationPageState extends State<AddResourceAllocationPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late TextEditingController _selectDevice_Controller;
//   late FocusNode _selectDevice_FocusNode;
//   late TextEditingController _quantity_Controller;
//   late FocusNode _quantity_FocusNode;
//   late TextEditingController _startDate_Controller;
//   late FocusNode _startDate_FocusNode;
//   late TextEditingController _endDate_Controller;
//   late FocusNode _endDate_FocusNode;
//   late TextEditingController _description_Controller;
//   late FocusNode _description_FocusNode;

//   @override
//   void initState() {
//     super.initState();
//     _selectDevice_Controller = TextEditingController();
//     _selectDevice_FocusNode = FocusNode();
//     _quantity_Controller = TextEditingController();
//     _quantity_FocusNode = FocusNode();
//     _startDate_Controller = TextEditingController();
//     _startDate_FocusNode = FocusNode();
//     _endDate_Controller = TextEditingController();
//     _endDate_FocusNode = FocusNode();
//     _description_Controller = TextEditingController();
//     _description_FocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _selectDevice_Controller.dispose();
//     _selectDevice_FocusNode.dispose();
//     _quantity_Controller.dispose();
//     _quantity_FocusNode.dispose();
//     _startDate_Controller.dispose();
//     _startDate_FocusNode.dispose();
//     _endDate_Controller.dispose();
//     _endDate_FocusNode.dispose();
//     _description_Controller.dispose();
//     _description_FocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Resource Allocation'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: <Widget>[
//             TextFormField(
//               controller: _selectDevice_Controller,
//               focusNode: _selectDevice_FocusNode,
//               decoration: const InputDecoration(
//                 labelText: 'Select Device',
//               ),
//               validator: (String? value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _quantity_Controller,
//               focusNode: _quantity_FocusNode,
//               decoration: const InputDecoration(
//                 labelText: 'Quantity',
//               ),
//               validator: (String? value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _startDate_Controller,
//               focusNode: _startDate_FocusNode,
//               decoration: const InputDecoration(
//                 labelText: 'Start Date',
//               ),
//               validator: (String? value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _endDate_Controller,
//               focusNode: _endDate_FocusNode,
//               decoration: const InputDecoration(
//                 labelText: 'End Date',
//               ),
//               validator: (String? value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _description_Controller,
//               focusNode: _description_FocusNode,
//               decoration: const InputDecoration(
//                 labelText: 'Description',
//               ),
//               validator: (String? value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Processing Data')),
//                   );
//                 }
//               },
//               child: const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

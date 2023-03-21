import 'package:flutter/material.dart';

import '../data.dart';

class AddressTypeList extends StatefulWidget {
  const AddressTypeList({super.key, this.onTap});
  final ValueChanged<AddressType>? onTap;

  @override
  // ignore: no_logic_in_create_state
  AddressTypeListState createState() => AddressTypeListState(onTap);
}

class AddressTypeListState extends State<AddressTypeList> {
  late Future<List<AddressType>> futureAddressTypes;
  final ValueChanged<AddressType>? onTap;

  AddressTypeListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureAddressTypes = fetchAddressTypes();
  }

  Future<List<AddressType>> refreshAddressTypeState() async {
    futureAddressTypes = fetchAddressTypes();
    return futureAddressTypes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AddressType>>(
      future: refreshAddressTypeState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setAddressTypes(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                snapshot.data![index].name!,
              ),
              subtitle: Text(
                ' ' +
                    snapshot.data![index].name! +
                    ' ' +
                    snapshot.data![index].description! +
                    ' ',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => EditAddressTypePage(
                                    addressType: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteAddressType(snapshot.data![index]);
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete)),
                ],
              ),
              onTap: onTap != null ? () => onTap!(snapshot.data![index]) : null,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> _deleteAddressType(AddressType addressType) async {
    try {
      await deleteAddressType(addressType.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the AddressType'),
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

class AddAddressTypePage extends StatefulWidget {
  static const String route = '/address_type/add';
  const AddAddressTypePage({super.key});
  @override
  _AddAddressTypePageState createState() => _AddAddressTypePageState();
}

class _AddAddressTypePageState extends State<AddAddressTypePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddressType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the AddressType you want to add'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _description_Controller,
                decoration: const InputDecoration(labelText: 'description'),
                onFieldSubmitted: (_) {
                  _description_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addAddressType(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addAddressType(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final AddressType addressType = AddressType(
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await createAddressType(addressType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add AddressType'),
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

class EditAddressTypePage extends StatefulWidget {
  static const String route = 'address_type/edit';
  final AddressType addressType;
  const EditAddressTypePage({super.key, required this.addressType});
  @override
  _EditAddressTypePageState createState() => _EditAddressTypePageState();
}

class _EditAddressTypePageState extends State<EditAddressTypePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  @override
  void initState() {
    super.initState();
    final AddressType addressType = widget.addressType;
    _name_Controller = TextEditingController(text: addressType.name);
    _name_FocusNode = FocusNode();
    _description_Controller =
        TextEditingController(text: addressType.description);
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddressType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the AddressType you want to edit'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _description_Controller,
                decoration: const InputDecoration(labelText: 'description'),
                onFieldSubmitted: (_) {
                  _description_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editAddressType(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editAddressType(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final AddressType addressType = AddressType(
          id: widget.addressType.id,
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await updateAddressType(addressType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the AddressType'),
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

import 'package:flutter/material.dart';

import '../data.dart';

class InventoryList extends StatefulWidget {
  const InventoryList({super.key, this.onTap});
  final ValueChanged<Inventory>? onTap;

  @override
  InventoryListState createState() => InventoryListState(onTap);
}

class InventoryListState extends State<InventoryList> {
  late Future<List<Inventory>> futureInventories;
  final ValueChanged<Inventory>? onTap;

  InventoryListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureInventories = fetchInventories();
  }

  Future<List<Inventory>> refreshInventoryState() async {
    futureInventories = fetchInventories();
    return futureInventories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inventory>>(
      future: refreshInventoryState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setInventories(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].asset_id.toString()),
              ),
              subtitle: Text(
                ' ' +
                    snapshot.data![index].asset_id.toString() +
                    ' ' +
                    snapshot.data![index].consumable_id.toString() +
                    ' ' +
                    snapshot.data![index].organization_id.toString() +
                    ' ' +
                    snapshot.data![index].person_id.toString() +
                    ' ' +
                    snapshot.data![index].quantity.toString() +
                    ' ' +
                    snapshot.data![index].quantity_in.toString() +
                    ' ' +
                    snapshot.data![index].quantity_out.toString() +
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
                                builder: (context) => EditInventoryPage(
                                    inventory: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteInventory(snapshot.data![index]);
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
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> _deleteInventory(Inventory inventory) async {
    try {
      await deleteAsset(inventory.id!);
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Inventory'),
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

class AddInventoryPage extends StatefulWidget {
  static const String route = '/inventory/add';
  const AddInventoryPage({super.key});
  @override
  _AddInventoryPageState createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _asset_id_Controller;
  late FocusNode _asset_id_FocusNode;
  late TextEditingController _consumable_id_Controller;
  late FocusNode _consumable_id_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _person_id_Controller;
  late FocusNode _person_id_FocusNode;
  late TextEditingController _quantity_Controller;
  late FocusNode _quantity_FocusNode;
  late TextEditingController _quantity_in_Controller;
  late FocusNode _quantity_in_FocusNode;
  late TextEditingController _quantity_out_Controller;
  late FocusNode _quantity_out_FocusNode;

  @override
  void initState() {
    super.initState();
    _asset_id_Controller = TextEditingController();
    _asset_id_FocusNode = FocusNode();
    _consumable_id_Controller = TextEditingController();
    _consumable_id_FocusNode = FocusNode();
    _organization_id_Controller = TextEditingController();
    _organization_id_FocusNode = FocusNode();
    _person_id_Controller = TextEditingController();
    _person_id_FocusNode = FocusNode();
    _quantity_Controller = TextEditingController();
    _quantity_FocusNode = FocusNode();
    _quantity_in_Controller = TextEditingController();
    _quantity_in_FocusNode = FocusNode();
    _quantity_out_Controller = TextEditingController();
    _quantity_out_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _asset_id_Controller.dispose();
    _consumable_id_Controller.dispose();
    _organization_id_Controller.dispose();
    _person_id_Controller.dispose();
    _quantity_Controller.dispose();
    _quantity_in_Controller.dispose();
    _quantity_out_Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inventory'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Inventory you want to add'),
              TextFormField(
                controller: _asset_id_Controller,
                decoration: const InputDecoration(labelText: 'asset_id'),
                onFieldSubmitted: (_) {
                  _asset_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _consumable_id_Controller,
                decoration: const InputDecoration(labelText: 'consumable_id'),
                onFieldSubmitted: (_) {
                  _consumable_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _person_id_Controller,
                decoration: const InputDecoration(labelText: 'person_id'),
                onFieldSubmitted: (_) {
                  _person_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_Controller,
                decoration: const InputDecoration(labelText: 'quantity'),
                onFieldSubmitted: (_) {
                  _quantity_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_in_Controller,
                decoration: const InputDecoration(labelText: 'quantity_in'),
                onFieldSubmitted: (_) {
                  _quantity_in_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_out_Controller,
                decoration: const InputDecoration(labelText: 'quantity_out'),
                onFieldSubmitted: (_) {
                  _quantity_out_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addInventory(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addInventory(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Inventory inventory = Inventory(
          asset_id: int.parse(_asset_id_Controller.text),
          consumable_id: int.parse(_consumable_id_Controller.text),
          organization_id: int.parse(_organization_id_Controller.text),
          person_id: int.parse(_person_id_Controller.text),
          quantity: int.parse(_quantity_Controller.text),
          quantity_in: int.parse(_quantity_in_Controller.text),
          quantity_out: int.parse(_quantity_out_Controller.text),
        );
        await createInventory(inventory);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Inventory'),
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

class EditInventoryPage extends StatefulWidget {
  static const String route = 'inventory/edit';
  final Inventory inventory;
  const EditInventoryPage({super.key, required this.inventory});
  @override
  _EditInventoryPageState createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _asset_id_Controller;
  late FocusNode _asset_id_FocusNode;
  late TextEditingController _consumable_id_Controller;
  late FocusNode _consumable_id_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _person_id_Controller;
  late FocusNode _person_id_FocusNode;
  late TextEditingController _quantity_Controller;
  late FocusNode _quantity_FocusNode;
  late TextEditingController _quantity_in_Controller;
  late FocusNode _quantity_in_FocusNode;
  late TextEditingController _quantity_out_Controller;
  late FocusNode _quantity_out_FocusNode;

  @override
  void initState() {
    super.initState();
    final Inventory inventory = widget.inventory;
    _asset_id_Controller = TextEditingController();
    _asset_id_FocusNode = FocusNode();
    _consumable_id_Controller = TextEditingController();
    _consumable_id_FocusNode = FocusNode();
    _organization_id_Controller = TextEditingController();
    _organization_id_FocusNode = FocusNode();
    _person_id_Controller = TextEditingController();
    _person_id_FocusNode = FocusNode();
    _quantity_Controller = TextEditingController();
    _quantity_FocusNode = FocusNode();
    _quantity_in_Controller = TextEditingController();
    _quantity_in_FocusNode = FocusNode();
    _quantity_out_Controller = TextEditingController();
    _quantity_out_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _asset_id_Controller.dispose();
    _consumable_id_Controller.dispose();
    _organization_id_Controller.dispose();
    _person_id_Controller.dispose();
    _quantity_Controller.dispose();
    _quantity_in_Controller.dispose();
    _quantity_out_Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Inventory'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _asset_id_Controller,
                decoration: const InputDecoration(labelText: 'asset_id'),
                onFieldSubmitted: (_) {
                  _asset_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _consumable_id_Controller,
                decoration: const InputDecoration(labelText: 'consumable_id'),
                onFieldSubmitted: (_) {
                  _consumable_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _person_id_Controller,
                decoration: const InputDecoration(labelText: 'person_id'),
                onFieldSubmitted: (_) {
                  _person_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_Controller,
                decoration: const InputDecoration(labelText: 'quantity'),
                onFieldSubmitted: (_) {
                  _quantity_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_in_Controller,
                decoration: const InputDecoration(labelText: 'quantity_in'),
                onFieldSubmitted: (_) {
                  _quantity_in_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _quantity_out_Controller,
                decoration: const InputDecoration(labelText: 'quantity_out'),
                onFieldSubmitted: (_) {
                  _quantity_out_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editInventory(context);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editInventory(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Inventory inventory = Inventory(
          asset_id: int.parse(_asset_id_Controller.text),
          consumable_id: int.parse(_consumable_id_Controller.text),
          organization_id: int.parse(_organization_id_Controller.text),
          person_id: int.parse(_person_id_Controller.text),
          quantity: int.parse(_quantity_Controller.text),
          quantity_in: int.parse(_quantity_in_Controller.text),
          quantity_out: int.parse(_quantity_out_Controller.text),
        );
        await updateInventory(inventory);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit Inventory'),
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

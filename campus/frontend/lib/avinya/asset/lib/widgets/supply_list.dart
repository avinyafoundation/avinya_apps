import 'package:flutter/material.dart';

import '../data.dart';

class SupplyList extends StatefulWidget {
  const SupplyList({super.key, this.onTap});
  final ValueChanged<Supply>? onTap;

  @override
  SupplyListState createState() => SupplyListState(onTap);
}

class SupplyListState extends State<SupplyList> {
  late Future<List<Supply>> futureSupplies;
  final ValueChanged<Supply>? onTap;

  SupplyListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureSupplies = fetchSupplies();
  }

  Future<List<Supply>> refreshSupplyState() async {
    futureSupplies = fetchSupplies();
    return futureSupplies;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Supply>>(
      future: refreshSupplyState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setSupplies(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].supplier_id.toString()),
              ),
              subtitle: Text(' ' +
                  snapshot.data![index].asset_id.toString() +
                  ' ' +
                  snapshot.data![index].consumable_id.toString() +
                  ' ' +
                  snapshot.data![index].supplier_id.toString() +
                  ' ' +
                  snapshot.data![index].person_id.toString() +
                  ' ' +
                  snapshot.data![index].order_date.toString() +
                  ' ' +
                  snapshot.data![index].delivery_date.toString() +
                  ' ' +
                  snapshot.data![index].order_id.toString() +
                  ' ' +
                  snapshot.data![index].order_amount.toString() +
                  ' '),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => EditSupplyPage(
                                    supply: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteSupply(snapshot.data![index]);
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

  Future<void> _deleteSupply(Supply supply) async {
    try {
      await deleteSupply(supply.id!);
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Supply'),
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

class AddSupplyPage extends StatefulWidget {
  static const String route = '/supply/add';
  const AddSupplyPage({super.key});
  @override
  _AddSupplyPageState createState() => _AddSupplyPageState();
}

class _AddSupplyPageState extends State<AddSupplyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _asset_id_Controller;
  late FocusNode _asset_id_FocusNode;
  late TextEditingController _consumable_id_Controller;
  late FocusNode _consumable_id_FocusNode;
  late TextEditingController _supplier_id_Controller;
  late FocusNode _supplier_id_FocusNode;
  late TextEditingController _person_id_Controller;
  late FocusNode _person_id_FocusNode;
  late TextEditingController _order_date_Controller;
  late FocusNode _order_date_FocusNode;
  late TextEditingController _delivery_date_Controller;
  late FocusNode _delivery_date_FocusNode;
  late TextEditingController _order_id_Controller;
  late FocusNode _order_id_FocusNode;
  late TextEditingController _order_amount_Controller;
  late FocusNode _order_amount_FocusNode;

  @override
  void initState() {
    super.initState();
    _asset_id_Controller = TextEditingController();
    _asset_id_FocusNode = FocusNode();
    _consumable_id_Controller = TextEditingController();
    _consumable_id_FocusNode = FocusNode();
    _supplier_id_Controller = TextEditingController();
    _supplier_id_FocusNode = FocusNode();
    _person_id_Controller = TextEditingController();
    _person_id_FocusNode = FocusNode();
    _order_date_Controller = TextEditingController();
    _order_date_FocusNode = FocusNode();
    _delivery_date_Controller = TextEditingController();
    _delivery_date_FocusNode = FocusNode();
    _order_id_Controller = TextEditingController();
    _order_id_FocusNode = FocusNode();
    _order_amount_Controller = TextEditingController();
    _order_amount_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _asset_id_Controller.dispose();
    _asset_id_FocusNode.dispose();
    _consumable_id_Controller.dispose();
    _consumable_id_FocusNode.dispose();
    _supplier_id_Controller.dispose();
    _supplier_id_FocusNode.dispose();
    _person_id_Controller.dispose();
    _person_id_FocusNode.dispose();
    _order_date_Controller.dispose();
    _order_date_FocusNode.dispose();
    _delivery_date_Controller.dispose();
    _delivery_date_FocusNode.dispose();
    _order_id_Controller.dispose();
    _order_id_FocusNode.dispose();
    _order_amount_Controller.dispose();
    _order_amount_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Supply'),
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
                controller: _supplier_id_Controller,
                decoration: const InputDecoration(labelText: 'supplier_id'),
                onFieldSubmitted: (_) {
                  _supplier_id_FocusNode.requestFocus();
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
                controller: _order_date_Controller,
                decoration: const InputDecoration(labelText: 'order_date'),
                onFieldSubmitted: (_) {
                  _order_date_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _delivery_date_Controller,
                decoration: const InputDecoration(labelText: 'delivery_date'),
                onFieldSubmitted: (_) {
                  _delivery_date_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _order_id_Controller,
                decoration: const InputDecoration(labelText: 'order_id'),
                onFieldSubmitted: (_) {
                  _order_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _order_amount_Controller,
                decoration: const InputDecoration(labelText: 'order_amount'),
                onFieldSubmitted: (_) {
                  _order_amount_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addSupply(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addSupply(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final supply = Supply(
          asset_id: int.parse(_asset_id_Controller.text),
          consumable_id: int.parse(_consumable_id_Controller.text),
          supplier_id: int.parse(_supplier_id_Controller.text),
          person_id: int.parse(_person_id_Controller.text),
          order_date: _order_date_Controller.text,
          delivery_date: _delivery_date_Controller.text,
          order_id: _order_id_Controller.text,
          order_amount: int.parse(_order_amount_Controller.text),
        );
        await createSupply(supply);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Supply'),
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

class EditSupplyPage extends StatefulWidget {
  static const String route = 'supply/edit';
  final Supply supply;
  const EditSupplyPage({Key? key, required this.supply});
  @override
  _EditSupplyPageState createState() => _EditSupplyPageState();
}

class _EditSupplyPageState extends State<EditSupplyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _asset_id_Controller;
  late FocusNode _asset_id_FocusNode;
  late TextEditingController _consumable_id_Controller;
  late FocusNode _consumable_id_FocusNode;
  late TextEditingController _supplier_id_Controller;
  late FocusNode _supplier_id_FocusNode;
  late TextEditingController _person_id_Controller;
  late FocusNode _person_id_FocusNode;
  late TextEditingController _order_date_Controller;
  late FocusNode _order_date_FocusNode;
  late TextEditingController _delivery_date_Controller;
  late FocusNode _delivery_date_FocusNode;
  late TextEditingController _order_id_Controller;
  late FocusNode _order_id_FocusNode;
  late TextEditingController _order_amount_Controller;
  late FocusNode _order_amount_FocusNode;

  @override
  void initState() {
    super.initState();
    final Supply supply = widget.supply;
    _asset_id_Controller =
        TextEditingController(text: widget.supply.asset_id.toString());
    _asset_id_FocusNode = FocusNode();
    _consumable_id_Controller =
        TextEditingController(text: widget.supply.consumable_id.toString());
    _consumable_id_FocusNode = FocusNode();
    _supplier_id_Controller =
        TextEditingController(text: widget.supply.supplier_id.toString());
    _supplier_id_FocusNode = FocusNode();
    _person_id_Controller =
        TextEditingController(text: widget.supply.person_id.toString());
    _person_id_FocusNode = FocusNode();
    _order_date_Controller =
        TextEditingController(text: widget.supply.order_date);
    _order_date_FocusNode = FocusNode();
    _delivery_date_Controller =
        TextEditingController(text: widget.supply.delivery_date);
    _delivery_date_FocusNode = FocusNode();
    _order_id_Controller = TextEditingController(text: widget.supply.order_id);
    _order_id_FocusNode = FocusNode();
    _order_amount_Controller =
        TextEditingController(text: widget.supply.order_amount.toString());
    _order_amount_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _asset_id_Controller.dispose();
    _asset_id_FocusNode.dispose();
    _consumable_id_Controller.dispose();
    _consumable_id_FocusNode.dispose();
    _supplier_id_Controller.dispose();
    _supplier_id_FocusNode.dispose();
    _person_id_Controller.dispose();
    _person_id_FocusNode.dispose();
    _order_date_Controller.dispose();
    _order_date_FocusNode.dispose();
    _delivery_date_Controller.dispose();
    _delivery_date_FocusNode.dispose();
    _order_id_Controller.dispose();
    _order_id_FocusNode.dispose();
    _order_amount_Controller.dispose();
    _order_amount_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supply'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
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
                controller: _supplier_id_Controller,
                decoration: const InputDecoration(labelText: 'supplier_id'),
                onFieldSubmitted: (_) {
                  _supplier_id_FocusNode.requestFocus();
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
                controller: _order_date_Controller,
                decoration: const InputDecoration(labelText: 'order_date'),
                onFieldSubmitted: (_) {
                  _order_date_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _delivery_date_Controller,
                decoration: const InputDecoration(labelText: 'delivery_date'),
                onFieldSubmitted: (_) {
                  _delivery_date_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _order_id_Controller,
                decoration: const InputDecoration(labelText: 'order_id'),
                onFieldSubmitted: (_) {
                  _order_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _order_amount_Controller,
                decoration: const InputDecoration(labelText: 'order_amount'),
                onFieldSubmitted: (_) {
                  _order_amount_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editSupply(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editSupply(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Supply supply = Supply(
          id: widget.supply.id,
          asset_id: int.parse(_asset_id_Controller.text),
          consumable_id: int.parse(_consumable_id_Controller.text),
          supplier_id: int.parse(_supplier_id_Controller.text),
          person_id: int.parse(_person_id_Controller.text),
          order_date: _order_date_Controller.text,
          delivery_date: _delivery_date_Controller.text,
          order_id: _order_id_Controller.text,
          order_amount: int.parse(_order_amount_Controller.text),
        );
        await updateSupply(supply);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the Supply'),
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

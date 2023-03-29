import 'package:flutter/material.dart';

import '../data.dart';

class SupplierList extends StatefulWidget {
  const SupplierList({super.key, this.onTap});
  final ValueChanged<Supplier>? onTap;

  @override
  SupplierListState createState() => SupplierListState(onTap);
}

class SupplierListState extends State<SupplierList> {
  late Future<List<Supplier>> futureSuppliers;
  final ValueChanged<Supplier>? onTap;

  SupplierListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureSuppliers = fetchSuppliers();
  }

  Future<List<Supplier>> refreshSupplierState() async {
    futureSuppliers = fetchSuppliers();
    return futureSuppliers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Supplier>>(
      future: refreshSupplierState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setSuppliers(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].name ?? ''),
              ),
              subtitle: Text(' ' +
                  snapshot.data![index].name.toString() +
                  ' ' +
                  snapshot.data![index].phone.toString() +
                  ' ' +
                  snapshot.data![index].email.toString() +
                  ' ' +
                  snapshot.data![index].description.toString() +
                  ' '),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => EditSupplierPage(
                                    supplier: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteSupplier(snapshot.data![index]);
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

  Future<void> _deleteSupplier(Supplier supplier) async {
    try {
      await deleteSupplier(supplier.id!);
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Supplier'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class AddSupplierPage extends StatefulWidget {
  static const String route = '/supplier/add';
  const AddSupplierPage({super.key});
  @override
  _AddSupplierPageState createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _phone_Controller = TextEditingController();
    _phone_FocusNode = FocusNode();
    _email_Controller = TextEditingController();
    _email_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Supplier you want to add'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _phone_Controller,
                decoration: const InputDecoration(labelText: 'phone'),
                onFieldSubmitted: (_) {
                  _phone_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _email_Controller,
                decoration: const InputDecoration(labelText: 'email'),
                onFieldSubmitted: (_) {
                  _email_FocusNode.requestFocus();
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
          await _addSupplier(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addSupplier(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Supplier supplier = Supplier(
          name: _name_Controller.text,
          phone: int.parse(_phone_Controller.text),
          email: _email_Controller.text,
          description: _description_Controller.text,
        );
        await createSupplier(supplier);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Supplier'),
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

class EditSupplierPage extends StatefulWidget {
  static const String route = 'supplier/edit';
  final Supplier supplier;
  const EditSupplierPage({super.key, required this.supplier});
  @override
  _EditSupplierPageState createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;

  @override
  void initState() {
    super.initState();
    final Supplier supplier = widget.supplier;
    _name_Controller = TextEditingController(text: supplier.name);
    _name_FocusNode = FocusNode();
    _phone_Controller = TextEditingController(text: supplier.phone.toString());
    _phone_FocusNode = FocusNode();
    _email_Controller = TextEditingController(text: supplier.email);
    _email_FocusNode = FocusNode();
    _description_Controller = TextEditingController(text: supplier.description);
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Supplier you want to edit'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _phone_Controller,
                decoration: const InputDecoration(labelText: 'phone'),
                onFieldSubmitted: (_) {
                  _phone_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _email_Controller,
                decoration: const InputDecoration(labelText: 'email'),
                onFieldSubmitted: (_) {
                  _email_FocusNode.requestFocus();
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
          await _editSupplier(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editSupplier(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Supplier supplier = Supplier(
          id: widget.supplier.id,
          name: _name_Controller.text,
          phone: int.parse(_phone_Controller.text),
          email: _email_Controller.text,
          description: _description_Controller.text,
        );
        await updateSupplier(supplier);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit Supplier'),
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

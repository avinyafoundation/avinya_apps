import 'package:flutter/material.dart';

import '../data.dart';

class ConsumableList extends StatefulWidget {
  const ConsumableList({super.key, this.onTap});
  final ValueChanged<Consumable>? onTap;

  @override
  ConsumableListState createState() => ConsumableListState(onTap);
}

class ConsumableListState extends State<ConsumableList> {
  late Future<List<Consumable>> futureConsumables;
  final ValueChanged<Consumable>? onTap;

  ConsumableListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureConsumables = fetchConsumables();
  }

  Future<List<Consumable>> refreshConsumableState() async {
    futureConsumables = fetchConsumables();
    return futureConsumables;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Consumable>>(
      future: refreshConsumableState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusConfigSystemInstance.setConsumables(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].name ?? ''),
              ),
              subtitle: Text(' ' +
                  snapshot.data![index].name.toString() +
                  ' ' +
                  snapshot.data![index].description.toString() +
                  ' ' +
                  snapshot.data![index].avinyaTypeId.toString() +
                  ' ' +
                  snapshot.data![index].manufacturer.toString() +
                  ' ' +
                  snapshot.data![index].model.toString() +
                  ' ' +
                  snapshot.data![index].serialNumber.toString() +
                  ' '),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => EditConsumablePage(
                                    consumable: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteConsumable(snapshot.data![index]);
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

  Future<void> _deleteConsumable(Consumable consumable) async {
    try {
      await deleteConsumable(consumable.id!);
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Consumable'),
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

class AddConsumablePage extends StatefulWidget {
  static const String route = '/consumable/add';
  const AddConsumablePage({super.key});
  @override
  _AddConsumablePageState createState() => _AddConsumablePageState();
}

class _AddConsumablePageState extends State<AddConsumablePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _avinyaTypeId_Controller;
  late FocusNode _avinyaTypeId_FocusNode;
  late TextEditingController _manufacturer_Controller;
  late FocusNode _manufacturer_FocusNode;
  late TextEditingController _model_Controller;
  late FocusNode _model_FocusNode;
  late TextEditingController _serialNumber_Controller;
  late FocusNode _serialNumber_FocusNode;

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
    _avinyaTypeId_Controller = TextEditingController();
    _avinyaTypeId_FocusNode = FocusNode();
    _manufacturer_Controller = TextEditingController();
    _manufacturer_FocusNode = FocusNode();
    _model_Controller = TextEditingController();
    _model_FocusNode = FocusNode();
    _serialNumber_Controller = TextEditingController();
    _serialNumber_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _avinyaTypeId_Controller.dispose();
    _avinyaTypeId_FocusNode.dispose();
    _manufacturer_Controller.dispose();
    _manufacturer_FocusNode.dispose();
    _model_Controller.dispose();
    _model_FocusNode.dispose();
    _serialNumber_Controller.dispose();
    _serialNumber_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Consumable'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Consumable you want to add'),
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
              TextFormField(
                controller: _avinyaTypeId_Controller,
                decoration: const InputDecoration(labelText: 'avinyaTypeId'),
                onFieldSubmitted: (_) {
                  _avinyaTypeId_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _manufacturer_Controller,
                decoration: const InputDecoration(labelText: 'manufacturer'),
                onFieldSubmitted: (_) {
                  _manufacturer_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _model_Controller,
                decoration: const InputDecoration(labelText: 'model'),
                onFieldSubmitted: (_) {
                  _model_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _serialNumber_Controller,
                decoration: const InputDecoration(labelText: 'serialNumber'),
                onFieldSubmitted: (_) {
                  _serialNumber_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addConsumable(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addConsumable(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Consumable consumable = Consumable(
          name: _name_Controller.text,
          description: _description_Controller.text,
          avinyaTypeId: int.parse(_avinyaTypeId_Controller.text),
          manufacturer: _manufacturer_Controller.text,
          model: _model_Controller.text,
          serialNumber: _serialNumber_Controller.text,
        );
        await createConsumable(consumable);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Consumable'),
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

class EditConsumablePage extends StatefulWidget {
  static const String route = 'consumable/edit';
  final Consumable consumable;
  const EditConsumablePage({super.key, required this.consumable});
  @override
  _EditConsumablePageState createState() => _EditConsumablePageState();
}

class _EditConsumablePageState extends State<EditConsumablePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _avinyaTypeId_Controller;
  late FocusNode _avinyaTypeId_FocusNode;
  late TextEditingController _manufacturer_Controller;
  late FocusNode _manufacturer_FocusNode;
  late TextEditingController _model_Controller;
  late FocusNode _model_FocusNode;
  late TextEditingController _serialNumber_Controller;
  late FocusNode _serialNumber_FocusNode;

  @override
  void initState() {
    super.initState();
    final Consumable consumable = widget.consumable;
    _name_Controller = TextEditingController(text: consumable.name);
    _name_FocusNode = FocusNode();
    _description_Controller =
        TextEditingController(text: consumable.description);
    _description_FocusNode = FocusNode();
    _avinyaTypeId_Controller =
        TextEditingController(text: consumable.avinyaTypeId.toString());
    _avinyaTypeId_FocusNode = FocusNode();
    _manufacturer_Controller =
        TextEditingController(text: consumable.manufacturer);
    _manufacturer_FocusNode = FocusNode();
    _model_Controller = TextEditingController(text: consumable.model);
    _model_FocusNode = FocusNode();
    _serialNumber_Controller =
        TextEditingController(text: consumable.serialNumber);
    _serialNumber_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _avinyaTypeId_Controller.dispose();
    _avinyaTypeId_FocusNode.dispose();
    _manufacturer_Controller.dispose();
    _manufacturer_FocusNode.dispose();
    _model_Controller.dispose();
    _model_FocusNode.dispose();
    _serialNumber_Controller.dispose();
    _serialNumber_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Consumable'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Consumable you want to edit'),
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
              TextFormField(
                controller: _avinyaTypeId_Controller,
                decoration: const InputDecoration(labelText: 'avinyaTypeId'),
                onFieldSubmitted: (_) {
                  _avinyaTypeId_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _manufacturer_Controller,
                decoration: const InputDecoration(labelText: 'manufacturer'),
                onFieldSubmitted: (_) {
                  _manufacturer_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _model_Controller,
                decoration: const InputDecoration(labelText: 'model'),
                onFieldSubmitted: (_) {
                  _model_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _serialNumber_Controller,
                decoration: const InputDecoration(labelText: 'serialNumber'),
                onFieldSubmitted: (_) {
                  _serialNumber_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editConsumable(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editConsumable(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Consumable consumable = Consumable(
          id: widget.consumable.id,
          name: _name_Controller.text,
          description: _description_Controller.text,
          avinyaTypeId: int.parse(_avinyaTypeId_Controller.text),
          manufacturer: _manufacturer_Controller.text,
          model: _model_Controller.text,
          serialNumber: _serialNumber_Controller.text,
        );
        await updateConsumable(consumable);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit Consumable'),
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

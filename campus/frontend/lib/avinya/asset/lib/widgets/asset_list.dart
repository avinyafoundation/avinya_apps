import 'package:flutter/material.dart';

import '../data.dart';

class AssetList extends StatefulWidget {
  const AssetList({super.key, this.onTap});
  final ValueChanged<Asset>? onTap;

  @override
  AssetListState createState() => AssetListState(onTap);
}

class AssetListState extends State<AssetList> {
  late Future<List<Asset>> futureAssets;
  final ValueChanged<Asset>? onTap;

  AssetListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureAssets = fetchAssets();
  }

  Future<List<Asset>> refreshAssetState() async {
    futureAssets = fetchAssets();
    return futureAssets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Asset>>(
      future: refreshAssetState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data![1].avinya_type_id.toString() + "test");
          campusConfigSystemInstance.setAssets(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].name ?? ''),
              ),
              subtitle: Text(
                ' ' +
                    snapshot.data![index].name.toString() +
                    ' ' +
                    snapshot.data![index].manufacturer.toString() +
                    ' ' +
                    snapshot.data![index].model.toString() +
                    ' ' +
                    snapshot.data![index].serialNumber.toString() +
                    ' ' +
                    snapshot.data![index].registrationNumber.toString() +
                    ' ' +
                    snapshot.data![index].description.toString() +
                    ' ' +
                    snapshot.data![index].avinya_type_id.toString() +
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
                                builder: (context) =>
                                    EditAssetPage(asset: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteAsset(snapshot.data![index]);
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

  Future<void> _deleteAsset(Asset asset) async {
    try {
      await deleteAsset(asset.id!);
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Asset'),
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

class AddAssetPage extends StatefulWidget {
  static const String route = '/asset/add';
  const AddAssetPage({super.key});
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _manufacturer_Controller;
  late FocusNode _manufacturer_FocusNode;
  late TextEditingController _model_Controller;
  late FocusNode _model_FocusNode;
  late TextEditingController _serialNumber_Controller;
  late FocusNode _serialNumber_FocusNode;
  late TextEditingController _registrationNumber_Controller;
  late FocusNode _registrationNumber_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _avinyaTypeId_Controller;
  late FocusNode _avinyaTypeId_FocusNode;

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _manufacturer_Controller = TextEditingController();
    _manufacturer_FocusNode = FocusNode();
    _model_Controller = TextEditingController();
    _model_FocusNode = FocusNode();
    _serialNumber_Controller = TextEditingController();
    _serialNumber_FocusNode = FocusNode();
    _registrationNumber_Controller = TextEditingController();
    _registrationNumber_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
    _avinyaTypeId_Controller = TextEditingController();
    _avinyaTypeId_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _manufacturer_Controller.dispose();
    _manufacturer_FocusNode.dispose();
    _model_Controller.dispose();
    _model_FocusNode.dispose();
    _serialNumber_Controller.dispose();
    _serialNumber_FocusNode.dispose();
    _registrationNumber_Controller.dispose();
    _registrationNumber_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _avinyaTypeId_Controller.dispose();
    _avinyaTypeId_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Asset you want to add'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
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
              TextFormField(
                controller: _registrationNumber_Controller,
                decoration:
                    const InputDecoration(labelText: 'registrationNumber'),
                onFieldSubmitted: (_) {
                  _registrationNumber_FocusNode.requestFocus();
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addAsset(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addAsset(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Asset asset = Asset(
          name: _name_Controller.text,
          manufacturer: _manufacturer_Controller.text,
          model: _model_Controller.text,
          serialNumber: _serialNumber_Controller.text,
          registrationNumber: _registrationNumber_Controller.text,
          description: _description_Controller.text,
          // avinyaTypeId:
          //     AvinyaType(id: int.parse(_avinyaTypeId_Controller.text))
        );
        await createAsset(asset);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Asset'),
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

class EditAssetPage extends StatefulWidget {
  static const String route = 'asset/edit';
  final Asset asset;
  const EditAssetPage({super.key, required this.asset});
  @override
  _EditAssetPageState createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _manufacturer_Controller;
  late FocusNode _manufacturer_FocusNode;
  late TextEditingController _model_Controller;
  late FocusNode _model_FocusNode;
  late TextEditingController _serialNumber_Controller;
  late FocusNode _serialNumber_FocusNode;
  late TextEditingController _registrationNumber_Controller;
  late FocusNode _registrationNumber_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _avinyaTypeId_Controller;
  late FocusNode _avinyaTypeId_FocusNode;

  @override
  void initState() {
    super.initState();
    final Asset asset = widget.asset;
    _name_Controller = TextEditingController(text: asset.name);
    _name_FocusNode = FocusNode();
    _manufacturer_Controller = TextEditingController(text: asset.manufacturer);
    _manufacturer_FocusNode = FocusNode();
    _model_Controller = TextEditingController(text: asset.model);
    _model_FocusNode = FocusNode();
    _serialNumber_Controller = TextEditingController(text: asset.serialNumber);
    _serialNumber_FocusNode = FocusNode();
    _registrationNumber_Controller =
        TextEditingController(text: asset.registrationNumber);
    _registrationNumber_FocusNode = FocusNode();
    _description_Controller = TextEditingController(text: asset.description);
    _description_FocusNode = FocusNode();
    _avinyaTypeId_Controller =
        TextEditingController(text: asset.avinya_type_id.toString());
    _avinyaTypeId_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _manufacturer_Controller.dispose();
    _manufacturer_FocusNode.dispose();
    _model_Controller.dispose();
    _model_FocusNode.dispose();
    _serialNumber_Controller.dispose();
    _serialNumber_FocusNode.dispose();
    _registrationNumber_Controller.dispose();
    _registrationNumber_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _avinyaTypeId_Controller.dispose();
    _avinyaTypeId_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Asset'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
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
              TextFormField(
                controller: _registrationNumber_Controller,
                decoration:
                    const InputDecoration(labelText: 'registrationNumber'),
                onFieldSubmitted: (_) {
                  _registrationNumber_FocusNode.requestFocus();
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editAsset(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editAsset(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Asset asset = Asset(
          id: widget.asset.id,
          name: _name_Controller.text,
          manufacturer: _manufacturer_Controller.text,
          model: _model_Controller.text,
          serialNumber: _serialNumber_Controller.text,
          registrationNumber: _registrationNumber_Controller.text,
          description: _description_Controller.text,
          // avinyaTypeId:
          //     AvinyaType(id: int.parse(_avinyaTypeId_Controller.text)),
        );
        await updateAsset(asset);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the Asset'),
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

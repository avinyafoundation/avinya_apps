import 'package:flutter/material.dart';

import '../data.dart';

class AvinyaTypeList extends StatefulWidget {
  const AvinyaTypeList({super.key, this.onTap});
  final ValueChanged<AvinyaType>? onTap;

  @override
  // ignore: no_logic_in_create_state
  AvinyaTypeListState createState() => AvinyaTypeListState(onTap);
}

class AvinyaTypeListState extends State<AvinyaTypeList> {
  late Future<List<AvinyaType>> futureAvinyaTypes;
  final ValueChanged<AvinyaType>? onTap;

  AvinyaTypeListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureAvinyaTypes = fetchAvinyaTypes();
  }

  Future<List<AvinyaType>> refreshAvinyaTypeState() async {
    futureAvinyaTypes = fetchAvinyaTypes();
    return futureAvinyaTypes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvinyaType>>(
      future: refreshAvinyaTypeState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusAttendanceSystemInstance.setAvinyaTypes(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                (snapshot.data![index].name ?? ''),
              ),
              subtitle: Text(
                ' ' +
                    (snapshot.data![index].global_type ?? '') +
                    ' ' +
                    (snapshot.data![index].foundation_type ?? '') +
                    ' ' +
                    (snapshot.data![index].focus ?? '') +
                    ' ' +
                    snapshot.data![index].active!.toString() +
                    ' ' +
                    snapshot.data![index].level!.toString() +
                    ' ' +
                    (snapshot.data![index].name ?? '') +
                    ' ' +
                    (snapshot.data![index].description ?? '') +
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
                                builder: (context) => EditAvinyaTypePage(
                                    avinyaType: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteAvinyaType(snapshot.data![index]);
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

  Future<void> _deleteAvinyaType(AvinyaType avinyaType) async {
    try {
      await deleteAvinyaType(avinyaType.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the AvinyaType'),
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

class AddAvinyaTypePage extends StatefulWidget {
  static const String route = '/avinya_type/add';
  const AddAvinyaTypePage({super.key});
  @override
  _AddAvinyaTypePageState createState() => _AddAvinyaTypePageState();
}

class _AddAvinyaTypePageState extends State<AddAvinyaTypePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _global_type_Controller;
  late FocusNode _global_type_FocusNode;
  late TextEditingController _foundation_type_Controller;
  late FocusNode _foundation_type_FocusNode;
  late TextEditingController _focus_Controller;
  late FocusNode _focus_FocusNode;
  late TextEditingController _active_Controller;
  late FocusNode _active_FocusNode;
  late TextEditingController _level_Controller;
  late FocusNode _level_FocusNode;
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;

  @override
  void initState() {
    super.initState();
    _global_type_Controller = TextEditingController();
    _global_type_FocusNode = FocusNode();
    _foundation_type_Controller = TextEditingController();
    _foundation_type_FocusNode = FocusNode();
    _focus_Controller = TextEditingController();
    _focus_FocusNode = FocusNode();
    _active_Controller = TextEditingController();
    _active_FocusNode = FocusNode();
    _level_Controller = TextEditingController();
    _level_FocusNode = FocusNode();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _global_type_Controller.dispose();
    _global_type_FocusNode.dispose();
    _foundation_type_Controller.dispose();
    _foundation_type_FocusNode.dispose();
    _focus_Controller.dispose();
    _focus_FocusNode.dispose();
    _active_Controller.dispose();
    _active_FocusNode.dispose();
    _level_Controller.dispose();
    _level_FocusNode.dispose();
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
        title: const Text('AvinyaType'),
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
                controller: _global_type_Controller,
                decoration: const InputDecoration(labelText: 'global_type'),
                onFieldSubmitted: (_) {
                  _global_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _foundation_type_Controller,
                decoration: const InputDecoration(labelText: 'foundation_type'),
                onFieldSubmitted: (_) {
                  _foundation_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _focus_Controller,
                decoration: const InputDecoration(labelText: 'focus'),
                onFieldSubmitted: (_) {
                  _focus_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _active_Controller,
                decoration: const InputDecoration(labelText: 'active'),
                onFieldSubmitted: (_) {
                  _active_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _level_Controller,
                decoration: const InputDecoration(labelText: 'level'),
                onFieldSubmitted: (_) {
                  _level_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
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
          await _addAvinyaType(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addAvinyaType(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final AvinyaType avinyaType = AvinyaType(
          global_type: _global_type_Controller.text,
          foundation_type: _foundation_type_Controller.text,
          focus: _focus_Controller.text,
          active: _active_Controller.text.toLowerCase() == 'true',
          level: int.parse(_level_Controller.text),
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await createAvinyaType(avinyaType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add AvinyaType'),
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

class EditAvinyaTypePage extends StatefulWidget {
  static const String route = 'avinya_type/edit';
  final AvinyaType avinyaType;
  const EditAvinyaTypePage({super.key, required this.avinyaType});
  @override
  _EditAvinyaTypePageState createState() => _EditAvinyaTypePageState();
}

class _EditAvinyaTypePageState extends State<EditAvinyaTypePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _global_type_Controller;
  late FocusNode _global_type_FocusNode;
  late TextEditingController _foundation_type_Controller;
  late FocusNode _foundation_type_FocusNode;
  late TextEditingController _focus_Controller;
  late FocusNode _focus_FocusNode;
  late TextEditingController _active_Controller;
  late FocusNode _active_FocusNode;
  late TextEditingController _level_Controller;
  late FocusNode _level_FocusNode;
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  @override
  void initState() {
    super.initState();
    final AvinyaType avinyaType = widget.avinyaType;
    _global_type_Controller =
        TextEditingController(text: avinyaType.global_type);
    _global_type_FocusNode = FocusNode();
    _foundation_type_Controller =
        TextEditingController(text: avinyaType.foundation_type);
    _foundation_type_FocusNode = FocusNode();
    _focus_Controller = TextEditingController(text: avinyaType.focus);
    _focus_FocusNode = FocusNode();
    _active_Controller =
        TextEditingController(text: avinyaType.active.toString());
    _active_FocusNode = FocusNode();
    _level_Controller =
        TextEditingController(text: avinyaType.level.toString());
    _level_FocusNode = FocusNode();
    _name_Controller = TextEditingController(text: avinyaType.name);
    _name_FocusNode = FocusNode();
    _description_Controller =
        TextEditingController(text: avinyaType.description);
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _global_type_Controller.dispose();
    _global_type_FocusNode.dispose();
    _foundation_type_Controller.dispose();
    _foundation_type_FocusNode.dispose();
    _focus_Controller.dispose();
    _focus_FocusNode.dispose();
    _active_Controller.dispose();
    _active_FocusNode.dispose();
    _level_Controller.dispose();
    _level_FocusNode.dispose();
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
        title: const Text('AvinyaType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the AvinyaType you want to edit'),
              TextFormField(
                controller: _global_type_Controller,
                decoration: const InputDecoration(labelText: 'global_type'),
                onFieldSubmitted: (_) {
                  _global_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _foundation_type_Controller,
                decoration: const InputDecoration(labelText: 'foundation_type'),
                onFieldSubmitted: (_) {
                  _foundation_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _focus_Controller,
                decoration: const InputDecoration(labelText: 'focus'),
                onFieldSubmitted: (_) {
                  _focus_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _active_Controller,
                decoration: const InputDecoration(labelText: 'active'),
                onFieldSubmitted: (_) {
                  _active_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _level_Controller,
                decoration: const InputDecoration(labelText: 'level'),
                onFieldSubmitted: (_) {
                  _level_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
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
          await _editAvinyaType(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editAvinyaType(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final AvinyaType avinyaType = AvinyaType(
          id: widget.avinyaType.id,
          global_type: _global_type_Controller.text,
          foundation_type: _foundation_type_Controller.text,
          focus: _focus_Controller.text,
          active: _active_Controller.text.toLowerCase() == 'true',
          level: int.parse(_level_Controller.text),
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await updateAvinyaType(avinyaType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the AvinyaType'),
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

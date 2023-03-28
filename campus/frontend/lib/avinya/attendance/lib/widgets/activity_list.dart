import 'package:gallery/config/app_config.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({super.key, this.onTap});
  final ValueChanged<Activity>? onTap;

  @override
  // ignore: no_logic_in_create_state
  ActivityListState createState() => ActivityListState(onTap);
}

class ActivityListState extends State<ActivityList> {
  late Future<Activity> futureActivity;
  final ValueChanged<Activity>? onTap;

  ActivityListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureActivity = fetchActivity(AppConfig.mainCampusActivity);
  }

  Future<Activity> refreshActivityState() async {
    futureActivity = fetchActivity(AppConfig.mainCampusActivity);
    return futureActivity;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Activity>(
      future: refreshActivityState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusAttendanceSystemInstance.setActivity(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.child_activities!.length,
            itemBuilder: (context, index) => ListTile(
              leading: Text(
                snapshot.data!.name! +
                    ' activity ' +
                    ((snapshot.data!.child_activities![index].id ?? 0) - 1)
                        .toString(),
              ),
              title: Text(
                (snapshot.data!.child_activities![index].name ?? ''),
              ),
              subtitle: Text(
                'Activity Instances ' +
                    (snapshot.data!.child_activities![index].activity_instances
                            ?.length
                            .toString() ??
                        '') +
                    ' ' +
                    (snapshot.data!.child_activities![index].notes ?? '') +
                    ' ' +
                    (snapshot.data!.child_activities![index].created ?? '') +
                    ' ' +
                    (snapshot.data!.child_activities![index].updated ?? '') +
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
                                builder: (context) => EditActivityPage(
                                    avinyaType: snapshot
                                        .data!.child_activities![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deleteActivity(
                            snapshot.data!.child_activities![index]);
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete)),
                ],
              ),
              onTap: onTap != null
                  ? () => onTap!(snapshot.data!.child_activities![index])
                  : null,
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

  Future<void> _deleteActivity(Activity avinyaType) async {
    try {
      await deleteActivity(avinyaType.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Activity'),
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

class AddActivityPage extends StatefulWidget {
  static const String route = '/avinya_type/add';
  const AddActivityPage({super.key});
  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;

  @override
  void initState() {
    super.initState();
    _notes_Controller = TextEditingController();
    _notes_FocusNode = FocusNode();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();
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
        title: const Text('Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Activity you want to add'),
              TextFormField(
                controller: _notes_Controller,
                decoration: const InputDecoration(labelText: 'global_type'),
                onFieldSubmitted: (_) {
                  _notes_FocusNode.requestFocus();
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
          await _addActivity(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addActivity(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Activity avinyaType = Activity(
          notes: _notes_Controller.text,
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await createActivity(avinyaType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Activity'),
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

class EditActivityPage extends StatefulWidget {
  static const String route = 'avinya_type/edit';
  final Activity avinyaType;
  const EditActivityPage({super.key, required this.avinyaType});
  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  @override
  void initState() {
    super.initState();
    final Activity avinyaType = widget.avinyaType;
    _notes_Controller = TextEditingController(text: avinyaType.notes);
    _notes_FocusNode = FocusNode();

    _name_Controller = TextEditingController(text: avinyaType.name);
    _name_FocusNode = FocusNode();
    _description_Controller =
        TextEditingController(text: avinyaType.description);
    _description_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();

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
        title: const Text('Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Activity you want to edit'),
              TextFormField(
                controller: _notes_Controller,
                decoration: const InputDecoration(labelText: 'global_type'),
                onFieldSubmitted: (_) {
                  _notes_FocusNode.requestFocus();
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
          await _editActivity(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editActivity(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Activity avinyaType = Activity(
          id: widget.avinyaType.id,
          notes: _notes_Controller.text,
          name: _name_Controller.text,
          description: _description_Controller.text,
        );
        await updateActivity(avinyaType);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the Activity'),
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

import 'package:flutter/material.dart';

import '../data.dart';

class PersonList extends StatefulWidget {
  const PersonList({super.key, this.onTap});
  final ValueChanged<Person>? onTap;

  @override
  // ignore: no_logic_in_create_state
  PersonListState createState() => PersonListState(onTap);
}

class PersonListState extends State<PersonList> {
  late Future<List<Person>> futurePersons;
  final ValueChanged<Person>? onTap;

  PersonListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futurePersons = fetchPersons();
  }

  Future<List<Person>> refreshPersonState() async {
    futurePersons = fetchPersons();
    return futurePersons;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: refreshPersonState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusAttendanceSystemInstance.setPersons(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                snapshot.data![index].full_name!,
              ),
              subtitle: Text(
                ' ' +
                    snapshot.data![index].record_type! +
                    ' ' +
                    snapshot.data![index].preferred_name! +
                    ' ' +
                    snapshot.data![index].full_name! +
                    ' ' +
                    snapshot.data![index].notes! +
                    ' ' +
                    snapshot.data![index].date_of_birth! +
                    ' ' +
                    snapshot.data![index].sex! +
                    ' ' +
                    snapshot.data![index].avinya_type_id!.toString() +
                    ' ' +
                    snapshot.data![index].passport_no! +
                    ' ' +
                    snapshot.data![index].permanent_address_id!.toString() +
                    ' ' +
                    snapshot.data![index].mailing_address_id!.toString() +
                    ' ' +
                    snapshot.data![index].nic_no! +
                    ' ' +
                    snapshot.data![index].id_no! +
                    ' ' +
                    snapshot.data![index].phone!.toString() +
                    ' ' +
                    snapshot.data![index].organization_id!.toString() +
                    ' ' +
                    snapshot.data![index].asgardeo_id! +
                    ' ' +
                    snapshot.data![index].email! +
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
                                builder: (context) => EditPersonPage(
                                    person: snapshot.data![index]),
                              ),
                            )
                            .then((value) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () async {
                        await _deletePerson(snapshot.data![index]);
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

  Future<void> _deletePerson(Person person) async {
    try {
      await deletePerson(person.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Person'),
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

class AddPersonPage extends StatefulWidget {
  static const String route = '/person/add';
  const AddPersonPage({super.key});
  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _record_type_Controller;
  late FocusNode _record_type_FocusNode;
  late TextEditingController _preferred_name_Controller;
  late FocusNode _preferred_name_FocusNode;
  late TextEditingController _full_name_Controller;
  late FocusNode _full_name_FocusNode;
  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;
  late TextEditingController _date_of_birth_Controller;
  late FocusNode _date_of_birth_FocusNode;
  late TextEditingController _sex_Controller;
  late FocusNode _sex_FocusNode;
  late TextEditingController _avinya_type_id_Controller;
  late FocusNode _avinya_type_id_FocusNode;
  late TextEditingController _passport_no_Controller;
  late FocusNode _passport_no_FocusNode;
  late TextEditingController _permanent_address_id_Controller;
  late FocusNode _permanent_address_id_FocusNode;
  late TextEditingController _mailing_address_id_Controller;
  late FocusNode _mailing_address_id_FocusNode;
  late TextEditingController _nic_no_Controller;
  late FocusNode _nic_no_FocusNode;
  late TextEditingController _id_no_Controller;
  late FocusNode _id_no_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _asgardeo_id_Controller;
  late FocusNode _asgardeo_id_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;

  @override
  void initState() {
    super.initState();
    _record_type_Controller = TextEditingController();
    _record_type_FocusNode = FocusNode();
    _preferred_name_Controller = TextEditingController();
    _preferred_name_FocusNode = FocusNode();
    _full_name_Controller = TextEditingController();
    _full_name_FocusNode = FocusNode();
    _notes_Controller = TextEditingController();
    _notes_FocusNode = FocusNode();
    _date_of_birth_Controller = TextEditingController();
    _date_of_birth_FocusNode = FocusNode();
    _sex_Controller = TextEditingController();
    _sex_FocusNode = FocusNode();
    _avinya_type_id_Controller = TextEditingController();
    _avinya_type_id_FocusNode = FocusNode();
    _passport_no_Controller = TextEditingController();
    _passport_no_FocusNode = FocusNode();
    _permanent_address_id_Controller = TextEditingController();
    _permanent_address_id_FocusNode = FocusNode();
    _mailing_address_id_Controller = TextEditingController();
    _mailing_address_id_FocusNode = FocusNode();
    _nic_no_Controller = TextEditingController();
    _nic_no_FocusNode = FocusNode();
    _id_no_Controller = TextEditingController();
    _id_no_FocusNode = FocusNode();
    _phone_Controller = TextEditingController();
    _phone_FocusNode = FocusNode();
    _organization_id_Controller = TextEditingController();
    _organization_id_FocusNode = FocusNode();
    _asgardeo_id_Controller = TextEditingController();
    _asgardeo_id_FocusNode = FocusNode();
    _email_Controller = TextEditingController();
    _email_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _record_type_Controller.dispose();
    _record_type_FocusNode.dispose();
    _preferred_name_Controller.dispose();
    _preferred_name_FocusNode.dispose();
    _full_name_Controller.dispose();
    _full_name_FocusNode.dispose();
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();
    _date_of_birth_Controller.dispose();
    _date_of_birth_FocusNode.dispose();
    _sex_Controller.dispose();
    _sex_FocusNode.dispose();
    _avinya_type_id_Controller.dispose();
    _avinya_type_id_FocusNode.dispose();
    _passport_no_Controller.dispose();
    _passport_no_FocusNode.dispose();
    _permanent_address_id_Controller.dispose();
    _permanent_address_id_FocusNode.dispose();
    _mailing_address_id_Controller.dispose();
    _mailing_address_id_FocusNode.dispose();
    _nic_no_Controller.dispose();
    _nic_no_FocusNode.dispose();
    _id_no_Controller.dispose();
    _id_no_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _organization_id_Controller.dispose();
    _organization_id_FocusNode.dispose();
    _asgardeo_id_Controller.dispose();
    _asgardeo_id_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Person you want to add'),
              TextFormField(
                controller: _record_type_Controller,
                decoration: const InputDecoration(labelText: 'record_type'),
                onFieldSubmitted: (_) {
                  _record_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _preferred_name_Controller,
                decoration: const InputDecoration(labelText: 'preferred_name'),
                onFieldSubmitted: (_) {
                  _preferred_name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _full_name_Controller,
                decoration: const InputDecoration(labelText: 'full_name'),
                onFieldSubmitted: (_) {
                  _full_name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _notes_Controller,
                decoration: const InputDecoration(labelText: 'notes'),
                onFieldSubmitted: (_) {
                  _notes_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _date_of_birth_Controller,
                decoration: const InputDecoration(labelText: 'date_of_birth'),
                onFieldSubmitted: (_) {
                  _date_of_birth_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _sex_Controller,
                decoration: const InputDecoration(labelText: 'sex'),
                onFieldSubmitted: (_) {
                  _sex_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_id_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type_id'),
                onFieldSubmitted: (_) {
                  _avinya_type_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _passport_no_Controller,
                decoration: const InputDecoration(labelText: 'passport_no'),
                onFieldSubmitted: (_) {
                  _passport_no_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _permanent_address_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'permanent_address_id'),
                onFieldSubmitted: (_) {
                  _permanent_address_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _mailing_address_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'mailing_address_id'),
                onFieldSubmitted: (_) {
                  _mailing_address_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _nic_no_Controller,
                decoration: const InputDecoration(labelText: 'nic_no'),
                onFieldSubmitted: (_) {
                  _nic_no_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _id_no_Controller,
                decoration: const InputDecoration(labelText: 'id_no'),
                onFieldSubmitted: (_) {
                  _id_no_FocusNode.requestFocus();
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
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _asgardeo_id_Controller,
                decoration: const InputDecoration(labelText: 'asgardeo_id'),
                onFieldSubmitted: (_) {
                  _asgardeo_id_FocusNode.requestFocus();
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addPerson(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addPerson(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Person person = Person(
          record_type: _record_type_Controller.text,
          preferred_name: _preferred_name_Controller.text,
          full_name: _full_name_Controller.text,
          notes: _notes_Controller.text,
          date_of_birth: _date_of_birth_Controller.text,
          sex: _sex_Controller.text,
          avinya_type_id: int.parse(_avinya_type_id_Controller.text),
          passport_no: _passport_no_Controller.text,
          permanent_address_id:
              int.parse(_permanent_address_id_Controller.text),
          mailing_address_id: int.parse(_mailing_address_id_Controller.text),
          nic_no: _nic_no_Controller.text,
          id_no: _id_no_Controller.text,
          phone: int.parse(_phone_Controller.text),
          organization_id: int.parse(_organization_id_Controller.text),
          asgardeo_id: _asgardeo_id_Controller.text,
          email: _email_Controller.text,
        );
        await createPerson(person);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add Person'),
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

class EditPersonPage extends StatefulWidget {
  static const String route = 'person/edit';
  final Person person;
  const EditPersonPage({super.key, required this.person});
  @override
  _EditPersonPageState createState() => _EditPersonPageState();
}

class _EditPersonPageState extends State<EditPersonPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _record_type_Controller;
  late FocusNode _record_type_FocusNode;
  late TextEditingController _preferred_name_Controller;
  late FocusNode _preferred_name_FocusNode;
  late TextEditingController _full_name_Controller;
  late FocusNode _full_name_FocusNode;
  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;
  late TextEditingController _date_of_birth_Controller;
  late FocusNode _date_of_birth_FocusNode;
  late TextEditingController _sex_Controller;
  late FocusNode _sex_FocusNode;
  late TextEditingController _avinya_type_id_Controller;
  late FocusNode _avinya_type_id_FocusNode;
  late TextEditingController _passport_no_Controller;
  late FocusNode _passport_no_FocusNode;
  late TextEditingController _permanent_address_id_Controller;
  late FocusNode _permanent_address_id_FocusNode;
  late TextEditingController _mailing_address_id_Controller;
  late FocusNode _mailing_address_id_FocusNode;
  late TextEditingController _nic_no_Controller;
  late FocusNode _nic_no_FocusNode;
  late TextEditingController _id_no_Controller;
  late FocusNode _id_no_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _asgardeo_id_Controller;
  late FocusNode _asgardeo_id_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  @override
  void initState() {
    super.initState();
    final Person person = widget.person;
    _record_type_Controller = TextEditingController(text: person.record_type);
    _record_type_FocusNode = FocusNode();
    _preferred_name_Controller =
        TextEditingController(text: person.preferred_name);
    _preferred_name_FocusNode = FocusNode();
    _full_name_Controller = TextEditingController(text: person.full_name);
    _full_name_FocusNode = FocusNode();
    _notes_Controller = TextEditingController(text: person.notes);
    _notes_FocusNode = FocusNode();
    _date_of_birth_Controller =
        TextEditingController(text: person.date_of_birth);
    _date_of_birth_FocusNode = FocusNode();
    _sex_Controller = TextEditingController(text: person.sex);
    _sex_FocusNode = FocusNode();
    _avinya_type_id_Controller =
        TextEditingController(text: person.avinya_type_id!.toString());
    _avinya_type_id_FocusNode = FocusNode();
    _passport_no_Controller = TextEditingController(text: person.passport_no);
    _passport_no_FocusNode = FocusNode();
    _permanent_address_id_Controller =
        TextEditingController(text: person.permanent_address_id!.toString());
    _permanent_address_id_FocusNode = FocusNode();
    _mailing_address_id_Controller =
        TextEditingController(text: person.mailing_address_id!.toString());
    _mailing_address_id_FocusNode = FocusNode();
    _nic_no_Controller = TextEditingController(text: person.nic_no);
    _nic_no_FocusNode = FocusNode();
    _id_no_Controller = TextEditingController(text: person.id_no);
    _id_no_FocusNode = FocusNode();
    _phone_Controller = TextEditingController(text: person.phone!.toString());
    _phone_FocusNode = FocusNode();
    _organization_id_Controller =
        TextEditingController(text: person.organization_id!.toString());
    _organization_id_FocusNode = FocusNode();
    _asgardeo_id_Controller = TextEditingController(text: person.asgardeo_id);
    _asgardeo_id_FocusNode = FocusNode();
    _email_Controller = TextEditingController(text: person.email);
    _email_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _record_type_Controller.dispose();
    _record_type_FocusNode.dispose();
    _preferred_name_Controller.dispose();
    _preferred_name_FocusNode.dispose();
    _full_name_Controller.dispose();
    _full_name_FocusNode.dispose();
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();
    _date_of_birth_Controller.dispose();
    _date_of_birth_FocusNode.dispose();
    _sex_Controller.dispose();
    _sex_FocusNode.dispose();
    _avinya_type_id_Controller.dispose();
    _avinya_type_id_FocusNode.dispose();
    _passport_no_Controller.dispose();
    _passport_no_FocusNode.dispose();
    _permanent_address_id_Controller.dispose();
    _permanent_address_id_FocusNode.dispose();
    _mailing_address_id_Controller.dispose();
    _mailing_address_id_FocusNode.dispose();
    _nic_no_Controller.dispose();
    _nic_no_FocusNode.dispose();
    _id_no_Controller.dispose();
    _id_no_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _organization_id_Controller.dispose();
    _organization_id_FocusNode.dispose();
    _asgardeo_id_Controller.dispose();
    _asgardeo_id_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Person you want to edit'),
              TextFormField(
                controller: _record_type_Controller,
                decoration: const InputDecoration(labelText: 'record_type'),
                onFieldSubmitted: (_) {
                  _record_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _preferred_name_Controller,
                decoration: const InputDecoration(labelText: 'preferred_name'),
                onFieldSubmitted: (_) {
                  _preferred_name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _full_name_Controller,
                decoration: const InputDecoration(labelText: 'full_name'),
                onFieldSubmitted: (_) {
                  _full_name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _notes_Controller,
                decoration: const InputDecoration(labelText: 'notes'),
                onFieldSubmitted: (_) {
                  _notes_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _date_of_birth_Controller,
                decoration: const InputDecoration(labelText: 'date_of_birth'),
                onFieldSubmitted: (_) {
                  _date_of_birth_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _sex_Controller,
                decoration: const InputDecoration(labelText: 'sex'),
                onFieldSubmitted: (_) {
                  _sex_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_id_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type_id'),
                onFieldSubmitted: (_) {
                  _avinya_type_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _passport_no_Controller,
                decoration: const InputDecoration(labelText: 'passport_no'),
                onFieldSubmitted: (_) {
                  _passport_no_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _permanent_address_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'permanent_address_id'),
                onFieldSubmitted: (_) {
                  _permanent_address_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _mailing_address_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'mailing_address_id'),
                onFieldSubmitted: (_) {
                  _mailing_address_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _nic_no_Controller,
                decoration: const InputDecoration(labelText: 'nic_no'),
                onFieldSubmitted: (_) {
                  _nic_no_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _id_no_Controller,
                decoration: const InputDecoration(labelText: 'id_no'),
                onFieldSubmitted: (_) {
                  _id_no_FocusNode.requestFocus();
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
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _asgardeo_id_Controller,
                decoration: const InputDecoration(labelText: 'asgardeo_id'),
                onFieldSubmitted: (_) {
                  _asgardeo_id_FocusNode.requestFocus();
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editPerson(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editPerson(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Person person = Person(
          id: widget.person.id,
          record_type: _record_type_Controller.text,
          preferred_name: _preferred_name_Controller.text,
          full_name: _full_name_Controller.text,
          notes: _notes_Controller.text,
          date_of_birth: _date_of_birth_Controller.text,
          sex: _sex_Controller.text,
          avinya_type_id: int.parse(_avinya_type_id_Controller.text),
          passport_no: _passport_no_Controller.text,
          permanent_address_id:
              int.parse(_permanent_address_id_Controller.text),
          mailing_address_id: int.parse(_mailing_address_id_Controller.text),
          nic_no: _nic_no_Controller.text,
          id_no: _id_no_Controller.text,
          phone: int.parse(_phone_Controller.text),
          organization_id: int.parse(_organization_id_Controller.text),
          asgardeo_id: _asgardeo_id_Controller.text,
          email: _email_Controller.text,
        );
        await updatePerson(person);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to edit the Person'),
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

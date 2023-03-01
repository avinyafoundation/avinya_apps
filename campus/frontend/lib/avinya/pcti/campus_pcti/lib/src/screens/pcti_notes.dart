import 'package:flutter/material.dart';
import 'package:pcti/src/screens/pcti_note_details.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/pcti_activity_instance_details.dart';
import '../widgets/pcti_note_list.dart';

class PctiNoteScreen extends StatefulWidget {
  final Activity? pctiActivity;

  const PctiNoteScreen({
    super.key,
    this.pctiActivity,
  });

  @override
  State<PctiNoteScreen> createState() => _PctiNoteScreenState(this.pctiActivity);
}

class _PctiNoteScreenState extends State<PctiNoteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Activity? pctiActivity;

  _PctiNoteScreenState(this.pctiActivity);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/pcti_notes/all')) {
      _tabController.index = 0;
    } 
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if (pctiActivity == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Activity found.'),
        ),
      );
    }
    return Scaffold(
          appBar: AppBar(
            title: const Text('PCTI Notes'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'All PCTI Notes',
                  icon: Icon(Icons.list_alt),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              PctiNoteList(
                onTap: _handlePctiNoteTapped,
                pctiActivity: pctiActivity,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => SelectPctiActivityInstancePage(pctiActivity: pctiActivity,),
                ),
              )
              .then((value) => setState(() {}));
            },
            child: const Icon(Icons.add),
          ),
        );
      }

  RouteState get _routeState => RouteStateScope.of(context);

  // this is to view a single pcti note
  // check this - dynamic or Evaluation?
  void _handlePctiNoteTapped(dynamic pctiNote) {
    // _routeState.go('/pcti_notes/${pctiNote.id}');
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => PctiNoteDetail(pctiNote: pctiNote,),
        )
      );
  }

  // to get all pcti notes
  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
        _routeState.go('/pcti_notes/all');
        break;
    }
  }
}
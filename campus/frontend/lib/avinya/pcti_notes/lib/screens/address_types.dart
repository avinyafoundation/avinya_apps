import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/address_type_list.dart';

class AddressTypeScreen extends StatefulWidget {
  const AddressTypeScreen({
    super.key,
  });

  @override
  State<AddressTypeScreen> createState() => _AddressTypeScreenState();
}

class _AddressTypeScreenState extends State<AddressTypeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    if (newPath.startsWith('/address_types/all')) {
      _tabController.index = 0;
    } 
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('AddressType'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All AddressTypes',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AddressTypeList(
              onTap: _handleAddressTypeTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => AddAddressTypePage(),
              ),
            )
            .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleAddressTypeTapped(AddressType addressType) {
    _routeState.go('/address_type/${addressType.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/address_types/all');
        break;
    }
  }
}

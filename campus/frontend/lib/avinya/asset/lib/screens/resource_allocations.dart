import 'package:ShoolManagementSystem/src/screens/resource_allocation_details.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/resource_allocation_list.dart';

class ResourceAllocationsScreen extends StatefulWidget {
  const ResourceAllocationsScreen({
    super.key,
  });

  @override
  State<ResourceAllocationsScreen> createState() =>
      _ResourceAllocationsScreenState();
}

class _ResourceAllocationsScreenState extends State<ResourceAllocationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    if (newPath.startsWith('/resource_allocations/all')) {
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
          title: const Text('Resource Allocations'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Resource Allocations',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ResourceAllocationList(onTap: _handleResourceAllocationTapped),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => AddResourceAllocationPage(),
                  ),
                )
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleResourceAllocationTapped(ResourceAllocation resourceAllocation) {
    _routeState.go('/resource_allocations/${resourceAllocation.id}');

    // Navigator.of(context).push<void>(MaterialPageRoute<void>(
    //   builder: (context) => ResourceAllocationDetailsScreen(
    //     resourceAllocation: resourceAllocation,
    //   ),
    // ));
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/resource_allocations/all');
        break;
    }
  }
}















// import 'package:flutter/material.dart';

// import '../data.dart';
// import '../routing.dart';
// import '../widgets/resource_allocation_list.dart';
// import '../widgets/asset_list.dart';

// class ResourceAllocationScreen extends StatefulWidget {
//   const ResourceAllocationScreen({
//     super.key,
//   });

//   @override
//   State<ResourceAllocationScreen> createState() =>
//       _ResourceAllocationScreenState();
// }

// class _ResourceAllocationScreenState extends State<ResourceAllocationScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(
//       length: 2,
//       vsync: this,
//     )..addListener(_handleTabIndexChanged);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final newPath = _routeState.route.pathTemplate;
//     if (newPath.startsWith('/resource_allocations/all')) {
//       _tabController.index = 0;
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.removeListener(_handleTabIndexChanged);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('ResourceAllocation'),
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(
//                 text: 'All ResourceAllocations',
//                 icon: Icon(Icons.list_alt),
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             ResourceAllocationList(
//               onTap: _handleResourceAllocationTapped,
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             Navigator.of(context)
//                 .push<void>(
//                   MaterialPageRoute<void>(
//                     builder: (context) => AddResourceAllocationPage(),
//                   ),
//                 )
//                 .then((value) => setState(() {}));
//           },
//           child: const Icon(Icons.add),
//         ),
//       );

//   RouteState get _routeState => RouteStateScope.of(context);

//   void _handleResourceAllocationTapped(ResourceAllocation resourceAllocation) {
//     _routeState.go('/resource_allocations/${resourceAllocation.asset!.id}');
//   }

//   void _handleTabIndexChanged() {
//     switch (_tabController.index) {
//       case 0:
//       default:
//         _routeState.go('/resourceAllocation/all');
//         break;
//     }
//   }
// }

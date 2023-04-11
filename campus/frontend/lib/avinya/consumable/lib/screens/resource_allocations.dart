//import 'package:ShoolManagementSystem/src/screens/resource_allocation_details.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/resource_allocation_list.dart';
import 'package:consumable/screens/favorite_list.dart';
import 'package:consumable/widgets/favorite_list_models.dart';
import 'package:consumable/widgets/favorite_page_models.dart';
import 'package:provider/provider.dart';

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
    if (newPath.startsWith('/consumables/all')) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  static List<String> menuItems = [
    'Admob Ads',
    'Android Studio',
    'Angularjs',
    'Bootstrap',
    'C-sharp',
    'Flutter Apps',
    'intellij-idea',
    'java-coffee',
    'json',
    'kotlin',
    'PHP Designer',
    'python',
    'React Native',
    'Stack over flow',
    'Unity 5',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Today's Menu3"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Add to Menu',
                icon: Icon(Icons.restaurant_menu),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Center(
              child: Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Breakfast Menu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          SizedBox(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10.0,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Wrap(
                                    spacing:
                                        8.0, // set the spacing between chips
                                    runSpacing:
                                        4.0, // set the spacing between rows of chips
                                    children: List.generate(menuItems.length,
                                        (index) {
                                      return Chip(
                                        backgroundColor: Colors.green.shade400,
                                        padding: EdgeInsets.all(10),
                                        label: Text(menuItems[index]),
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                      );
                                    }),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Lunch Menu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          SizedBox(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10.0,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Wrap(
                                    spacing:
                                        8.0, // set the spacing between chips
                                    runSpacing:
                                        4.0, // set the spacing between rows of chips
                                    children: List.generate(menuItems.length,
                                        (index) {
                                      return Chip(
                                        backgroundColor: Colors.blue.shade400,
                                        padding: EdgeInsets.all(10),
                                        label: Text(menuItems[index]),
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                      );
                                    }),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [FavoriteList(context: context)],
              ),
            ),
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
    _routeState.go('/consumables/${resourceAllocation.id}');

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

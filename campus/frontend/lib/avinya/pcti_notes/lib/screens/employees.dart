import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/employee_list.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({
    super.key,
  });

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/employees/popular')) {
      _tabController.index = 0;
    } else if (newPath.startsWith('/employees/new')) {
      _tabController.index = 1;
    } else if (newPath == '/employees/all') {
      _tabController.index = 2;
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
          title: const Text('Employees'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All',
                icon: Icon(Icons.people),
              ),
              Tab(
                text: 'Active',
                icon: Icon(Icons.new_releases),
              ),
              Tab(
                text: 'Absent',
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            EmployeeList(
              onTap: _handleEmployeeTapped,
            ),
            EmployeeList(
              onTap: _handleEmployeeTapped,
            ),
            EmployeeList(
              onTap: _handleEmployeeTapped,
            ),
          ],
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleEmployeeTapped(Employee employee) {
    _routeState.go('/employee/${employee.employee_id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        _routeState.go('/employees/new');
        break;
      case 2:
        _routeState.go('/employees/all');
        break;
      case 0:
      default:
        _routeState.go('/employees/popular');
        break;
    }
  }
}

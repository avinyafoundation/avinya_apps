import 'package:flutter/material.dart';
import '../routing.dart';

class SideNavigationSectionTile extends StatefulWidget {
  SideNavigationSectionTile(
      {super.key,
      required this.tileName,
      required this.route,
      required this.icon});

  final String tileName;
  final String route;
  final IconData icon;

  @override
  State<SideNavigationSectionTile> createState() => _SideNavigationSectionTileState();
}

class _SideNavigationSectionTileState extends State<SideNavigationSectionTile> {
  late bool isSectionHovered;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final routeState = RouteStateScope.of(context);

    return Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(widget.icon,
                  color: Colors.white, size: 20.0),
              title: Container(
                margin: EdgeInsets.only(left: 12.0),
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  widget.tileName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go(widget.route);
              },
            ),
          ),
        );
  }
}

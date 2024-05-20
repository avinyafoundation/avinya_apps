import 'package:flutter/material.dart';
import 'side_nav_section_tile.dart';


class SideNavigationSection extends StatefulWidget {
  
  SideNavigationSection(
    {super.key,
    required this.initialSectionHoveredValue,
    required this.sectionName,
    required this.icon,
    required this.destinations
    });

  final bool initialSectionHoveredValue;
  final String sectionName;
  final IconData icon;
  final List<SideNavigationSectionTile> destinations;

  @override
  State<SideNavigationSection> createState() => _SideNavigationSectionState();
}

class _SideNavigationSectionState extends State<SideNavigationSection> {

  late bool isSectionHovered;

  @override
  void initState() {
    super.initState();
    isSectionHovered = widget.initialSectionHoveredValue;

  }


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                    backgroundColor: Colors.yellow.shade600,
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    title: Container(
                      margin: EdgeInsets.only(left: 12.0),
                      transform: Matrix4.translationValues(-21, 0.0, 0.0),
                      child: Text(
                        widget.sectionName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    leading: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    children: widget.destinations,
                  ),
                  //),
                ),
            );
  }
}
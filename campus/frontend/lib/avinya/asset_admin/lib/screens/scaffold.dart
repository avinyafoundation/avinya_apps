import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/side_nav_section.dart';
import '../widgets/side_nav_section_tile.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isAssetDashboardSectionHovered = false;
  bool isConsumableDashboardSectionHovered = false;
  bool isAssetSectionHovered = false;
  bool isAssetReportSectionHovered = false;
  bool isConsumableSectionHovered = false;
  bool isConsumableReportSectionHovered = false;
  bool isStockReplenishmentSectionHovered = false;
  bool isStockDepletionSectionHovered = false;
  bool isVehicleFuelConsumptionSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    List<SideNavigationSectionTile> assetReportDestinations = [];
    List<SideNavigationSectionTile> consumableReportDestinations = [];

    assetReportDestinations = [
      SideNavigationSectionTile(
          tileName: "Resource Allocation",
          route: "/resource_allocation_report",
          icon: Icons.report),
    ];

    consumableReportDestinations = [
      SideNavigationSectionTile(
          tileName: "Consumable Weekly Report",
          route: "/consumable_weekly_report",
          icon: Icons.summarize_outlined),
      SideNavigationSectionTile(
          tileName: "Consumable Monthly Report",
          route: "/consumable_monthly_report",
          icon: Icons.summarize_sharp),
      SideNavigationSectionTile(
          tileName: "Vehicle Fuel Consumption Monthly Report",
          route: "/vehicle_fuel_consumption_monthly_report",
          icon: Icons.local_gas_station_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Campus Asset and Inventory Portal",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Logout',
            onPressed: () {
              SMSAuthScope.of(context).signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Signed Out')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Help'),
                    ),
                    body: Align(
                      alignment: Alignment.center,
                      child: SelectableText.rich(TextSpan(
                        text:
                            "If you need help, write to us at admissions-help@avinyafoundation.org",
                        style: new TextStyle(color: Colors.yellow[800]),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri(
                              scheme: 'mailto',
                              path: 'admissions-help@avinyafoundation.org',
                              query:
                                  'subject=Avinya Academy Admissions - Bandaragama&body=Question on my application', //add subject and body here
                            ));
                          },
                      )),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isAssetDashboardSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAssetDashboardSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAssetDashboardSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.dashboard,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Asset Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go('/asset_dashboard');
                        },
                      ),
                    ),
                  ),
                  // ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isAssetSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAssetSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAssetSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                    backgroundColor: Colors.yellow[800],
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    title: Container(
                      margin: EdgeInsets.only(left: 12.0),
                      transform: Matrix4.translationValues(-21, 0.0, 0.0),
                      child: Text(
                        "Asset",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    leading: Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    //childrenPadding: EdgeInsets.only(left: 25.0),
                    children: [
                      SideNavigationSection(
                        initialSectionHoveredValue: isAssetReportSectionHovered,
                        sectionName: "Reports",
                        icon: Icons.summarize,
                        destinations: assetReportDestinations,
                      ),
                    ],
                  ),
                  //),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isConsumableDashboardSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isConsumableDashboardSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isConsumableDashboardSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.space_dashboard_rounded,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Consumable Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go('/consumable_dashboard');
                        },
                      ),
                    ),
                  ),
                  // ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isConsumableSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isConsumableSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isConsumableSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                    backgroundColor: Colors.yellow[800],
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    title: Container(
                      margin: EdgeInsets.only(left: 12.0),
                      transform: Matrix4.translationValues(-21, 0.0, 0.0),
                      child: Text(
                        "Consumable",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    leading: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    children: [
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isStockReplenishmentSectionHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isStockReplenishmentSectionHovered = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isStockReplenishmentSectionHovered
                                ? Colors.white.withOpacity(0.3)
                                : null,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Icons.inventory,
                                color: Colors.white, size: 20.0),
                            title: Container(
                              margin: EdgeInsets.only(left: 12.0),
                              transform:
                                  Matrix4.translationValues(-25, 0.0, 0.0),
                              child: Text(
                                "Stock Replenishment",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer
                              routeState.go('/stock_replenishment');
                            },
                          ),
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isStockDepletionSectionHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isStockDepletionSectionHovered = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isStockDepletionSectionHovered
                                ? Colors.white.withOpacity(0.3)
                                : null,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Icons.inventory,
                                color: Colors.white, size: 20.0),
                            title: Container(
                              margin: EdgeInsets.only(left: 12.0),
                              transform:
                                  Matrix4.translationValues(-25, 0.0, 0.0),
                              child: Text(
                                "Stock Depletion",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer
                              routeState.go('/stock_depletion');
                            },
                          ),
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isVehicleFuelConsumptionSectionHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isVehicleFuelConsumptionSectionHovered = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isVehicleFuelConsumptionSectionHovered
                                ? Colors.white.withOpacity(0.3)
                                : null,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Icons.local_gas_station_sharp,
                                color: Colors.white, size: 20.0),
                            title: Container(
                              margin: EdgeInsets.only(left: 12.0),
                              transform:
                                  Matrix4.translationValues(-25, 0.0, 0.0),
                              child: Text(
                                "Vehicle Fuel Consumption",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer
                              routeState.go('/vehicle_fuel_consumption');
                            },
                          ),
                        ),
                      ),
                      SideNavigationSection(
                        initialSectionHoveredValue:
                            isConsumableReportSectionHovered,
                        sectionName: "Reports",
                        icon: Icons.summarize,
                        destinations: consumableReportDestinations,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
      body: const SMSScaffoldBody(),
      persistentFooterButtons: [
        new OutlinedButton(
            child: Text(
              'About',
              style: TextStyle(
                color: Colors.yellow[800],
                fontSize: 12,
              ),
            ),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2024, Avinya Foundation."),
      ],
    );
  }
}

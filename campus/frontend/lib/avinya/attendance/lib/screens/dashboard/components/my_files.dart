import 'package:gallery/avinya/attendance/lib/screens/responsive.dart';
import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data/dashboard_data.dart';
import '../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  MyFiles({
    Key? key,
  }) : super(key: key);

  List cardData = [
    DashboardData(
      title: "Daily Attendance",
      numOfFiles: 1328,
      svgSrc: "assets/icons/Documents.svg",
      color: primaryColor,
      percentage: 35,
    ),
    DashboardData(
      title: "Absent Students",
      numOfFiles: 1328,
      svgSrc: "assets/icons/google_drive.svg",
      color: Color(0xFFFFA113),
      percentage: 35,
    ),
    DashboardData(
      title: "Late Arrival",
      numOfFiles: 1328,
      svgSrc: "assets/icons/one_drive.svg",
      color: Color(0xFFA4CDFF),
      percentage: 10,
    ),
    DashboardData(
      title: "Present for Duty",
      numOfFiles: 5328,
      svgSrc: "assets/icons/drop_box.svg",
      color: Color(0xFF007EE5),
      percentage: 78,
    ),
    DashboardData(
      title: "Absent for Duty",
      numOfFiles: 5328,
      svgSrc: "assets/icons/drop_box.svg",
      color: Color(0xFF007EE5),
      percentage: 78,
    ),
    DashboardData(
      title: "Late for Duty",
      numOfFiles: 5328,
      svgSrc: "assets/icons/drop_box.svg",
      color: Color(0xFF007EE5),
      percentage: 78,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Files",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 ? 1.3 : 1,
            cardData: cardData,
          ),
          tablet: FileInfoCardGridView(cardData: cardData),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
            cardData: cardData,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
    required this.cardData,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final List cardData;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cardData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: cardData[index]),
    );
  }
}

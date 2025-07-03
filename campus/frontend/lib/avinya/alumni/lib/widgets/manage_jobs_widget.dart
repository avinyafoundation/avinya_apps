import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/alumni/lib/data/job_category.dart';
import 'package:gallery/avinya/alumni/lib/data/job_post.dart';
import 'package:gallery/avinya/alumni/lib/screens/admin_edit_alumni_profile.dart';
import 'package:gallery/avinya/alumni/lib/widgets/job_post_table.dart';
import 'package:sizer/sizer.dart';
import 'package:gallery/constants.dart';

class ManageJobsWidget extends StatefulWidget {
  const ManageJobsWidget({super.key});

  @override
  State<ManageJobsWidget> createState() => _ManageJobsWidgetState();
}

class _ManageJobsWidgetState extends State<ManageJobsWidget> {
  late Future<List<JobPost>> _fetchJobPostData;
  JobPostDataSource? _data;

  final List<String> _jobPostTypesOptions = ['text', 'image', 'text_with_link'];
  late Future<List<JobCategory>> _jobCategoryOptions;

  String? _selectedJobPostTypeValue;
  int? _selectedJobCategoryId;
  JobCategory? _selectedJobCategory;
  int _rowsPerPage = 4;
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _loadJobPostData(5, 0);
    _jobCategoryOptions = _loadJobCategoryData();
    _data = JobPostDataSource(_rowsPerPage, context);
    setState(() {
      _isLoading = true;
    });
    _data!.loadData(0);
    setState(() {
      _isLoading = false;
    });
    //_data.
  }

  // void _loadJobPostData(int result_limit, int offset) async {
  //   List<JobPost> jobPosts = await fetchJobPosts(result_limit, offset);
  //   setState(() {
  //     _data = JobPostDataSource(2, jobPosts, context);
  //   });
  // }

  Future<List<JobCategory>> _loadJobCategoryData() async {
    return await fetchJobCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_data = MyData(_fetchedAlumniListData, updateSelected, context);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Row(
                    //   children: [
                    //     FittedBox(
                    //       child: Text(
                    //         'Select a Job Post Type :',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .titleMedium!
                    //             .copyWith(
                    //               color: kTextBlackColor,
                    //               fontSize:
                    //                   SizerUtil.deviceType == DeviceType.mobile
                    //                       ? 09.sp
                    //                       : SizerUtil.deviceType ==
                    //                               DeviceType.tablet
                    //                           ? 12.sp
                    //                           : SizerUtil.deviceType ==
                    //                                   DeviceType.web
                    //                               ? 04.sp
                    //                               : 09.sp,
                    //             ),
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: 1.w,
                    //     ),
                    //     SizedBox(
                    //       width: 30.w,
                    //       child: DropdownButtonFormField<String>(
                    //         value: _selectedJobPostTypeValue,
                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(8.0)),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(8.0),
                    //             borderSide: BorderSide(
                    //                 color: Colors.grey.shade800, width: 1.5),
                    //           ),
                    //           contentPadding: EdgeInsets.symmetric(
                    //               horizontal: 12.0, vertical: 14.0),
                    //         ),
                    //         items: _jobPostTypesOptions.map((String status) {
                    //           return DropdownMenuItem<String>(
                    //             value: status,
                    //             child: Text(
                    //               status,
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           );
                    //         }).toList(),
                    //         onChanged: (newValue) {
                    //           setState(() {
                    //             _selectedJobPostTypeValue = newValue;
                    //           });
                    //         },
                    //         validator: (value) {
                    //           if (value == null || value.isEmpty) {
                    //             return 'Please select a job post type';
                    //           }
                    //           return null;
                    //         },
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .titleMedium!
                    //             .copyWith(
                    //               color: kTextBlackColor,
                    //               fontSize:
                    //                   SizerUtil.deviceType == DeviceType.mobile
                    //                       ? 09.sp
                    //                       : SizerUtil.deviceType ==
                    //                               DeviceType.tablet
                    //                           ? 12.sp
                    //                           : SizerUtil.deviceType ==
                    //                                   DeviceType.web
                    //                               ? 04.sp
                    //                               : 09.sp,
                    //             ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 5.h,
                    // ),
                    // Row(
                    //   children: [
                    //     FittedBox(
                    //       child: Text(
                    //         'Select a Job Category :',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .titleMedium!
                    //             .copyWith(
                    //               color: kTextBlackColor,
                    //               fontSize:
                    //                   SizerUtil.deviceType == DeviceType.mobile
                    //                       ? 09.sp
                    //                       : SizerUtil.deviceType ==
                    //                               DeviceType.tablet
                    //                           ? 12.sp
                    //                           : SizerUtil.deviceType ==
                    //                                   DeviceType.web
                    //                               ? 04.sp
                    //                               : 09.sp,
                    //             ),
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: 1.w,
                    //     ),
                    //     SizedBox(
                    //       width: 30.w,
                    //       child: FutureBuilder<List<JobCategory>>(
                    //           future: _jobCategoryOptions,
                    //           builder: (context, snapshot) {
                    //             if (snapshot.connectionState ==
                    //                 ConnectionState.waiting) {
                    //               return Container(
                    //                 margin: EdgeInsets.only(top: 10),
                    //                 child: SpinKitCircle(
                    //                   color: (Colors.blueGrey[400]),
                    //                   size: 70,
                    //                 ),
                    //               );
                    //             } else if (snapshot.hasError) {
                    //               return const Center(
                    //                 child: Text('Something went wrong...'),
                    //               );
                    //             } else if (!snapshot.hasData) {
                    //               return const Center(
                    //                 child: Text('No job category found'),
                    //               );
                    //             }
                    //             final jobCategoryData = snapshot.data!;
                    //             return DropdownButtonFormField<JobCategory>(
                    //               value: _selectedJobCategory,
                    //               decoration: InputDecoration(
                    //                 border: OutlineInputBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(8.0)),
                    //                 focusedBorder: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(8.0),
                    //                   borderSide: BorderSide(
                    //                       color: Colors.grey.shade800,
                    //                       width: 1.5),
                    //                 ),
                    //                 contentPadding: EdgeInsets.symmetric(
                    //                     horizontal: 12.0, vertical: 14.0),
                    //               ),
                    //               items: jobCategoryData
                    //                   .map((JobCategory jobCategory) {
                    //                 return DropdownMenuItem<JobCategory>(
                    //                   value: jobCategory,
                    //                   child: Text(
                    //                     jobCategory.name!,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 );
                    //               }).toList(),
                    //               onChanged: (JobCategory? newValue) {
                    //                 setState(() {
                    //                   if (newValue != null) {
                    //                     _selectedJobCategory = newValue;
                    //                     _selectedJobCategoryId = newValue!.id;
                    //                   }
                    //                 });
                    //               },
                    //               validator: (value) {
                    //                 if (value == null) {
                    //                   return 'Please select a job category';
                    //                 }
                    //                 return null;
                    //               },
                    //               style: Theme.of(context)
                    //                   .textTheme
                    //                   .titleMedium!
                    //                   .copyWith(
                    //                     color: kTextBlackColor,
                    //                     fontSize: SizerUtil.deviceType ==
                    //                             DeviceType.mobile
                    //                         ? 09.sp
                    //                         : SizerUtil.deviceType ==
                    //                                 DeviceType.tablet
                    //                             ? 12.sp
                    //                             : SizerUtil.deviceType ==
                    //                                     DeviceType.web
                    //                                 ? 04.sp
                    //                                 : 09.sp,
                    //                   ),
                    //             );
                    //           }),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          JobPostTableWidget(),
        ],
      ),
    );
  }
}

class JobPostDataSource extends DataTableSource {
  final BuildContext context;
  List<JobPost> jobPosts = [];
  int total = 0;
  final int resultLimit;
  //final Function(int limit, int offset) fetchJobPosts;

  JobPostDataSource(this.resultLimit, this.context);

  int _offset = 0;

  Future<void> loadData(int offset) async {
    _offset = offset;
    print("offset:${offset}");
    jobPosts = await fetchJobPosts(resultLimit, offset);
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    print("getRow called for index: $index");

    if (index >= jobPosts.length) return null;

    final jobPost = jobPosts[index];

    List<DataCell> cells = List<DataCell>.filled(7, DataCell.empty);

    cells[0] = DataCell(SizedBox(
      width: 200,
      child: Center(child: Text(jobPost.job_type.toString() ?? "N/A")),
    ));

    cells[1] = DataCell(SizedBox(
      width: 300,
      child: Center(child: Text(jobPost.job_text.toString() ?? "N/A")),
    ));

    cells[2] = DataCell(SizedBox(
      width: 170,
      child: Center(child: Text(jobPost.job_link.toString() ?? "N/A")),
    ));

    cells[3] = DataCell(SizedBox(
        width: 170,
        child: Center(
          child: Row(
            children: [
              jobPost.job_post_image != null
                  ? Image.memory(
                      base64Decode(jobPost.job_post_image.toString()),
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover,
                    )
                  : Spacer()
            ],
          ),
        )));

    cells[4] = DataCell(SizedBox(
      width: 90,
      child: Center(child: Text(jobPost.job_category_id.toString() ?? "N/A")),
    ));

    cells[5] = DataCell(SizedBox(
      width: 150,
      child:
          Center(child: Text(jobPost.application_deadline.toString() ?? "N/A")),
    ));

    cells[6] = DataCell(SizedBox(
      width: 200,
      child: Center(
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 20.0),
                width: 100.0,
                height: 30.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditAlumniProfileScreen(
                          id: jobPost.id, // Pass the ID
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 20.0),
                width: 100.0,
                height: 30.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditAlumniProfileScreen(
                          id: jobPost.id, // Pass the ID
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    return DataRow(cells: cells);

    // if (index == 0) {
    //   List<DataCell> cells = List<DataCell>.filled(7, DataCell.empty);
    //   return DataRow(
    //     cells: cells,
    //   );
    // }

    // if (_fetchedAlumniListData.length > 0 &&
    //     index <= _fetchedAlumniListData.length) {
    //   List<DataCell> cells = List<DataCell>.filled(7, DataCell.empty);

    // }

    return null; // Return null for invalid index values
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => jobPosts.length + 20;
  @override
  int get selectedRowCount => 0;
}
